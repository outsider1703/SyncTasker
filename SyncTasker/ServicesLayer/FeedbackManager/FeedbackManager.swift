//
//  FeedbackManager.swift
//  SyncTasker
//
//  Created by ingvar on 12.02.2025.
//

import SwiftUI

class FeedbackManager {
    
    // MARK: - Singleton
    
    static let shared = FeedbackManager()
    
    // MARK: - Properties
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Methods
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light: lightGenerator.impactOccurred()
        case .medium: mediumGenerator.impactOccurred()
        case .heavy: heavyGenerator.impactOccurred()
        default: break
        }
    }
    
    func selection() {
        selectionGenerator.selectionChanged()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }
}
