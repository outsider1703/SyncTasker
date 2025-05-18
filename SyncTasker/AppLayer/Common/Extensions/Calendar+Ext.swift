//
//  Calendar+Ext.swift
//  SyncTasker
//
//  Created by ingvar on 18.05.2025.
//

import Foundation

extension Calendar {
    
    /// Генерирует массив дат от start до end включительно с шагом adding единиц компонента.
    func dates(from start: Date, through end: Date, adding component: Calendar.Component, value: Int) -> [Date] {
        var dates = [start]
        var current = start
        while let next = date(byAdding: component, value: value, to: current), next <= end {
            dates.append(next)
            current = next
        }
        return dates
    }
}
