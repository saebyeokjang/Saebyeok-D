//
//  DDayWidget.swift
//  DDayWidget
//
//  Created by Saebyeok Jang on 2/14/25.
//

import WidgetKit
import SwiftUI

struct DDayEventData: Codable, Identifiable {
    let id: String
    let title: String
    let dDayText: String
    let targetDate: Date

    enum CodingKeys: String, CodingKey {
        case id, title, dDayText, targetDate
    }

    init(id: UUID, title: String, dDayText: String, targetDate: Date) {
        self.id = id.uuidString
        self.title = title
        self.dDayText = dDayText
        self.targetDate = targetDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        if let uuid = UUID(uuidString: idString) {
            self.id = uuid.uuidString
        } else {
            self.id = UUID().uuidString
        }
        self.title = try container.decode(String.self, forKey: .title)
        self.dDayText = try container.decode(String.self, forKey: .dDayText)
        self.targetDate = try container.decodeIfPresent(Date.self, forKey: .targetDate) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dDayText, forKey: .dDayText)
        try container.encode(targetDate, forKey: .targetDate)
    }
}

struct DDayEntry: TimelineEntry {
    let date: Date
    let events: [DDayEventData]
}

func loadSharedDDayEvents() -> [DDayEventData] {
    guard let defaults = UserDefaults(suiteName: "group.com.SaebyeokD"),
          let data = defaults.data(forKey: "ddayList") else {
        // 데이터가 없으면 더미 데이터
        return [
            DDayEventData(id: UUID(), title: "Event 1", dDayText: "D-5", targetDate: Date()),
            DDayEventData(id: UUID(), title: "Event 2", dDayText: "D-10", targetDate: Date()),
            DDayEventData(id: UUID(), title: "Event 3", dDayText: "D-15", targetDate: Date())
        ]
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
        DDayEntry(date: Date(), events: [
            DDayEventData(id: UUID(), title: "Event 1", dDayText: "D-5", targetDate: Date()),
            DDayEventData(id: UUID(), title: "Event 2", dDayText: "D-10", targetDate: Date()),
            DDayEventData(id: UUID(), title: "Event 3", dDayText: "D-15", targetDate: Date())
        ])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DDayEntry) -> Void) {
            let entry = DDayEntry(date: Date(), events: loadSharedDDayEvents())
            completion(entry)
        }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DDayEntry>) -> Void) {
        let events = loadSharedDDayEvents()
        let currentDate = Date()
        
        var entries: [DDayEntry] = []
        let calendar = Calendar.current
        
        let startOfToday = calendar.startOfDay(for: currentDate)
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        
        let currentEntry = DDayEntry(date: currentDate, events: events)
        entries.append(currentEntry)
        
        let midnightEvents = events.map { event -> DDayEventData in
            let startOfTarget = calendar.startOfDay(for: event.targetDate)
            let diff = calendar.dateComponents([.day], from: nextMidnight, to: startOfTarget).day ?? 0
            
            let newDDayText: String
            switch diff {
            case 0:
                newDDayText = "오늘"
            case 1...:
                newDDayText = "D-\(diff)"
            default:
                newDDayText = "\(-diff + 1)일"
            }
            
            return DDayEventData(
                id: UUID(uuidString: event.id) ?? UUID(),
                title: event.title,
                dDayText: newDDayText,
                targetDate: event.targetDate
            )
        }
        
        let midnightEntry = DDayEntry(date: nextMidnight, events: midnightEvents)
        entries.append(midnightEntry)

        let dayAfterTomorrowMidnight = calendar.date(byAdding: .day, value: 2, to: startOfToday)!
        let dayAfterTomorrowEvents = events.map { event -> DDayEventData in
            let startOfTarget = calendar.startOfDay(for: event.targetDate)
            let diff = calendar.dateComponents([.day], from: dayAfterTomorrowMidnight, to: startOfTarget).day ?? 0
            
            let newDDayText: String
            switch diff {
            case 0:
                newDDayText = "오늘"
            case 1...:
                newDDayText = "D-\(diff)"
            default:
                newDDayText = "\(-diff + 1)일"
            }
            
            return DDayEventData(
                id: UUID(uuidString: event.id) ?? UUID(),
                title: event.title,
                dDayText: newDDayText,
                targetDate: event.targetDate
            )
        }
        
        let dayAfterTomorrowEntry = DDayEntry(date: dayAfterTomorrowMidnight, events: dayAfterTomorrowEvents)
        entries.append(dayAfterTomorrowEntry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        
        completion(timeline)
    }
}

struct DDayWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    func formattedTargetDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Image("NightSkyW")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            switch widgetFamily {
            case .systemSmall:
                // Small
                VStack(spacing: 4) {
                    if let firstEvent = entry.events.first {
                        Spacer()
                        Text(firstEvent.title)
                            .font(.custom("NIXGONM-Vb", size: 22))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Spacer()
                        Text(firstEvent.dDayText)
                            .font(.custom("NIXGONM-Vb", size: 30))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Text(formattedTargetDate(firstEvent.targetDate))
                            .font(.custom("NIXGONM-Vb", size: 12))
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
                // Medium
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(entry.events.prefix(3).enumerated()), id: \.offset) { index, event in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title)
                                    .font(.custom("NIXGONM-Vb", size: 18))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text(formattedTargetDate(event.targetDate))
                                    .font(.custom("NIXGONL-Vb", size: 10))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(event.dDayText)
                                .font(.custom("NIXGONM-Vb", size: 24))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 6)
                        // 마지막 행이 아니라면 Divider 추가
                        if index < entry.events.prefix(3).count - 1 {
                            Divider()
                                .background(Color.white)
                        }
                    }
                }
                .padding()
            default:
                // Fallback: medium과 동일
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(entry.events.prefix(3).enumerated()), id: \.offset) { index, event in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title)
                                    .font(.custom("NIXGONL-Vb", size: 16))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text(formattedTargetDate(event.targetDate))
                                    .font(.custom("NIXGONM-Vb", size: 12))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(event.dDayText)
                                .font(.custom("NIXGONM-Vb", size: 16))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 2)
                        if index < entry.events.prefix(3).count - 1 {
                            Divider()
                                .background(Color.white)
                        }
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
        .description("앱의 디데이 이벤트 목록과 목표날짜를 확인할 수 있습니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall, widget: { DDayWidget() }, timelineProvider: { Provider() })
