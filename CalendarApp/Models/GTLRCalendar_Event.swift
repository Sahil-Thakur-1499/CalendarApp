//
//  GTLRCalendar_Event.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar

extension GTLRCalendar_Event {
    func datesSpanned() -> [Date]? {
        guard let startDateTime = start?.dateTime?.date ?? start?.date?.date else { return nil }
        
        let calendar = Calendar.current
        
        var endDateTime: Date
        if let endTime = end?.dateTime?.date {
            endDateTime = endTime
        } else if let endDate = end?.date?.date, let updatedDate = calendar.date(byAdding: .second, value: -1, to: endDate) {
            endDateTime = updatedDate
        } else {
            return [startDateTime]
        }

        var dates: [Date] = []
        var currentDate = startDateTime
        
        while currentDate <= endDateTime {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
}
