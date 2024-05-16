//
//  BizCardImageRealmEntity.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import Foundation
import RealmSwift

class BizCardImageRealmEntity: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var data: Data
}

extension BizCardImageRealmEntity {
    convenience init(id: BizCardID, imageData: Data) {
        self.init()
        self.id = id.rawValue
        self.data = imageData
    }
}
