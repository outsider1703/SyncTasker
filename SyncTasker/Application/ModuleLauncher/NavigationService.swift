//
//  NavigationRouter.swift
//  SyncTasker
//
//  Created by ingvar on 14.02.2025.
//

import SwiftUI

// NavigationService: управление состоянием навигации

protocol NavigationServiceProtocol: AnyObject {
    func navigate(to route: Route) async
    func navigateBack() async
    func navigateToRoot() async
}

@MainActor
class NavigationService: ObservableObject, NavigationServiceProtocol {

    @Published var path: NavigationPath
    @Published var presentedModal: Route?
    
    init(initialPath: NavigationPath = NavigationPath(), initialModal: Route? = nil) {
        self.path = initialPath
        self.presentedModal = initialModal
    }

    func navigate(to route: Route) async {
        if route.isModal {
            presentedModal = route
        } else {
            path.append(route)
        }
    }
    
    func navigateBack() async {
        if presentedModal != nil {
            presentedModal = nil
        } else {
            path.removeLast()
        }
    }
    
    func navigateToRoot() async {
        presentedModal = nil
        path.removeLast(path.count)
    }
}
