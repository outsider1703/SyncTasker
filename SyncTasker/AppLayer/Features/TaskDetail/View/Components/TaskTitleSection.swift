//
//  TaskTitleSection.swift
//  SyncTasker
//
//  Created by ingvar on 10.03.2025.
//

import SwiftUI

private enum Constants {
    static let titlePlaceholder = "Task Title"
    static let descriptionPlaceholder = "Task Description"
}

struct TaskTitleSection: View {
    
    // MARK: - Private Properties
    
    @Binding private var title: String
    @Binding private var description: String
    
    // MARK: - Initialization
    
    init(
        title: Binding<String>,
        description: Binding<String>
    ) {
        self._title = title
        self._description = description
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            TextField(Constants.titlePlaceholder, text: $title)
                .font(Theme.Typography.headlineFont)
                .frame(height: 40)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(Constants.descriptionPlaceholder)
                    .foregroundStyle(.secondary)
                TextEditor(text: $description)
                    .font(Theme.Typography.bodyFont)
                    .frame(minHeight: 40)
                    .cornerRadius(12)
                    .shadow(radius: 1)
            }
        }
    }
}
