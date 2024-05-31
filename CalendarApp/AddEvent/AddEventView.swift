//
//  AddEventView.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import SwiftUI
import GoogleAPIClientForREST_Calendar

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddEventViewModel

    var onAdd: (GTLRCalendar_Event) -> Void
    
    init(startDate: Date = Date(), onAdd: @escaping (GTLRCalendar_Event) -> Void) {
        self._viewModel = StateObject(wrappedValue: AddEventViewModel(startDate: startDate))
        self.onAdd = onAdd
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    // Event Details Section
                    Text(StringConstants.eventDetails.capitalized)
                        .font(.system(size: 18, weight: .semibold))
                    
                    // Title TextField
                    TextField(StringConstants.titleLabel, text: $viewModel.summary)
                        .font(.system(size: 16))
                        .submitLabel(.done)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .autocorrectionDisabled()
                    
                    // Start Date DatePicker
                    DatePicker(StringConstants.startDateLabel, selection: $viewModel.startDate, displayedComponents: [.date, .hourAndMinute])
                        .font(.system(size: 16))
                    
                    // End Date DatePicker
                    DatePicker(StringConstants.endDateLabel, selection: $viewModel.endDate, in: viewModel.endDateBegins..., displayedComponents: [.date, .hourAndMinute])
                        .font(.system(size: 16))
                    
                    // Description Section
                    VStack(alignment: .leading) {
                        Text(StringConstants.descriptionLabel)
                            .font(.system(size: 16))
                        
                        TextEditor(text: $viewModel.description)
                            .font(.system(size: 16, weight: .regular))
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .autocorrectionDisabled()
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button(StringConstants.doneButton) {
                                        endTextEditing()
                                    }
                                }
                            }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.08))
                .cornerRadius(10)
                
                Spacer(minLength: 32)
                
                // Save Button
                Button(action: {
                    endTextEditing()
                    viewModel.submitClicked(completion: { event in
                        if let event {
                            onAdd(event)
                            dismiss()
                        } else {
                            viewModel.showAlert(StringConstants.errorMessage)
                        }
                    })
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .scaleEffect(1.2)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(.blue)
                            .cornerRadius(10)
                    } else {
                        Text(StringConstants.saveButton)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .disabled(viewModel.isLoading)
        }
        .scrollDismissesKeyboard(.immediately)
        .showAlert(showError: $viewModel.alertData.0, title: "", message: viewModel.alertData.alertMessage, cancelButton: .cancel(StringConstants.ok), buttonClicked: { _ in
            viewModel.resetAlertData()
        })
        .navigationTitle(StringConstants.addEvent)
    }
}

#Preview {
    AddEventView(startDate: Date(), onAdd: { _ in })
}
