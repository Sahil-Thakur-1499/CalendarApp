//
//  CalendarView.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 30/05/24.
//

import SwiftUI
import GoogleAPIClientForREST_Calendar

struct CalendarView: View {
    @StateObject var viewModel: CalendarViewModel = CalendarViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                headerView
                    .padding(.bottom, 8)
                                
                calendarDatesView
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(Color.gray.opacity(0.08))
            .cornerRadius(10)
            .padding(.horizontal)
            .onAppear {
                viewModel.onAppearActivities()
            }
            .showAlert(
                showError: $viewModel.alertData.showAlert,
                message: viewModel.alertData.alertMessage,
                cancelButton: .cancel(StringConstants.ok),
                buttonClicked: { _ in 
                    viewModel.resetAlert()
                }
            )
        }
    }
    
    // Header View containing the month picker and add event button
    private var headerView: some View {
        HStack {
            Text(viewModel.selectedCalendarMonth.getDateString(DateFormats.monthAndYear.rawValue))
                .font(.title)
            
            Spacer()
            
            Button(action: { viewModel.showMonthPicker = true }) {
                Image(systemName: "calendar.circle")
                    .font(.title)
                    .foregroundColor(.black)
            }
            .sheet(isPresented: $viewModel.showMonthPicker) {
                MonthYearPickerView(
                    pickedMonth: viewModel.selectedCalendarMonthNumber,
                    pickedYear: viewModel.selectedCalendarYear,
                    resetClicked: { viewModel.resetMonth() },
                    applyClicked: { pickedMonth, pickedYear in
                        viewModel.updateMonth(pickedMonth: pickedMonth, pickedYear: pickedYear)
                    }
                )
                .presentationDetents([.medium])
            }
            
            NavigationLink(
                destination: AddEventView { event in
                    viewModel.addEvent(event)
                },
                label: {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.black)
                }
            )
        }
    }
    
    // View displaying the dates in the selected month and their respective events
    private var calendarDatesView: some View {
        ForEach(viewModel.allDatesInGivenMonth, id: \.self) { date in
            VStack {
                Button(action: { viewModel.updateSelectedDate(date) }) {
                    HStack {
                        Text(date)
                        
                        Spacer()
                        
                        Group {
                            if let eventsForSelectedDate = viewModel.eventsDict[date] {
                                Text("\(eventsForSelectedDate.count)\(StringConstants.eventSuffix)")
                                
                                Image(systemName: "chevron.down")
                            } else {
                                Text(StringConstants.noEvents)
                            }
                        }
                        .redacted(reason: viewModel.isLoading ? [.placeholder] : [])
                    }
                    .foregroundColor(dateRowColor(date))
                }
                
                if viewModel.selectedDate == date {
                    VStack {
                        if let eventsForSelectedDate = viewModel.eventsDict[date] {
                            ForEach(Array(eventsForSelectedDate.enumerated()), id: \.offset) { index, event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    HStack(alignment: .top) {
                                        Text(event.summary ?? StringConstants.noTitle)
                                        
                                        Spacer()
                                        
                                        if let status = event.status {
                                            Text(status.capitalized)
                                        }
                                    }
                                    .foregroundColor(.black)
                                }
                            }
                        }
                        NavigationLink(destination: AddEventView(startDate: date.convertStringToDateWithCurrentTime(viewModel.selectedCalendarYear)) { event in
                            viewModel.addEvent(event)
                        }) {
                            HStack {
                                Text(StringConstants.addEvent)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(Color.white)
                    .cornerRadius(6)
                }
                
                Divider()
            }
        }
    }
    
    // Function to determine the color of the date row
    private func dateRowColor(_ date: String) -> Color {
        if viewModel.selectedDate == date {
            return .blue
        } else if date == Date().getDateString() {
            return .purple
        } else {
            return .black
        }
    }
}

#Preview {
    CalendarView()
}
