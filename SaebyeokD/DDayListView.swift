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
            }
        }
    }
}
