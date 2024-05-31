//
//  GoogleSignInManager.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 30/05/24.
//

//
//  GoogleSignInManager.swift
//  AuthLogin
//
//  Created by Marwa Abou Niaaj on 01/12/2023.
//

import GoogleSignIn
import FirebaseCore
import GoogleAPIClientForREST_Calendar

class GoogleSignInManager {
    
    // GoogleSignInManager shared instance.
    static let shared = GoogleSignInManager()
    
    // Google auth result
    typealias GoogleAuthResult = (GIDGoogleUser?, Error?) -> Void
    
    var calendarService = GTLRCalendarService()
    
    private init() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let configuration = GIDConfiguration(clientID: clientID, serverClientID: AppInfo.googleServerId)
        GIDSignIn.sharedInstance.configuration = configuration
    }
    
    // Sign in with `Google`.
    func signInWithGoogle(completion: @escaping GoogleAuthResult) {
        // Check previous sign-in.
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if error != nil {
                    // Previous sign in available, but was previously revoked, so initiate sign in flow.
                    self.googleSignInFlow(completion: completion)
                } else {
                    user?.refreshTokensIfNeeded(completion: { _, error in
                        if let error = error {
                            completion(nil, error)
                        } else {
                            self.setAuthorizer(user)
                            completion(user, nil)
                        }
                    })
                }
            }
        } else {
            googleSignInFlow(completion: completion)
        }
    }
    
    private func googleSignInFlow(completion: @escaping GoogleAuthResult) {
        // Accessing rootViewController through shared instance of UIApplication.
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                completion(nil, NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No window scene found"]))
                return
            }
            guard let rootViewController = windowScene.windows.first?.rootViewController else {
                completion(nil, NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"]))
                return
            }
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, additionalScopes: ["https://www.googleapis.com/auth/calendar"]) { user, error in
                if let user = user {
                    self.setAuthorizer(user.user)
                }
                completion(user?.user, error)
            }
        }
    }
    
    private func setAuthorizer(_ user: GIDGoogleUser?) {
        guard (user?.accessToken.tokenString) != nil else { return }
        self.calendarService.authorizer = user?.fetcherAuthorizer
    }
    
    // Sign out from `Google`.
    func signOutFromGoogle() {
        GIDSignIn.sharedInstance.signOut()
    }
}
