//
//  DependencyContainer.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import UIKit

protocol DependencyContainerInterface {
    var apiClient: APIClientInterface { get }
    var realmProvider: RealmProviderInterface { get }
    var bizCardAccessor: BizCardAccessorInterface { get }
    var bizCardImageAccessor: BizCardImageAccessorInterface { get }
    var bizCardRepository: BizCardRepositoryInterface { get }
    var bizCardStoreUseCase: BizCardStoreUseCaseInterface { get }
    var bizCardOCRUseCase: BizCardOCRUseCaseInterface { get }
    var bizCardFactoryUseCase: BizCardFactoryUseCaseInterface { get }
}

final class DependencyContainer: DependencyContainerInterface {
    static let shared = DependencyContainer()

    private init() {}

    var apiClient: APIClientInterface {
        APIClient()
    }

    var realmProvider: RealmProviderInterface {
        RealmProvider()
    }

    var bizCardAccessor: BizCardAccessorInterface {
        BizCardAccessor(realmProvider: realmProvider)
    }

    var bizCardImageAccessor: BizCardImageAccessorInterface {
        BizCardImageAccessor(realmProvider: realmProvider)
    }

    var bizCardRepository: BizCardRepositoryInterface {
        BizCardLocalRepository(
            bizCardAccessor: bizCardAccessor,
            bizCardImageAccessor: bizCardImageAccessor
        )
    }

    var bizCardStoreUseCase: BizCardStoreUseCaseInterface {
        BizCardStoreUseCase(
            bizCardRepository: bizCardRepository
        )
    }

    var bizCardOCRUseCase: BizCardOCRUseCaseInterface {
        BizCardOCRUseCase(apiClient: apiClient)
    }

    var bizCardFactoryUseCase: BizCardFactoryUseCaseInterface {
        BizCardFactoryUseCase()
    }
}
