//
//  DateFormatUseCase.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation

protocol DateFormatUseCaseInterface {
    func formatToYYYYMM(date: Date) -> String
}

/// Dateを日付の文字列にフォーマットする処理をまとめたUseCase
struct DateFormatUseCase: DateFormatUseCaseInterface {
    let dateFormatter = DateFormatter()

    func formatToYYYYMM(date: Date) -> String {
        dateFormatter.dateFormat = "YYYY/MM/d"
        return dateFormatter.string(from: date)
    }
}

