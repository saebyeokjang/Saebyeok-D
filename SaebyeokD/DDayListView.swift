//
//  DDayListView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

struct DDayListView: View {
    @Query(sort: \DDayEvent.targetDate, order: .forward) var events: [DDayEvent]

    var body: some View {
        List {
            ForEach(events) { event in
                DDayRowView(event: event)
                    // 셀의 기본 여백을 줄임
                    .listRowInsets(EdgeInsets(top: 3, leading: 1, bottom: 3, trailing: 1))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())      // Plain 스타일 사용
        .scrollContentBackground(.hidden)  // 기본 배경 제거
        .background(Color.clear)           // 전체 뷰 배경 투명
    }
}
