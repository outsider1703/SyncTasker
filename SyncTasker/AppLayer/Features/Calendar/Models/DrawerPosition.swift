//
//  DrawerPosition.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

enum DrawerPosition {
    case closed, mid, open
    
    var offset: CGFloat {
        switch self {
        case .closed: return UIScreen.main.bounds.width - 40
        case .mid: return UIScreen.main.bounds.width / 2
        case .open: return 0
        }
    }
}
