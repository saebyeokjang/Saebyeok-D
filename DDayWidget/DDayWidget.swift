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
        return []
    }
    
    do {
        let events = try JSONDecoder().decode([DDayEventData].self, from: data)
        return events
    } catch {
        print("디코딩 에러: \(error)")
        return []
    }
}

// D-day 텍스트를 새로 계산하는 함수
func calculateDDayText(targetDate: Date, from currentDate: Date) -> String {
    let calendar = Calendar.current
    let startOfToday = calendar.startOfDay(for: currentDate)
    let startOfTarget = calendar.startOfDay(for: targetDate)
    let diff = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget).day ?? 0
    
    switch diff {
    case 0:
        return "오늘"
    case 1...:
        return "D-\(diff)"
    default:
        return "\(-diff + 1)일"
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DDayEntry {
        // 플레이스홀더 데이터가 비어있는 경우 기본 더미 데이터 제공
        let dummyEvents = [
            DDayEventData(id: UUID(), title: "이벤트", dDayText: "D-5", targetDate: Date())
        ]
        return DDayEntry(date: Date(), events: dummyEvents)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DDayEntry) -> Void) {
        // 스냅샷용 데이터 로드
        var events = loadSharedDDayEvents()
        if events.isEmpty && !context.isPreview {
            // 실제 환경에서만 더미 데이터 사용 (미리보기에서는 빈 상태 보여주기)
            events = [
                DDayEventData(id: UUID(), title: "이벤트", dDayText: "D-5", targetDate: Date())
            ]
        }
        let entry = DDayEntry(date: Date(), events: events)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DDayEntry>) -> Void) {
        let events = loadSharedDDayEvents()
        let currentDate = Date()
        
        var entries: [DDayEntry] = []
        let calendar = Calendar.current
        
        // 오늘 자정 계산
        let startOfToday = calendar.startOfDay(for: currentDate)
        
        // 현재 시간 기준 엔트리 추가
        let currentEvents = events.map { event in
            // D-day 텍스트를 현재 시간 기준으로 다시 계산
            let newDDayText = calculateDDayText(targetDate: event.targetDate, from: currentDate)
            
            return DDayEventData(
                id: UUID(uuidString: event.id) ?? UUID(),
                title: event.title,
                dDayText: newDDayText,
                targetDate: event.targetDate
            )
        }
        let currentEntry = DDayEntry(date: currentDate, events: currentEvents)
        entries.append(currentEntry)
        
        // 다음 자정에 업데이트할 엔트리 추가
        if let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) {
            let midnightEvents = events.map { event in
                let newDDayText = calculateDDayText(targetDate: event.targetDate, from: nextMidnight)
                
                return DDayEventData(
                    id: UUID(uuidString: event.id) ?? UUID(),
                    title: event.title,
                    dDayText: newDDayText,
                    targetDate: event.targetDate
                )
            }
            let midnightEntry = DDayEntry(date: nextMidnight, events: midnightEvents)
            entries.append(midnightEntry)
        }
        
        // 다음 시간 업데이트 엔트리 추가 (1시간마다 업데이트)
        if let nextHour = calendar.date(byAdding: .hour, value: 1, to: currentDate) {
            let hourlyEvents = events.map { event in
                let newDDayText = calculateDDayText(targetDate: event.targetDate, from: nextHour)
                
                return DDayEventData(
                    id: UUID(uuidString: event.id) ?? UUID(),
                    title: event.title,
                    dDayText: newDDayText,
                    targetDate: event.targetDate
                )
            }
            let hourlyEntry = DDayEntry(date: nextHour, events: hourlyEvents)
            entries.append(hourlyEntry)
        }
        
        // 다음 업데이트 정책 설정
        let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: currentDate) ?? Date()
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        
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
