//
//  BaseView.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 30/05/24.
//

import SwiftUI
import GoogleAPIClientForREST_Calendar

struct BaseView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                if authManager.authState == .signedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    BaseView()
        .environmentObject(AuthManager())
}
