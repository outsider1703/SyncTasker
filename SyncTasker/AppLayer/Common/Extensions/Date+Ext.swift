//
//  Date+Ext.swift
//  SyncTasker
//
//  Created by ingvar on 03.03.2025.
//

import Foundation

extension Date {
    
    /// Конвертирует дату в строку
    /// - Parameter format: Формат даты
    /// - Returns: Строковое представление даты
    func toString(format: String = "dd.MM.yy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func inHours(for multiplier: Int = 0) -> Int {
        return Calendar.current.component(.hour, from: self) * multiplier
    }
    
    func inMinuts() -> Int {
        Calendar.current.component(.minute, from: self)
    }
}
