//
//  Optional+Ext.swift
//  SyncTasker
//
//  Created by ingvar on 18.05.2025.
//

import Foundation

extension Optional where Wrapped == Date {
    
    /// Преобразует Date? → Date, в случае nil трактуется как «пустой» DayItem
    var map: Date? { self }
}
