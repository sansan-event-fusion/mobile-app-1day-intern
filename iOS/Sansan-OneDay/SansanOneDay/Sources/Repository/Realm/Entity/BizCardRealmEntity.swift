//
//  BizCardRealmEntity.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import Foundation
import RealmSwift

class BizCardRealmEntity: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String?
    @Persisted var companyName: String?
    @Persisted var tel: String?
    @Persisted var email: String?
    @Persisted var createdAt: Date
}

extension BizCardRealmEntity {
    convenience init(bizCard: BizCard) {
        self.init()
        id = bizCard.id.rawValue
        name = bizCard.name
        companyName = bizCard.companyName
        tel = bizCard.tel
        email = bizCard.email
        createdAt = bizCard.createdAt
    }

    var bizCard: BizCard {
        return BizCard(
            id: .init(rawValue: id),
            name: name,
            companyName: companyName,
            tel: tel,
            email: email,
            createdAt: createdAt
        )
    }
}
