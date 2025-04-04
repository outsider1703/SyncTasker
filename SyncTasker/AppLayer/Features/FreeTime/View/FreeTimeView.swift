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
            
        }
    }
}
