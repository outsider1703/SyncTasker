//
//  StackedCards.swift
//  SyncTasker
//
//  Created by ingvar on 03.03.2025.
//

import SwiftUI

@MainActor
struct StackedCards<Content: View>: View {
    var items: [DayItem]
    var selectedDate: Date
    var stackedDisplayCount: Int
    var opacityDisplayCount: Int
    var disablesOpacityEffect: Bool
    var itemHeight: CGFloat
    var onMonthChanged: (Date) -> Void
    @ViewBuilder var content: (DayItem) -> Content
    
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
                                        .opacity(disablesOpacityEffect == true ? 1 : calculateOpacity(geometryProxy))
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
                                                    onMonthChanged(nextDate)
                                                }
                                            }
                                            // Если скролл вниз
                                            else if let prevDate = getPreviousDate(for: item, in: items) {
                                                onMonthChanged(prevDate)
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
            .onAppear {
                if let currentIndex = items.firstIndex(where: {
                    guard let date = $0.date else { return false }
                    return Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .day)
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
