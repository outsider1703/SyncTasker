//
//  DailySleepView.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import SwiftUI

struct DailySleepView: View {
    
    // MARK: - Initial Private Properties
    
    private let dailySleep: DailyTask
    private let onTap: () -> Void
    
    // MARK: - Initialization
    
    init(
        dailySleep: DailyTask,
        onTap: @escaping () -> Void
    ) {
        self.dailySleep = dailySleep
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        Spacer()
            .frame(height: dailySleep.height)
            .background(Color.accentColor.opacity(0.2))
            .onTapGesture(perform: onTap)
    }
}
