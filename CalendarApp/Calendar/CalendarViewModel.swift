//
//  CalendarViewModel.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar

class CalendarViewModel: ObservableObject {
    // Dictionary to store events categorized by dates
    @Published var eventsDict: [String: [GTLRCalendar_Event]] = [:]
    
    // Currently selected date in string format
    @Published var selectedDate: String = Date().getDateString()
    
    // Flag to show or hide the month picker
    @Published var showMonthPicker: Bool = false
    
    // Currently selected month
    @Published var selectedCalendarMonth: Date = Date()
    
    // Flag to indicate if it's the first launch of the view
    @Published var firstLaunch: Bool = true
    
    // Variable to store loading state
    @Published var isLoading: Bool = false
    
    // Tuple to manage alert state and message
    @Published var alertData: (showAlert: Bool, alertMessage: String) = (false, StringConstants.errorMessage)

    // Calendar service object
    private let calendarService: CalendarService = CalendarService()
    
    // Computed property to get the selected month's number
    var selectedCalendarMonthNumber: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: selectedCalendarMonth)
    }
    
    // Computed property to get the selected year's number
    var selectedCalendarYear: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: selectedCalendarMonth)
    }
    
    // Computed property to get all dates in the selected month
    var allDatesInGivenMonth: [String] {
        getAllDatesInGivenMonth(selectedCalendarMonth) ?? []
    }
    
    // Function to handle activities on view appearance
    func onAppearActivities() {
        if firstLaunch {
            fetchEvents()
            firstLaunch = false
        }
    }
    
    // Function to update the selected date
    func updateSelectedDate(_ date: String) {
        if selectedDate == date {
            selectedDate = ""
        } else {
            selectedDate = date
        }
    }
    
    // Function to show an alert with a specific message
    func showAlert(_ message: String) {
        alertData = (true, message)
    }
    
    // Function to reset the alert data
    func resetAlert() {
        alertData = (false, StringConstants.errorMessage)
    }
    
    // Function to get all dates in a given month
    private func getAllDatesInGivenMonth(_ date: Date = Date()) -> [String]? {
        let calendar = Calendar.current
        let currentDate = date

        // Get the start of the month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return nil
        }

        // Get the range of days in the month
        guard let rangeOfDays = calendar.range(of: .day, in: .month, for: currentDate) else {
            return nil
        }

        // Generate all dates in the month
        var dates = [Date]()
        for day in rangeOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }

        return dates.map { $0.getDateString() }
    }
    
    // Function to reset the month to the current month
    func resetMonth() {
        showMonthPicker = false
        selectedCalendarMonth = Date()
        fetchEvents()
    }
    
    // Function to update the month with the picked month and year
    func updateMonth(pickedMonth: Int, pickedYear: Int) {
        showMonthPicker = false
        selectedCalendarMonth = firstDayOfMonth(year: pickedYear, month: pickedMonth) ?? Date()
        fetchEvents()
    }
    
    // Function to get the first day of a given month and year
    private func firstDayOfMonth(year: Int, month: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1
        
        return Calendar.current.date(from: dateComponents)
    }
    
    // Function to fetch events for the selected month
    func fetchEvents() {
        print("Fetch events called")
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.calendarService.fetchEvents(calendarMonth: selectedCalendarMonth) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false
                    switch result {
                    case .success(let events):
                        self.eventsDict = self.convertToEventDictionary(events: events)
                    case .failure(let error):
                        self.eventsDict = [:]
                        self.showAlert(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // Function to convert a list of events to a dictionary categorized by dates
    private func convertToEventDictionary(events: [GTLRCalendar_Event]) -> [String: [GTLRCalendar_Event]] {
        var eventDictionary: [String: [GTLRCalendar_Event]] = [:]

        for event in events {
            let dates = event.datesSpanned() ?? []
            dates.forEach { date in
                let key = date.getDateString()
                // Use the start date as the key in the dictionary
                if eventDictionary[key] == nil {
                    eventDictionary[key] = [event]
                } else {
                    eventDictionary[key]?.append(event)
                }
            }
        }

        return eventDictionary
    }
    
    // Function to perform event add action
    func addEvent(_ event: GTLRCalendar_Event) {
        appendEventToDates(event)
        showAlert("Event added successfully!")
    }
    
    // Function to append a new event to the dates it spans
    private func appendEventToDates(_ event: GTLRCalendar_Event) {
        let dates = event.datesSpanned() ?? []
        dates.forEach { date in
            let key = date.getDateString()
            // Use the start date as the key in the dictionary
            if eventsDict[key] == nil {
                eventsDict[key] = [event]
            } else {
                eventsDict[key]?.append(event)
            }
        }
    }
}
