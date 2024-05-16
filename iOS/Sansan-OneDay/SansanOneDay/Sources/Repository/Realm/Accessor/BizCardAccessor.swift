//
//  BizCardAccessor.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import Foundation
import RealmSwift

protocol BizCardAccessorInterface {
    // BizCard
    func fetchBizCards() throws -> [BizCard]
    func fetchBizCard(id: BizCardID) throws -> BizCard?
    @MainActor func save(bizCard: BizCard) throws
}

class BizCardAccessor: BizCardAccessorInterface {
    private let realmProvider: RealmProviderInterface

    init(realmProvider: RealmProviderInterface) {
        self.realmProvider = realmProvider
    }

    func fetchBizCards() throws -> [BizCard] {
        let realm = try realmProvider.realm()
        let results = realm.objects(BizCardRealmEntity.self)
        return results.map(\.bizCard)
    }

    func fetchBizCard(id: BizCardID) throws -> BizCard? {
        let realm = try realmProvider.realm()
        let results = realm.objects(BizCardRealmEntity.self)
        return results.first(where: { $0.id == id.rawValue })?.bizCard
    }

    func save(bizCard: BizCard) throws {
        let realm = try realmProvider.realm()
        try realm.write {
            realm.add(BizCardRealmEntity(bizCard: bizCard), update: .modified)
        }
    }
}
