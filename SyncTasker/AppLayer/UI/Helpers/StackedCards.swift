//
//  StackedCards.swift
//  SyncTasker
//
//  Created by ingvar on 03.03.2025.
//
// Модуль предоставляет кастомный UI-компонент для отображения карточек в виде стека.
// Основные возможности:
// - Анимированное масштабирование карточек при скролле
// - Динамическое изменение прозрачности
// - Отслеживание изменения месяца при прокрутке
// - Поддержка кастомного контента через generic parameter

import SwiftUI

@MainActor
struct StackedCards<Content: View>: View {
    
    // MARK: - Initial Private Properties

    private var items: [DayItem]
    @Binding private var currentMonth: Date
    private var itemHeight: CGFloat
    @ViewBuilder private var content: (DayItem) -> Content
    
    // MARK: - Private Properties

    private var stackedDisplayCount: Int = 3
    private var opacityDisplayCount: Int = 2
    private var disablesOpacityEffect: Bool = false
    
    // MARK: - Initialization

    init(
        items: [DayItem],
        currentMonth: Binding<Date>,
        itemHeight: CGFloat,
        @ViewBuilder content: @escaping (DayItem) -> Content
    ) {
        self.items = items
        self._currentMonth = currentMonth
        self.itemHeight = itemHeight
        self.content = content
    }
    
    // MARK: - Body

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        GeometryReader { itemProxy in
                            content(item)
                                .frame(height: itemHeight)
                                .visualEffect { content, geometryProxy in
                                    content
                                        .opacity(disablesOpacityEffect ? 1 : calculateOpacity(geometryProxy))
                                        .scaleEffect(calculateScale(geometryProxy))
                                        .offset(y: calculateOffset(geometryProxy))
                                }
                                .zIndex(-zIndex(item))
                                .id(item.id)
                                .onChange(of: itemProxy.frame(in: .scrollView).minY) { oldValue, newValue in
                                    // Отслеживаем только разделители
                                    if item.date == nil {
                                        let isOldVisible = oldValue >= 0 && oldValue <= UIScreen.main.bounds.height
                                        let isNewVisible = newValue >= 0 && newValue <= UIScreen.main.bounds.height
                                        
                                        // Когда разделитель исчезает
                                        if isOldVisible && !isNewVisible {
                                            // Если скролл вверх
                                            if newValue < 0 {
                                                if let nextDate = getNextDate(for: item, in: items) {
                                                    self.currentMonth = nextDate
                                                }
                                            } else if let prevDate = getPreviousDate(for: item, in: items) {
                                                // Если скролл вниз
                                                self.currentMonth = prevDate
                                            }
                                        }
                                    }
                                }
                        }
                        .frame(height: itemHeight)
                    }
                }
                .padding(.top, itemHeight * CGFloat(stackedDisplayCount))
            }
            .onFirstAppear {
                if let currentIndex = items.firstIndex(where: {
                    guard let date = $0.date else { return false }
                    return Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .day)
                }) {
                    scrollProxy.scrollTo(items[currentIndex].id, anchor: .top)
                }
            }
        }
    }
    
    // MARK: - Private Methods

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
    
    private func getNextDate(for item: DayItem, in items: [DayItem]) -> Date? {
        if let index = items.firstIndex(where: { $0.id == item.id }),
           index < items.count - 1,
           let date = items[index + 1].date {
            return date
        }
        return nil
    }
    
    private func getPreviousDate(for item: DayItem, in items: [DayItem]) -> Date? {
        if let index = items.firstIndex(where: { $0.id == item.id }),
           index > 0,
           let date = items[index - 1].date {
            return date
        }
        return nil
    }
    
    private func zIndex(_ item: DayItem) -> Double {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            return Double(items.count - index)
        }
        return 0
    }
}
