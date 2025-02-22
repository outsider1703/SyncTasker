//
//  CalendarView.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let navigationTitle = "Calendar"
    static let taskListButtonTitle = "Open Task List"
    static let taskListIcon = "list.bullet"
    static let columns = 1
    static let monthsToLoad = 100
    static let monthTitleScale: CGFloat = 1.2
    static let monthTitleOffset: CGFloat = -30
    static let titleAnimationDuration: Double = 0.3
}

struct CalendarView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: CalendarViewModel
    
    // MARK: - Properties
    
    private let calendar = Calendar.current
    @State private var selectedDate = Date()
    @State private var viewType: CalendarViewType = .month
    @State private var isTitleAnimating = false
    @State private var drawerOffset: CGFloat = DrawerPosition.closed.offset
    @State private var drawerPosition: DrawerPosition = .closed
    @State private var isDragging = false
    
    // MARK: - Initialization
    
    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    switch viewType {
                    case .month:
                        HStack(spacing: 0) {
                            MonthView(date: selectedDate, selectedDate: $selectedDate)
                                .frame(width: 182)
                                .ignoresSafeArea()
                            
                            VStack(alignment: .leading) {
                                Text(monthTitle)
                                    .font(Theme.Typography.headlineFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .scaleEffect(isTitleAnimating ? Constants.monthTitleScale : 1.0)
                                    .opacity(isTitleAnimating ? 0.5 : 1.0)
                                    .animation(.easeInOut(duration: Constants.titleAnimationDuration), value: isTitleAnimating)
                                    .onTapGesture { switchToYearView() }
                                TaskStatisticsView(statistics: viewModel.statistics)

                                Spacer()
                            }
                            //.frame(width: geometry.size.width - 182)
                        }
                        
                    case .year:
                        YearView(selectedDate: $selectedDate, onMonthSelected: switchToMonthView)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            if viewType == .month {
                DrawerView(
                    offset: $drawerOffset,
                    position: $drawerPosition,
                    taskSections: viewModel.taskSections
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private var monthTitle: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = viewType == .month ? "MMMM yyyy" : "yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    private func switchToYearView() {
        withAnimation {
            isTitleAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                viewType = .year
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                    isTitleAnimating = false
                }
            }
        }
    }
    
    private func switchToMonthView(with date: Date) {
        withAnimation {
            isTitleAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                selectedDate = date
                viewType = .month
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.titleAnimationDuration/2) {
                    isTitleAnimating = false
                }
            }
        }
    }
}
