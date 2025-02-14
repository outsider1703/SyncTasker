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

    @Published var path = NavigationPath()
    
    func navigate(to route: Route) async {
        path.append(route)
    }
    
    func navigateBack() async {
        path.removeLast()
    }
    
    func navigateToRoot() async {
        path.removeLast(path.count)
    }
}
