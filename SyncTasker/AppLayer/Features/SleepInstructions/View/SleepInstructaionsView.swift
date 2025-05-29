//
//  SleepInstructaionsView.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import SwiftUI

struct SleepInstructaionsView: View {
    
    // MARK: - Initial Private Properties
    
    @StateObject private var viewModel: SleepInstructionsViewModel
    
    // MARK: - Initialization
    
    init(
        viewModel: SleepInstructionsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        Text("")
    }
}
