//
//  HomeViewModel.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var showLoginSheet = false
    @Published var alertData: (showAlert: Bool, alertMessage: String) = (false, StringConstants.errorMessage)
    
    /// Handles the authentication button tap, either showing the login sheet or signing out.
    func handleAuthButtonTap(authManager: AuthManager) {
        if authManager.authState != .signedIn {
            showLoginSheet = true
        } else {
            signOut(authManager: authManager)
        }
    }

    /// Signs out the user and displays an alert if there's an error.
    func signOut(authManager: AuthManager) {
        authManager.signOut { [weak self] error in
            if let error = error {
                self?.alertData = (true, error.localizedDescription)
            }
        }
    }
}
