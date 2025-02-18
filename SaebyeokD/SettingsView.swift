//
//  SettingsView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 디데이 설정 섹션 (미구현...)
            VStack(alignment: .leading, spacing: 8) {
                Text("디데이 설정")
                    .font(.custom("NIXGONB-Vb", size: 14))
                    .foregroundColor(.white)
                Toggle(isOn: $notificationsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("지나간 디데이 숨기기")
                            .font(.custom("NIXGONM-Vb", size: 18))
                            .foregroundColor(.white)
                        Text("날짜가 지나간 디데이를 삭제합니다")
                            .font(.custom("NIXGONL-Vb", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                }
                .toggleStyle(SwitchToggleStyle(tint: .yellow))
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
                .padding(.horizontal, 16)
            
            // 알림 설정 섹션
            VStack(alignment: .leading, spacing: 8) {
                Text("알림 설정")
                    .font(.custom("NIXGONB-Vb", size: 14))
                    .foregroundColor(.white)
                Toggle(isOn: $notificationsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("디데이 알림")
                            .font(.custom("NIXGONM-Vb", size: 18))
                            .foregroundColor(.white)
                        Text("디데이의 알림 기능을 사용합니다")
                            .font(.custom("NIXGONL-Vb", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                }
                .toggleStyle(SwitchToggleStyle(tint: .yellow))
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
                .padding(.horizontal, 16)
            
            // 기타 설정 섹션
            VStack(alignment: .leading, spacing: 8) {
                Text("기타 설정")
                    .font(.custom("NIXGONB-Vb", size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 4) {
                    Text("준비중")
                        .font(.custom("NIXGONM-Vb", size: 18))
                        .foregroundColor(.white)
                    Text("추가 설정 준비중입니다")
                        .font(.custom("NIXGONL-Vb", size: 14))
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .scrollContentBackground(.hidden)
        .background(Color.black.opacity(0.3))
    }
}

#Preview {
    SettingsView()
}
