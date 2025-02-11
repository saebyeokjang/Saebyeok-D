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
                    .listRowBackground(Color.clear) // 리스트 행 배경 투명
            }
        }
        .scrollContentBackground(.hidden) // 기본 배경 제거
        .background(Color.clear) // 전체 뷰 배경 투명
    }
}
