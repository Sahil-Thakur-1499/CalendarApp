//
//  HomeView.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 30/05/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Display user information and sign-in/sign-out button
                    userInfoHeader
                    
                    // Show CalendarView if user is signed in and fetch call is enabled
                    if authManager.authState == .signedIn, authManager.makeFetchCall {
                        CalendarView()
                    }
                }
                // Show alert for errors
                .showAlert(
                    showError: $viewModel.alertData.showAlert,
                    message: viewModel.alertData.alertMessage,
                    cancelButton: .cancel(StringConstants.okayButton),
                    buttonClicked: { _ in
                        viewModel.alertData.showAlert = false
                    }
                )
            }
            .navigationTitle(StringConstants.calendarTitle)
        }
    }

    /// A view that displays user information and a sign-in/sign-out button.
    private var userInfoHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                // Display user name and email if signed in
                if authManager.authState == .signedIn {
                    if let name = authManager.user?.displayName {
                        Text(name)
                            .font(.headline)
                    }
                    if let email = authManager.user?.email {
                        Text(email)
                            .font(.subheadline)
                    }
                } else {
                    // Display sign-in prompt if not signed in
                    Text(StringConstants.signInToViewEvents)
                        .font(.headline)
                }
            }
            Spacer()
            // Sign-in/sign-out button
            Button(action: {
                viewModel.handleAuthButtonTap(authManager: authManager)
            }) {
                Text(authManager.authState == .signedIn ? StringConstants.signOut : StringConstants.signIn)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(10)
        .padding()
        // Show login view as a sheet
        .sheet(isPresented: $viewModel.showLoginSheet) {
            LoginView()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
