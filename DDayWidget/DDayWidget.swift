//
//  DDayWidget.swift
//  DDayWidget
//
//  Created by Saebyeok Jang on 2/14/25.
//

import WidgetKit
import SwiftUI

// 1. 앱과 위젯에서 공유할 데이터 모델: 목표날짜(targetDate) 추가
struct DDayEventData: Codable, Identifiable {
    let id: String
    let title: String
    let dDayText: String
    let targetDate: Date  // 목표날짜

    enum CodingKeys: String, CodingKey {
        case id, title, dDayText, targetDate
    }

    init(id: UUID, title: String, dDayText: String, targetDate: Date) {
        self.id = id.uuidString
        self.title = title
        self.dDayText = dDayText
        self.targetDate = targetDate
    }

    // 커스텀 디코딩: id를 문자열로 디코딩 후, UUID로 변환하며, targetDate가 없으면 기본값(Date()) 사용
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

    // 인코딩 시 id를 문자열로 저장
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dDayText, forKey: .dDayText)
        try container.encode(targetDate, forKey: .targetDate)
    }
}

// 2. 위젯 타임라인 엔트리: 여러 이벤트를 배열로 구성
struct DDayEntry: TimelineEntry {
    let date: Date
    let events: [DDayEventData]
}

// 3. Shared 데이터 로딩 함수 (App Group 사용)
// "ddayList" 키에 저장된 JSON 데이터를 디코딩하여 이벤트 배열 반환
func loadSharedDDayEvents() -> [DDayEventData] {
    guard let defaults = UserDefaults(suiteName: "group.com.SaebyeokD"),
          let data = defaults.data(forKey: "ddayList") else {
        // 데이터가 없으면 더미 데이터를 반환
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

// 4. 타임라인 제공자
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DDayEntry {
        DDayEntry(date: Date(), events: [
            DDayEventData(id: UUID(), title: "Event 1", dDayText: "D-5", targetDate: Date()),
            DDayEventData(id: UUID(), title: "Event 2", dDayText: "D-10", targetDate: Date()),
            DDayEventData(id: UUID(), title: "Event 3", dDayText: "D-15", targetDate: Date())
        ])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DDayEntry) -> Void) {
        let entry = DDayEntry(date: Date(), events: [
            DDayEventData(id: UUID(), title: "Event 1", dDayText: "D-5", targetDate: Date()),
            DDayEventData(id: UUID(), title: "Event 2", dDayText: "D-10", targetDate: Date()),
            DDayEventData(id: UUID(), title: "Event 3", dDayText: "D-15", targetDate: Date())
        ])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DDayEntry>) -> Void) {
        let events = loadSharedDDayEvents()
        let currentDate = Date()
        let entry = DDayEntry(date: currentDate, events: events)
        // 15분 후 업데이트 (필요에 따라 조정)
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

// 5. 위젯 뷰: 위젯 크기에 따라 다른 레이아웃으로 표시
struct DDayWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    // 목표날짜를 "yyyy.MM.dd" 형식으로 변환하는 함수
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
                // Small: 첫번째 이벤트를 수직 레이아웃으로 표시
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
                // Medium: 각 행을 목록 형식으로 표시하고, 왼쪽에 제목 및 목표날짜, 오른쪽에 디데이 텍스트
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
                // Fallback: medium과 동일하게 처리
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

// 6. 위젯 메인 구조체
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

// 7. 미리보기 코드
#Preview(as: .systemSmall, widget: { DDayWidget() }, timelineProvider: { Provider() })
