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
                            .transition(.move(edge: .trailing)) // 원하는 전환 효과 선택
                    } else if selectedTab == .settings {
                        SettingsView()
                            .transition(.move(edge: .leading))
                    }
                }
                .animation(.easeInOut, value: selectedTab) // 전환 애니메이션 지정
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("새벽:D")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // d-day 추가 액션 구현 (예: 모달 화면 띄우기)
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
