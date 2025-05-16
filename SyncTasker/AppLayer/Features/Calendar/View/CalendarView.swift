//
//  CalendarView.swift
//  SyncTasker
//
//  Created by ingvar on 16.02.2025.
//

import SwiftUI

struct CalendarView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: CalendarViewModel

    // MARK: - Initialization
    
    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            switch viewModel.calendarViewType {
            case .month:
                WeekView(
                    weekIndex: viewModel.weekIndex,
                    weeks: viewModel.weeksInYear,
                    onTaskDropped: { task, date in
                        viewModel.updateTaskDate(task: task, to: date)
                    }, routeToDailySchedule: { dayItem in
                        viewModel.navigateToDailySchedule(dayItem)
                    }
                )

            case .year:
                YearView(year: viewModel.monthsInYear, statistics: viewModel.statistics) { monthItem in
                    viewModel.didTapMonth(with: monthItem)
                }
            }
//            Spacer().frame(height: 300)
//            floatingButtons
        }
    }
    
    // MARK: - Subviews
            
    private var floatingButtons: some View {
        HStack {
            Button(action: { viewModel.navigateToFreeTime() }) {
                Text("Free Time")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.all, 8)
                    .background(Theme.Colors.accent)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            Button(action: {  }) {
                Text("Backlog")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.all, 8)
                    .background(Theme.Colors.accent)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            Spacer()
            Button(action: { viewModel.navigateToTaskDetail(nil) }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Theme.Colors.accent))
                    .shadow(radius: 4)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
    }
}

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: DIContainer.shared)
    }
}
#endif
