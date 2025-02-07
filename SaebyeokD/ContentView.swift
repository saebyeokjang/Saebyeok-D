//
//  ContentView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .dday

    enum Tab: Hashable {
        case dday, settings
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("디데이").tag(Tab.dday)
                    Text("설정").tag(Tab.settings)
                }
                .pickerStyle(.segmented)
                .padding()

                ZStack {
                    if selectedTab == .dday {
                        DDayListView()
                            .transition(.move(edge: .trailing))
                    } else if selectedTab == .settings {
                        SettingsView()
                            .transition(.move(edge: .leading))
                    }
                }
                .animation(nil, value: selectedTab) // 애니메이션 없이 전환
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("새벽:D")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddDDayView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
