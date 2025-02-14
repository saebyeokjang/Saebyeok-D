//
//  DDayWidget.swift
//  DDayWidget
//
//  Created by Saebyeok Jang on 2/14/25.
//

import WidgetKit
import SwiftUI

struct DDayEventData: Codable, Identifiable {
    let id: UUID
    let title: String
    let dDayText: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, dDayText
    }
    
    init(id: UUID, title: String, dDayText: String) {
        self.id = id
        self.title = title
        self.dDayText = dDayText
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        if let uuid = UUID(uuidString: idString) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        self.title = try container.decode(String.self, forKey: .title)
        self.dDayText = try container.decode(String.self, forKey: .dDayText)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dDayText, forKey: .dDayText)
    }
}

struct DDayEntry: TimelineEntry {
    let date: Date
    let events: [DDayEventData]
}

func loadSharedDDayEvents() -> [DDayEventData] {
    guard let defaults = UserDefaults(suiteName: "group.com.SaebyeokD"),
          let data = defaults.data(forKey: "ddayList") else {
        // 더미
        return [DDayEventData(id: UUID(), title: "생일", dDayText: "D-5")]
    }
    
    do {
        let events = try JSONDecoder().decode([DDayEventData].self, from: data)
        return events
    } catch {
        print("디코딩 에러: \(error)")
        return []
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DDayEntry {
        DDayEntry(date: Date(), events: [DDayEventData(id: UUID(), title: "예시 이벤트", dDayText: "D-10")])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DDayEntry) -> Void) {
        let entry = DDayEntry(date: Date(), events: loadSharedDDayEvents())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DDayEntry>) -> Void) {
        let events = loadSharedDDayEvents()
        let currentDate = Date()
        let entry = DDayEntry(date: currentDate, events: events)
        
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct DDayWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("WidgetGradientStart"), Color("WidgetGradientEnd")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 4) {
                if let firstEvent = entry.events.first {
                    HStack {
                        Text(firstEvent.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Text(firstEvent.dDayText)
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                } else {
                    Text("디데이 정보가 없습니다.")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)
            .padding()
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

@main
struct DDayWidget: Widget {
    let kind: String = "DDayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("디데이 위젯")
        .description("앱의 디데이 이벤트 목록을 확인할 수 있습니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium, widget: { DDayWidget() }, timelineProvider: { Provider() })
