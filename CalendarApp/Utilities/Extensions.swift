//
//  Extensions.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation
import SwiftUI

extension Int {
    var getMonthName: String {
       let formatter = DateFormatter()
       return formatter.monthSymbols[self - 1]
   }
}

extension Date {
    func getDateString(_ dateFormat: String = DateFormats.dayDateAndMonth.rawValue) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle =  .none
        dateFormatter.dateFormat = dateFormat
        let dueDateFormatted = dateFormatter.string(from: self )
        return dueDateFormatted
    }
    
    func isTimeAfterMidnight() -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let isPM = hour == 12
        
        // If it's PM, adjust the hour to 24-hour format
        let adjustedHour = isPM ? hour - 12 : hour
        
        // Check if the adjusted hour is greater than 12:00 AM
        return adjustedHour > 0 || isPM
    }
}

extension String {
    func convertStringToDateWithCurrentTime(_ year: Int, _ format: String = DateFormats.dayDateAndMonth.rawValue) -> Date {
        // Create a DateFormatter for the given format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        // Parse the string into a Date object
        guard let dateWithoutTime = dateFormatter.date(from: self) else {
            return Date()
        }

        // Get the current calendar and components
        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.day, .month], from: dateWithoutTime)
        let currentComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = dayComponents.month ?? 1
        dateComponents.day = dayComponents.day ?? 1
        dateComponents.hour = currentComponents.hour ?? 0
        dateComponents.minute = currentComponents.minute ?? 0
        dateComponents.second = currentComponents.second ?? 0

        return calendar.date(from: dateComponents) ?? Date()
    }
    
    var removeWhiteSpacesAndNewLines: String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
