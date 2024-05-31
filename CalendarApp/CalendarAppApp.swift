//
//  CalendarAppApp.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 30/05/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
struct CalendarAppApp: App {
    // Register app delegate for Firebase configuration
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // Add StateObject authManager.
    @StateObject var authManager: AuthManager = AuthManager()
        
    var body: some Scene {
        WindowGroup {
            BaseView()
                .environmentObject(authManager) // Pass authManager to enviromentObject.
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
