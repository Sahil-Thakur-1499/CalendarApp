//
//  AddEventViewModel.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar

class AddEventViewModel: ObservableObject {
    // Form variables
    @Published var summary: String = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var description: String = ""

    // Tuple to manage alert state and message
    @Published var alertData: (showAlert: Bool, alertMessage: String) = (false, StringConstants.errorMessage)
    
    // Variable to store loading state
    @Published var isLoading: Bool = false
    
    // Calendar service object
    private let calendarService: CalendarService = CalendarService()
    
    init(startDate: Date = Date()) {
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .minute, value: 1, to: startDate) ?? startDate
    }

    // Computes end date begins
    var endDateBegins: Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: startDate) ?? startDate
    }

    // Submit Event
    func submitClicked(completion: @escaping (GTLRCalendar_Event?) -> Void) {
        if validateFields() {
            createEvent(completion: completion)
        }
    }
    
    // Validates fields
    private func validateFields() -> Bool {
        if summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert(StringConstants.titleMissing)
            return false
        }
        let isDescriptionFilled = !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, isDescriptionFilled {
            showAlert(StringConstants.descriptionMissing)
            return false
        }
        return true
    }
    
    func showAlert(_ message: String) {
        alertData = (true, message)
    }
    
    func resetAlertData() {
        alertData = (false, StringConstants.errorMessage)
    }
    
    // Function to create a new event
    private func createEvent(completion: @escaping (GTLRCalendar_Event?) -> Void) {
        isLoading = true
        calendarService.createEvent(summary: summary, startDate: startDate, endDate: endDate, description: description) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let event):
                completion(event)
            case .failure(let error):
                self.showAlert(error.localizedDescription)
                completion(nil)
            }
        }
    }
}
