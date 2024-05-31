//
//  AppInfo.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation

struct AppInfo {
    static var bundle: Bundle {
        return Bundle.main
    }

    static func infoDictionary(_ key: String) -> String {
        return bundle.infoDictionary?[key] as? String ?? ""
    }

    static let googleServerId = AppInfo.infoDictionary("ServerId")
    static let version = AppInfo.infoDictionary("CFBundleShortVersionString")
    static let bundleId = AppInfo.bundle.bundleIdentifier ?? ""
}
