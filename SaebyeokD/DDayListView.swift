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
                    .listRowInsets(EdgeInsets(top: 3, leading: 1, bottom: 3, trailing: 1))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}
