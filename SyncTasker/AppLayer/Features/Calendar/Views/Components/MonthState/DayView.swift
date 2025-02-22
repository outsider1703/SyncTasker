//
//  DayView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DayView: View {
    
    // MARK: - Properties
    
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    private let calendar = Calendar.current
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.white
                .frame(width: 150, height: 150)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            Text("\(calendar.component(.day, from: date))")
                .font(Theme.Typography.bodyFont)
                .padding(8)
        }
        .frame(width: 150, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Theme.Colors.primary : .white)
        )
        .foregroundColor(isSelected ? .white : Theme.Colors.primary)
        .onTapGesture(perform: onTap)
    }
}
