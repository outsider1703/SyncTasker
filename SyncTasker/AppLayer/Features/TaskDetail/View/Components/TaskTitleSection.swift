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
        Section {
            TextField(Constants.titlePlaceholder, text: $title)
                .font(Theme.Typography.headlineFont)
            
            TextEditor(text: $description)
                .font(Theme.Typography.bodyFont)
                .frame(minHeight: 40)
                .placeholder(when: description.isEmpty) {
                    Text(Constants.descriptionPlaceholder)
                        .foregroundColor(Theme.Colors.secondary)
                }
        }
    }
}
