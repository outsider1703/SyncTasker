//
//  TaskDetailView.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import SwiftUI

struct TaskDetailView: View {
    
    let item: Item
    
    var body: some View {
        Text(item.description)
    }
}
