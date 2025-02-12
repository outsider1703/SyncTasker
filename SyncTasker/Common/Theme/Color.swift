//
//  Color.swift
//  SyncTasker
//
//  Created by ingvar on 11.02.2025.
//

import SwiftUI

// MARK: - Colors

enum Theme {
    enum Colors {
        static let background = Color(light: .white, dark: .black)
        static let foreground = Color(light: .gray, dark: .gray.opacity(0.8))
        static let primary = Color(light: .black, dark: .white)
        static let secondary = Color(light: .black.opacity(0.5), dark: .white.opacity(0.5))
        static let accent = Color.accentColor
        
        static let priorityLow = Color(light: .red.opacity(0.2), dark: .red.opacity(0.3))
        static let priorityMedium = Color(light: .red.opacity(0.5), dark: .red.opacity(0.6))
        static let priorityHigh = Color(light: .red.opacity(0.8), dark: .red.opacity(0.9))
        
        static let success = Color.green
        static let error = Color.red
    }
}

// MARK: - Color Extension

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
