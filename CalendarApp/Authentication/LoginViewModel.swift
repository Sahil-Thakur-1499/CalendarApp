//
//  LoginViewModel.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var alertData: (showAlert: Bool, alertMessage: String) = (false, StringConstants.errorMessage)
    
    /// Sign in with Google and authenticate with Firebase.
    func signInWithGoogle(authManager: AuthManager, dismiss: @escaping () -> Void) {
        GoogleSignInManager.shared.signInWithGoogle { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(StringConstants.googleSignInError + "\(error)")
                return
            }
            
            guard let user = user else {
                self.showAlert(StringConstants.noUserFoundError)
                return
            }
            
            authManager.googleAuth(user) { result, error in
                if let error = error {
                    self.showAlert(StringConstants.firebaseAuthError + "\(error)")
                    return
                }
                if result != nil {
                    dismiss()
                }
            }
        }
    }
    
    func resetAlertData() {
        alertData = (false, StringConstants.errorMessage)
    }
    
    func showAlert(_ message: String) {
        alertData = (true, message)
    }
}
