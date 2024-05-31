//
//  EventDetailView.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import SwiftUI
import GoogleAPIClientForREST_Calendar

struct EventDetailView: View {
    @StateObject var viewModel: EventDetailViewModel

    init(event: GTLRCalendar_Event) {
        self._viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                detailSection(title: StringConstants.basicDetails, details: viewModel.basicDetails)
                
                detailSection(title: StringConstants.additionalInformation, details: viewModel.additionalInformation)
                
                attendeesSection
            }
            .padding()
        }
        .navigationTitle(StringConstants.eventDetails)
    }

    // View for displaying a section of event details
    @ViewBuilder
    private func detailSection(title: String, details: [(title: String, value: String)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .padding(.bottom, 4)
            
            ForEach(details, id: \.self.title) { detail in
                detailRow(title: detail.title, value: detail.value)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(10)
    }

    // View for displaying attendees section
    @ViewBuilder
    private var attendeesSection: some View {
        if !viewModel.attendees.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(StringConstants.attendees)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.bottom, 4)
                
                ForEach(viewModel.attendees, id: \.self.title) { attendee in
                    detailRow(title: attendee.title, value: attendee.value)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.08))
            .cornerRadius(10)
        }
    }

    // View for displaying a single detail row
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: createDummyEvent())
    }
    
    static func createDummyEvent() -> GTLRCalendar_Event {
        let event = GTLRCalendar_Event()
        event.summary = "Sample Event"
        event.status = "confirmed"
                
        let attendee1 = GTLRCalendar_EventAttendee()
        attendee1.email = "attendee1@example.com"
        
        let attendee2 = GTLRCalendar_EventAttendee()
        attendee2.email = "attendee2@example.com"
        
        event.attendees = [attendee1, attendee2]
        
        event.visibility = "public"
        
        let updated = GTLRDateTime(date: Date())
        event.updated = updated
        
        return event
    }
}
