//
//  CustomPicker.swift
//  SyncTasker
//
//  Created by ingvar on 13.03.2025.
//

import SwiftUI

struct CustomPicker<T: Hashable, Content: View>: View {
    
    @Binding private var selection: T
    private let title: String
    private let content: () -> Content
    
    init(
        _ title: String,
        selection: Binding<T>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._selection = selection
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Picker(title, selection: $selection) {
                content()
            }
            .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}
