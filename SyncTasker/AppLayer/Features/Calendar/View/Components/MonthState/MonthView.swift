//
//  MonthView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct MonthView: View {
    
    // MARK: - Private Properties
    
    @State private var days: [DayItem] = []
    @State private var months: [Date] = []
    private let monthsToLoad = 12
    
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
            if !days.isEmpty {
                StackedCards(
                    items: days,
                    stackedDisplayCount: 3,
                    opacityDisplayCount: 2,
                    disablesOpacityEffect: false,
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
        .onAppear {
            generateMonths()
            days = getAllMonthsDays()
        }
    }
    
    // MARK: - Private Methods
    
    private func getTasksForDate(_ date: Date) -> [TaskItem] {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let normalizedDate = calendar.date(from: components) else { return [] }
        return dailyTasks[normalizedDate] ?? []
    }
    
    private func generateMonths() {
        let currentDate = date
        months = (-monthsToLoad...monthsToLoad).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: currentDate)
        }
    }
    
    private func getAllMonthsDays() -> [DayItem] {
        guard let firstMonth = months.first, let lastMonth = months.last,
              let startDate = calendar.dateInterval(of: .month, for: firstMonth)?.start,
              let endDate = calendar.dateInterval(of: .month, for: lastMonth)?.end else { return [] }
        
        // Создаем компоненты для всего периода сразу
        var currentDate = startDate
        var idCounter = 0
        var allDays = [DayItem]()
        
        while currentDate < endDate {
            // Проверяем, это первый день месяца или нет
            if calendar.component(.day, from: currentDate) == 1 && currentDate != startDate {
                // Добавляем разделитель между месяцами
                allDays.append(DayItem(id: idCounter, date: nil))
                idCounter += 1
            }
            
            allDays.append(DayItem(id: idCounter, date: currentDate))
            idCounter += 1
            
            // Переходим к следующему дню
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return allDays
    }
}

@MainActor
struct StackedCards<Content: View>: View {
    var items: [DayItem]
    var stackedDisplayCount: Int
    var opacityDisplayCount: Int
    var disablesOpacityEffect: Bool
    var itemHeight: CGFloat
    @ViewBuilder var content: (DayItem) -> Content
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        content(item)
                            .frame(height: itemHeight)
                            .visualEffect { content, proxy in
                                content
                                    .opacity(disablesOpacityEffect == true ? 1 : calculateOpacity(proxy))
                                    .scaleEffect(calculateScale(proxy))
                                    .offset(y: calculateOffset(proxy))
                            }
                            .zIndex(-zIndex(item))
                            .id(item.id)
                    }
                }
                .padding(.top, itemHeight * CGFloat(stackedDisplayCount))
            }
            .onAppear {
                if let currentIndex = items.firstIndex(where: {
                    guard let date = $0.date else { return false }
                    return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day)
                }) {
                    scrollProxy.scrollTo(items[currentIndex].id, anchor: .top)
                }
            }
        }
    }
    
    private nonisolated func calculateOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        guard minY < 0 else { return 0 }
        
        return min(-minY, itemHeight * CGFloat(stackedDisplayCount))
    }
    
    private nonisolated func calculateScale(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        guard minY < 0 else { return 1 }
        
        let progress = min(-minY / itemHeight, CGFloat(stackedDisplayCount))
        return 1 - (progress * 0.08)
    }
    
    private nonisolated func calculateOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        guard minY < 0 else { return 1 }
        
        let progress = min(-minY / itemHeight, CGFloat(opacityDisplayCount))
        return 1 - (progress * 0.3)
    }
    
    private func zIndex(_ item: DayItem) -> Double {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            return Double(items.count - index)
        }
        return 0
    }
}
