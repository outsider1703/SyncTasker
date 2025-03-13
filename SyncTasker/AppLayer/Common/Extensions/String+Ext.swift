//
//  String+Ext.swift
//  SyncTasker
//
//  Created by ingvar on 13.03.2025.
//

import Foundation
import UIKit

extension String {
    
    /// Вычисляет высоту текста при заданной ширине и шрифте
    /// - Parameters:
    ///   - width: Максимальная ширина текста
    ///   - font: Шрифт текста
    /// - Returns: Высота текста в точках
    func calculateHeight(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
    
    /// Вычисляет ширину текста при заданной высоте и шрифте
    /// - Parameters:
    ///   - height: Максимальная высота текста
    ///   - font: Шрифт текста
    /// - Returns: Ширина текста в точках
    func calculateWidth(withHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.width)
    }
}
