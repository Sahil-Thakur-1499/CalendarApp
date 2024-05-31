//
//  MonthYearPickerView.swift
//  CalendarApp
//
//  Created by Sahil Thakur on 31/05/24.
//

import SwiftUI

struct MonthYearPickerView: View {
    @State private var pickedMonth: Int
    @State private var pickedYear: Int
    
    let monthRange: (min: Int, max: Int)
    let yearRange: (min: Int, max: Int)
    
    var resetClicked: (() -> Void)
    var applyClicked: ((_ pickedMonth: Int, _ pickedYear: Int) -> Void)
    
    // Constants for strings used in the view
    struct MonthYearPickerViewStrings {
        static let selectMonthYear = "Select month and year"
        static let thisMonth = "This month"
        static let apply = "Apply"
    }
    
    init(pickedMonth: Int, pickedYear: Int, monthRange: (min: Int, max: Int) = (1, 12), yearRange: (min: Int, max: Int) = (1900, 3000), resetClicked: @escaping () -> Void, applyClicked: @escaping (_ pickedMonth: Int, _ pickedYear: Int) -> Void) {
        self._pickedMonth = State(wrappedValue: pickedMonth)
        self._pickedYear = State(wrappedValue: pickedYear)
        self.monthRange = monthRange
        self.yearRange = yearRange
        self.resetClicked = resetClicked
        self.applyClicked = applyClicked
    }
    
    var body: some View {
        VStack {
            Text(MonthYearPickerViewStrings.selectMonthYear)
                .font(.title)
                .padding()
            
            Spacer()
            
            HStack {
                Picker("", selection: $pickedMonth) {
                    ForEach(monthRange.min...monthRange.max, id: \.self) { month in
                        Text(month.getMonthName)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("", selection: $pickedYear) {
                    ForEach(yearRange.min...yearRange.max , id: \.self) {
                        Text(String($0))
                    }
                }
                .pickerStyle(.wheel)
            }
                        
            applyResetDateButtonView
                .padding()
        }
    }
    
    // View for applying or resetting the selected date
    private var applyResetDateButtonView: some View {
        HStack {
            Button(action: {
                resetClicked()
            }, label: {
                Text(MonthYearPickerViewStrings.thisMonth)
                    .font(.headline)
                    .foregroundColor(Color.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 40)
            })
            
            Spacer()
            
            Button(action: {
                applyClicked(pickedMonth, pickedYear)
            }, label: {
                Text(MonthYearPickerViewStrings.apply)
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
            })
        }
        .padding()
    }
}

#Preview {
    MonthYearPickerView(pickedMonth: 2, pickedYear: 2024, resetClicked: { }, applyClicked: { _, _ in})
}
