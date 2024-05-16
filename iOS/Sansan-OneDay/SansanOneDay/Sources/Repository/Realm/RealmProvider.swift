//
//  RealmProvider.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import Foundation
import RealmSwift

protocol RealmProviderInterface {
    func realm() throws -> Realm
}

class RealmProvider: RealmProviderInterface {
    private let schemaVersion: UInt64 = 0
    private func configuration() -> Realm.Configuration {
        return Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                print(migration.oldSchema, migration.newSchema)
                if oldSchemaVersion < self.schemaVersion {
                    // Do nothing
                }
            }
        )
    }

    func realm() throws -> Realm {
        try Realm(configuration: configuration())
    }
}
