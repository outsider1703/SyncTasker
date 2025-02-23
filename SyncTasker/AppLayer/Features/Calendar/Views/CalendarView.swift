//
//  CalendarView.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import SwiftUI

// MARK: - Constants

private enum Constants {
    static let monthTitleScale: CGFloat = 1.2
    static let titleAnimationDuration: Double = 0.3
}

struct CalendarView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: CalendarViewModel
    
    // MARK: - Private Properties
    
    @State private var selectedDate = Date()
    @State private var viewType: CalendarViewType = .month
    @State private var isTitleAnimating = false
    @State private var drawerOffset: CGFloat = DrawerPosition.closed.offset
    @State private var drawerPosition: DrawerPosition = .closed
    
    // MARK: - Initialization
    
    init(
        viewModel: CalendarViewModel
    ) {
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
                    selectedSortOption: $viewModel.selectedSortOption,
                    selectedFilter: $viewModel.selectedFilter,
                    errorMessage: $viewModel.errorMessage,
                    taskSections: viewModel.taskSections
                )
            }
        }
    }
    
    // MARK: - Subviews
    
    private var monthTitle: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = viewType == .month ? "MMMM yyyy" : "yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    // MARK: - Private Methods
    
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
