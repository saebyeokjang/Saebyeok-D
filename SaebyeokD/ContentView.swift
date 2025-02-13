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
    
    enum Tab: String, CaseIterable {
        case dday = "디데이"
        case settings = "설정"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                NightSkyBackground()
                
                VStack(spacing: 16) {
                    HStack {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation {
                                    selectedTab = tab
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(tab.rawValue)
                                        .font(.custom("NIXGONM-Vb", size: 18))
                                        .foregroundColor(selectedTab == tab ? .white : .gray)
                                    // 선택된 탭 밑줄
                                    Rectangle()
                                        .fill(selectedTab == tab ? Color.white : Color.clear)
                                        .frame(height: 2)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top, 16)
                    
                    ZStack {
                        if selectedTab == .dday {
                            DDayListView()
                                .transition(.move(edge: .trailing))
                        } else if selectedTab == .settings {
                            SettingsView()
                                .transition(.move(edge: .leading))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .animation(nil, value: selectedTab)
                }
                .navigationTitle("새벽:D")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = .clear
                    appearance.shadowColor = .clear
                    appearance.titleTextAttributes = [
                        .foregroundColor: UIColor.white,
                        .font: UIFont(name: "NIXGONM-Vb", size: 24)!
                    ]
                    appearance.largeTitleTextAttributes = [
                        .foregroundColor: UIColor.white,
                        .font: UIFont(name: "NIXGONM-Vb", size: 36)!
                    ]
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
            }
            // 디데이 추가 버튼
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == .dday {
                        NavigationLink(destination: AddDDayView()) {
                            Text("디데이 추가")
                                .font(.custom("NIXGONM-Vb", size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
