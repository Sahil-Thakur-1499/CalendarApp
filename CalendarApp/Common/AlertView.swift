//
//  AlertView.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import SwiftUI

struct AlertView: View {
    @Binding var showError: Bool
    let title: String
    let message: String
    let buttons: [String]
    let cancelButton: CancelButton
    var buttonClicked: ((String) -> Void)?
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 0, height: 0)
            .alert(title, isPresented: $showError, actions: {
                Button(role: buttons.isEmpty ? .cancel : cancelButton.type) {
                    buttonClicked?(cancelButton.getTitle)
                } label: {
                    Text(cancelButton.getTitle)
                }
                
                ForEach(Array(buttons.enumerated()), id: \.offset) { (index, button) in
                    Button(role: index == buttons.count - 1 && cancelButton.type != .cancel ? .cancel : nil) {
                        buttonClicked?(button)
                    } label: {
                        Text(button)
                    }
                }
            }, message: {
                Text(message)
            })
    }
}

#Preview {
    AlertView(showError: .constant(true), title: "Alert", message: "This is an alert", buttons: [""], cancelButton: .destructive("Delete"))
}


enum CancelButton: Equatable {
    case cancel(_ title: String)
    case destructive(_ title: String)
    
    var type: ButtonRole {
        switch self {
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
    
    var getTitle: String {
        switch self {
        case .cancel(let title):
            return title
        case .destructive(let title):
            return title
        }
    }
}

extension View {
    func showAlert(showError: Binding<Bool>, title: String = "Alert", message: String = "", buttons: String..., cancelButton: CancelButton = .cancel("Cancel"), buttonClicked: @escaping ((String) -> Void)) -> some View {
        let filteredButtons = buttons.filter({ !$0.isEmpty })
        return ZStack {
            self
            AlertView(showError: showError, title: title, message: message, buttons: filteredButtons, cancelButton: cancelButton, buttonClicked: { button in
                buttonClicked(button)
            })
        }
    }
}
