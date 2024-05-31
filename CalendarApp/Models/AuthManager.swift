//
//  AuthManager.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 30/05/24.
//

import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

enum AuthState {
    // Authenticated in Firebase using one of service providers, and not anonymous.
    case signedIn
    // Not authenticated in Firebase.
    case signedOut
}

class AuthManager: ObservableObject {

    // Current Firebase auth user.
    @Published var user: User?

    // Auth state for current user.
    @Published var authState = AuthState.signedOut
    
    @Published var makeFetchCall: Bool = false

    // Auth state listener handler
    private var authStateHandle: AuthStateDidChangeListenerHandle!

    // Common auth link errors.
    private let authLinkErrors: [AuthErrorCode.Code] = [
        .emailAlreadyInUse,
        .credentialAlreadyInUse,
        .providerAlreadyLinked
    ]

    init() {
        // Start listening to auth changes.
        configureAuthStateChanges()

        // Verify Google credentials
        verifySignInProvider { [weak self] revoked in
            guard let self = self else { return }
            if !revoked {
                makeFetchCall = true
            }
        }
    }
    
    // Update auth state for given user.
    private func updateState(user: User?) {
        self.user = user
        let isAuthenticatedUser = user != nil

        if isAuthenticatedUser {
            self.authState = .signedIn
        } else {
            self.authState = .signedOut
        }
    }

    // Add listener for changes in the authorization state.
    func configureAuthStateChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateState(user: user)
            }
        }
    }

    // Remove listener for changes in the authorization state.
    func removeAuthStateListener() {
        Auth.auth().removeStateDidChangeListener(authStateHandle)
    }

    // Verify sign in providers, whether or not they have been revoked.
    private func verifySignInProvider(completion: @escaping (Bool) -> Void) {
        guard let providerData = Auth.auth().currentUser?.providerData else { return }
        var isGoogleCredentialRevoked = false

        if providerData.contains(where: { $0.providerID == "google.com" }) {
            verifyGoogleSignIn { isRevoked in
                isGoogleCredentialRevoked = isRevoked
                if isGoogleCredentialRevoked {
                    // Sign out if user not signed out, or signed in anonymously.
                    if self.authState != .signedIn {
                        self.signOut { error in
                            if let error = error {
                                print("FirebaseAuthError: verifySignInProvider() failed. \(error)")
                            }
                            completion(isGoogleCredentialRevoked)
                        }
                    } else {
                        completion(isGoogleCredentialRevoked)
                    }
                } else {
                    completion(isGoogleCredentialRevoked)
                }
            }
        } else {
            completion(isGoogleCredentialRevoked)
        }
    }

    // Verify Google provider - Boolean indicates whether user is authorized, or authorization has been revoked
    private func verifyGoogleSignIn(completion: @escaping (Bool) -> Void) {
        guard let providerData = Auth.auth().currentUser?.providerData,
              providerData.contains(where: { $0.providerID == "google.com" }) else {
                  completion(false)
                  return
              }
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil {
                completion(true)
            } else {
                user?.refreshTokensIfNeeded(completion: { _, error in
                    if error != nil {
                        completion(true)
                    } else {
                        guard (user?.accessToken.tokenString) != nil else { return }
                        GoogleSignInManager.shared.calendarService.authorizer = user?.fetcherAuthorizer
                        completion(false)
                    }
                })
            }
        }
    }

    // Authenticate with Firebase using Google `idToken`, and `accessToken` from given `GIDGoogleUser`.
    func googleAuth(_ user: GIDGoogleUser, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        guard let idToken = user.idToken?.tokenString else {
            completion(nil, NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID token found"]))
            return
        }

        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        authSignIn(credentials: credentials, completion: completion)
    }

    private func authSignIn(credentials: AuthCredential, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(with: credentials) { result, error in
            DispatchQueue.main.async {
                self.updateState(user: result?.user)
            }
            completion(result, error)
        }
    }

    // Sign out a user from Firebase Provider.
    func firebaseProviderSignOut(_ user: User) {
        let providers = user.providerData
            .map { $0.providerID }.joined(separator: ", ")
        if providers.contains("google.com") {
            GoogleSignInManager.shared.signOutFromGoogle()
        }
    }

    // Sign out current `Firebase` auth user
    func signOut(completion: @escaping (Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            // Sign out current authenticated user in Firebase
            firebaseProviderSignOut(user)
            do {
                try Auth.auth().signOut()
                DispatchQueue.main.async {
                    self.authState = .signedOut
                }
                completion(nil)
            }
            catch let error as NSError {
                print("FirebaseAuthError: failed to sign out from Firebase, \(error)")
                completion(error)
            }
        } else {
            completion(nil)
        }
    }
}
