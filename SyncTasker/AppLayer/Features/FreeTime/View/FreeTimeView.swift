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
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.freeTimeDaysInYear, id: \.self) { month in
                    MonthFreeTimeItem(month: month)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

#if DEBUG
struct FreeTimeView_Previews: PreviewProvider {
    static var previews: some View {
        let initialRouteForFreeTime = Route.freeTime([[]])
        let previewContainer = DIContainer(initialRoute: initialRouteForFreeTime)
        RootView(container: previewContainer)
    }
}
#endif
