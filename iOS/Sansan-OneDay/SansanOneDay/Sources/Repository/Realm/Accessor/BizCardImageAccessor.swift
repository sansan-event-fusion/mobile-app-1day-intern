//
//  BizCardImageAccessor.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/08.
//

import Foundation
import RealmSwift
import UIKit.UIImage

enum BizCardImageAccessorError: Error {
    case initializationFailed
    case saveFailed
    
    var localizedDescription: String {
        switch self {
        case .initializationFailed:
            return String(localized: "bizcardimageaccessor_error_initialization_failed")
        case .saveFailed:
            return String(localized: "bizcardimageaccessor_error_save_failed")
        }
    }
}

protocol BizCardImageAccessorInterface {
    // BizCardImage
    func fetchBizCardImageData(id: BizCardID) throws -> Data?
    @MainActor func save(bizCardImageData: Data, for id: BizCardID) throws
}

class BizCardImageAccessor: BizCardImageAccessorInterface {
    private let realmProvider: RealmProviderInterface

    init(realmProvider: RealmProviderInterface) {
        self.realmProvider = realmProvider
    }

    func fetchBizCardImageData(id: BizCardID) throws -> Data? {
        let realm = try realmProvider.realm()
        let results = realm.objects(BizCardImageRealmEntity.self)
        return results.first(where: { $0.id == id.rawValue })?.data
    }

    func save(bizCardImageData: Data, for id: BizCardID) throws {
        let realm = try realmProvider.realm()

        try realm.write {
            realm.add(BizCardImageRealmEntity(id: id, imageData: bizCardImageData), update: .modified)
        }
    }
}
