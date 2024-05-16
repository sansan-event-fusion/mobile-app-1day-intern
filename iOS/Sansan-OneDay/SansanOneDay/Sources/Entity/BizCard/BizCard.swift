//
//  BizCard.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Foundation

struct BizCard: Hashable {
    let id: BizCardID
    let name: String?
    let companyName: String?
    let tel: String?
    let email: String?
    let createdAt: Date
}
