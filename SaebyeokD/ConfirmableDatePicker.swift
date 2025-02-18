//
//  ConfirmableDatePicker.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/18/25.
//

import SwiftUI

struct ConfirmableDatePicker: View {
    @Binding var selectedDate: Date
    @State private var tempDate: Date
    @State private var isExpanded: Bool = false
    
    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        _tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                    if isExpanded {
                        tempDate = selectedDate
                    }
                }
            }) {
                HStack {
                    Text("날짜: \(selectedDate, formatter: dateFormatter)")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.white)
                }
            }
            
            if isExpanded {
                VStack(spacing: 12) {
                    DatePicker(
                        "날짜 선택",
                        selection: $tempDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(.white)
                    .preferredColorScheme(.dark)
                    .onChange(of: tempDate) { oldValue, newValue in
                        selectedDate = newValue
                    }
                    
                    Button(action: {
                        withAnimation {
                            isExpanded = false
                        }
                    }) {
                        Text("확인")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 8)
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter
}()
