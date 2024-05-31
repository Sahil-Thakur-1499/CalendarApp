//
//  CalendarService.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar

class CalendarService {
    var calendarService = GoogleSignInManager.shared.calendarService
    
    // Fetch events from Google Calendar
    func fetchEvents(calendarMonth: Date = Date(), completion: @escaping (Result<[GTLRCalendar_Event], Error>) -> Void) {
        // Get the current calendar
        let calendar = Calendar.current
        // Get the date components for the first day of the current month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendarMonth)) else {
            completion(.failure(NSError(domain: "FetchEvents", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get the first day of the current month"])))
            return
        }
        let timeZoneOffset = TimeInterval(TimeZone.current.secondsFromGMT(for: startOfMonth))
        let localStartOfMonth = startOfMonth.addingTimeInterval(timeZoneOffset)
        
        // Get the date components for the last day of the current month
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: 0), to: startOfMonth) else {
            completion(.failure(NSError(domain: "FetchEvents", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get the last day of the current month"])))
            return
        }
        let localEndOfMonth = endOfMonth.addingTimeInterval(timeZoneOffset)
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.orderBy = kGTLRCalendarOrderByStartTime
        query.singleEvents = true
        query.timeMin = GTLRDateTime(date: localStartOfMonth)
        query.timeMax = GTLRDateTime(date: localEndOfMonth)
        
        calendarService.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let events = (response as? GTLRCalendar_Events)?.items {
                completion(.success(events))
            } else {
                completion(.success([]))
            }
        }
    }
    
    // Create an event in Google Calendar
    func createEvent(summary: String, startDate: Date, endDate: Date, description: String? = nil, completion: @escaping (Result<GTLRCalendar_Event, Error>) -> Void) {
        let event = GTLRCalendar_Event()
        event.summary = summary
        
        let startDateTime = GTLRDateTime(date: startDate)
        let endDateTime = GTLRDateTime(date: endDate)
        
        event.start = GTLRCalendar_EventDateTime()
        event.start?.dateTime = startDateTime
        event.end = GTLRCalendar_EventDateTime()
        event.end?.dateTime = endDateTime
        event.descriptionProperty = description
        
        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        calendarService.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let event = response as? GTLRCalendar_Event {
                completion(.success(event))
            }
        }
    }
}
