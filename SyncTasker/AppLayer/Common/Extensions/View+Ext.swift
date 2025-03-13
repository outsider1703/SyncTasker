//
//  View+Ext.swift
//  SyncTasker
//
//  Created by ingvar on 11.02.2025.
//

import SwiftUI

extension View {
    func primaryButton() -> some View {
        self.padding(Theme.Layout.padding)
            .background(Theme.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(Theme.Layout.cornerRadius)
    }
    
    func secondaryButton() -> some View {
        self.padding(Theme.Layout.padding)
            .background(Theme.Colors.secondary)
            .foregroundColor(Theme.Colors.foreground)
            .cornerRadius(Theme.Layout.cornerRadius)
    }
    
    func withHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light, onTap action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            FeedbackManager.shared.impact(style: style)
            action()
        }
    }
    
    func withSlideAnimation(isAnimating: Bool) -> some View {
        self.transition(.slide)
            .animation(.spring(), value: isAnimating)
    }
    
    func withFadeAnimation(isAnimating: Bool) -> some View {
        self.transition(.opacity)
            .animation(.easeInOut, value: isAnimating)
    }
}
