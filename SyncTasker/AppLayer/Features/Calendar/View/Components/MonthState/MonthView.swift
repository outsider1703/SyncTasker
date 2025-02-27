//
//  MonthView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthView: View {
    
    // MARK: - Private Properties
    
    private let stackAreaHeight: CGFloat = 200
    @State private var stickyCards: Set<Int> = []

    private var dailyTasks: [Date: [TaskItem]]
    private let calendar = Calendar.current
    private let date: Date
    private let onTaskDropped: (UUID, Date) -> Void
    private let routeToDailySchedule: (Date, [TaskItem]) -> Void
    
    // MARK: - Initialization
    
    init(
        date: Date,
        selectedDate: Binding<Date>,
        dailyTasks: [Date: [TaskItem]],
        onTaskDropped: @escaping (UUID, Date) -> Void,
        routeToDailySchedule: @escaping (Date, [TaskItem]) -> Void
    ) {
        self.date = date
        self.onTaskDropped = onTaskDropped
        self.dailyTasks = dailyTasks
        self.routeToDailySchedule = routeToDailySchedule
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            StackedCards(
                items: getDaysInMonth(),
                stackedDisplayCount: 3,
                opacityDisplayCount: 2,
                itemHeight: 150
            ) { dayItem in
                if let date = dayItem.date {
                    DayView(
                        date: date,
                        tasks: getTasksForDate(date),
                        onTap: { routeToDailySchedule(date, getTasksForDate(date)) },
                        onTaskDropped: onTaskDropped
                    )
                } else {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 150)
                }
            }
        }
    }
    
    // MARK: - Private Methods

    private func getTasksForDate(_ date: Date) -> [TaskItem] {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let normalizedDate = calendar.date(from: components) else { return [] }
        return dailyTasks[normalizedDate] ?? []
    }

    private func getDaysInMonth() -> [DayItem] {
        let interval = calendar.dateInterval(of: .month, for: date)!
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        var days: [DayItem] = []
        for i in 0..<(firstWeekday - 1) {
            days.append(DayItem(id: i, date: nil))
        }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(DayItem(id: day + firstWeekday - 1, date: date))
            }
        }
        return days
    }
}

struct StackedCards<Content: View, Data: RandomAccessCollection>: View where Data.Element: Identifiable {
    var items: Data
    var stackedDisplayCount: Int = 2
    var opacityDisplayCount: Int = 2
    var disablesOpacityEffect: Bool = false
    var spacing: CGFloat = 5
    var itemHeight: CGFloat
    @ViewBuilder var content: (Data.Element) -> Content
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let topPadding: CGFloat = size.height - itemHeight
            
            ScrollView(.vertical) {
                VStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                            .scaleEffect(x: 1, y: -1)
                            .frame(height: itemHeight)
                            .visualEffect { content, geometryProxy in
                                content
                                    .opacity(disablesOpacityEffect ? 1 : opacity(geometryProxy))
                                    .scaleEffect(scale(geometryProxy), anchor: .bottom)
                                    .offset(y: offset(geometryProxy))
                            }
                            .zIndex(zIndex(item))
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .safeAreaPadding(.top, topPadding)
        }
        .scaleEffect(x: 1, y: -1)
    }
    
    // Add stack effect calculation methods
    func zIndex(_ item: Data.Element) -> Double {
        if let index = items.firstIndex(where: { $0.id == item.id }) as? Int {
            return Double(items.count) - Double(index)
        }
        return 0
    }
    
    func offset(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        let progress = minY / itemHeight
        let maxOffset = CGFloat(stackedDisplayCount) * offsetForEachItem
        let offset = max(min(progress * offsetForEachItem, maxOffset), 0)
        
        return minY < 0 ? 0 : -minY + offset
    }
    
    func scale(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        let progress = minY / itemHeight
        let maxScale = CGFloat(stackedDisplayCount) * scaleForEachItem
        let scale = max(min(progress * scaleForEachItem, maxScale), 0)
        
        return 1 - scale
    }
    
    func opacity(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        let progress = minY / itemHeight
        let opacityForItem = 1 / CGFloat(opacityDisplayCount + 1)
        
        let maxOpacity = CGFloat(opacityForItem) * CGFloat(opacityDisplayCount + 1)
        let opacity = max(min(progress * opacityForItem, maxOpacity), 0)
        
        return progress < CGFloat(opacityDisplayCount + 1) ? 1 - opacity : 0
    }
    
    var offsetForEachItem: CGFloat { 8 }
    var scaleForEachItem: CGFloat { 0.08 }
}
