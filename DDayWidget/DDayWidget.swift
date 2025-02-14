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
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack {
            // 배경: 원하는 배경으로 설정하세요.
            Image("NightSkyW")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            switch widgetFamily {
            case .systemSmall:
                // 스몰 사이즈
                VStack(spacing: 8) {
                    if let firstEvent = entry.events.first {
                        Spacer()
                        Text(firstEvent.title)
                            .font(.custom("NIXGONL-Vb", size: 24))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Text(firstEvent.dDayText)
                            .font(.custom("NIXGONM-Vb", size: 32))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                    } else {
                        Text("디데이 정보가 없습니다.")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding()
            case .systemMedium:
                // 미디엄 사이즈
                HStack {
                    if let firstEvent = entry.events.first {
                        Spacer()
                        Text(firstEvent.title)
                            .font(.custom("NIXGONL-Vb", size: 24))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Text(firstEvent.dDayText)
                            .font(.custom("NIXGONM-Vb", size: 32))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                    } else {
                        Text("디데이 정보가 없습니다.")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding()
            default:
                // 다른 크기
                HStack {
                    if let firstEvent = entry.events.first {
                        Text(firstEvent.title)
                            .font(.custom("NIXGONL-Vb", size: 24))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Text(firstEvent.dDayText)
                            .font(.custom("NIXGONM-Vb", size: 32))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    } else {
                        Text("디데이 정보가 없습니다.")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
        .containerBackground(for: .widget) {
            Image("NightSkyW")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
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
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall, widget: { DDayWidget() }, timelineProvider: { Provider() })
