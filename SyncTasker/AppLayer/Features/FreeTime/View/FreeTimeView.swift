//
//  FreeTimeView.swift
//  SyncTasker
//
//  Created by ingvar on 04.04.2025.
//

import SwiftUI

struct FreeTimeView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: FreeTimeViewModel
    
    // MARK: - Initialization
    
    init(
        viewModel: FreeTimeViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.months, id: \.self) { month in
                        MonthFreeTimeItem(month: month) { dayItem in
                            viewModel.navigateToDailySchedule(dayItem)
                        }
                        .id(month.id)
                    }
                }
                .padding(.horizontal, 4)
                .onAppear() {
                    let currentMonthId = viewModel.months.first(where: { $0.isCurrentMonth })?.id
                    value.scrollTo(currentMonthId)
                }
            }
        }
    }
}

#if DEBUG
struct FreeTimeView_Previews: PreviewProvider {
    static var previews: some View {
        let initialRouteForFreeTime = Route.freeTime([])
        let previewContainer = DIContainer(initialRoute: initialRouteForFreeTime)
        RootView(container: previewContainer)
    }
}
#endif
