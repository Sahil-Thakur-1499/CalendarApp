//
//  EventDetailViewModel.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar

class EventDetailViewModel: ObservableObject {
    let event: GTLRCalendar_Event

    // Initialize the view model with the provided event
    init(event: GTLRCalendar_Event) {
        self.event = event
    }

    // Computed property to extract basic details of the event
    var basicDetails: [(title: String, value: String)] {
        var details: [(title: String, value: String)] = []

        // Extract and append the summary if available
        if let summary = event.summary, !summary.isEmpty {
            details.append((title: StringConstants.title, value: summary))
        }

        // Extract and append the location if available
        if let location = event.location, !location.isEmpty {
            details.append((title: StringConstants.location, value: location))
        }

        // Extract and append the start date if available
        if let startDate = event.start?.dateTime?.date ?? event.start?.date?.date {
            details.append((title: StringConstants.starts, value: formattedDate(startDate)))
        }

        // Extract and append the end date if available
        if let endDate = event.end?.dateTime?.date ?? event.end?.date?.date {
            details.append((title: StringConstants.ends, value: formattedDate(endDate)))
        }

        // Extract and append the description if available
        if let description = event.descriptionProperty, !description.isEmpty {
            details.append((title: StringConstants.description, value: description))
        }

        // Extract and append the status if available
        if let status = event.status {
            details.append((title: StringConstants.yourStatus, value: status))
        }

        return details
    }

    // Computed property to extract additional information of the event
    var additionalInformation: [(title: String, value: String)] {
        var details: [(title: String, value: String)] = []

        // Extract and append the creator's email if available
        if let creator = event.creator?.email {
            details.append((title: StringConstants.creator, value: creator))
        }

        // Extract and append the visibility if available
        if let visibility = event.visibility {
            details.append((title: StringConstants.visibility, value: visibility))
        }

        // Extract and append the last updated date if available
        if let updated = event.updated?.date {
            details.append((title: StringConstants.lastUpdated, value: formattedDate(updated)))
        }

        return details
    }

    // Computed property to extract attendees' information of the event
    var attendees: [(title: String, value: String)] {
        var details: [(title: String, value: String)] = []

        // Extract and append attendees' email and status if available
        if let attendees = event.attendees, !attendees.isEmpty {
            for attendee in attendees {
                let email = attendee.email ?? StringConstants.noEmail
                let status = attendee.responseStatus ?? StringConstants.noStatus
                details.append((title: email, value: status))
            }
        }

        return details
    }
    
    // Formats a given date into a string representation
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
