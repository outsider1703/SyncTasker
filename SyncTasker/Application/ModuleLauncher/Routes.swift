//
//  Routes.swift
//  SyncTasker
//
//  Created by ingvar on 14.02.2025.
//

//NavigationStack в SwiftUI требует:
//- path: Состояние, отслеживающее текущий путь навигации
//- Начальное представление (root view)
//- Правила для создания других представлений при навигации

enum Route: Hashable {
    case taskList
    case taskDetail(Task)
}
