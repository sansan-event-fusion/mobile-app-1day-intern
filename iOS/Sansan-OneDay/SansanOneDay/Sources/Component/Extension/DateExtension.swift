//
//  DateExtension.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import Foundation

extension Date {
    enum Format: String {
        case yyyyMMddHHmmss = "yyyy/MM/dd HH:mm:ss"
        case yyyyMMdd = "yyyy/MM/dd"
    }

    func string(format: Format) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
