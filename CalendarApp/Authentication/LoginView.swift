//
//  LoginView.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 30/05/24.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    
    // Accesses the AuthManager object from the environment
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                // Calendar app icon
                Image(systemName: "calendar.badge.checkmark.rtl")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                // Title text for the app
                Text(StringConstants.calendarAppTitle)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                // Google Sign-In button
                GoogleSignInButton {
                    // Call the sign-in function in the view model
                    viewModel.signInWithGoogle(authManager: authManager, dismiss: {
                        dismiss()
                    })
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                
                Spacer()
            }
            .padding()
            // Show alert for errors
            .showAlert(
                showError: $viewModel.alertData.0,
                message: viewModel.alertData.alertMessage,
                cancelButton: .cancel(StringConstants.ok),
                buttonClicked: { _ in
                    // Reset the alert data when the button is clicked
                    viewModel.resetAlertData()
                }
            )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
