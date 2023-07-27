//
//  HomeListRouter.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation

enum HomeListNavigationDestination {
    case camera
    case detail(BizCardId)
}

protocol HomeListRouterInterface {
    func navigate(_ destination: HomeListNavigationDestination)
}

final class HomeListRouter: BaseRouter, HomeListRouterInterface {
    init() {
        let viewController = HomeListViewController()
        super.init(moduleViewController: viewController)
        viewController.viewModel = HomeListViewModel(
            router: self,
            bizCardStoreUseCase: BizCardStoreUseCase(
                bizCardRepository: BizCardOnMemoryRepository(),
                bizCardImageRepository: BizCardImageOnMemoryRepository()
            ),
            dateFormatUseCase: DateFormatUseCase()
        )
    }

    func navigate(_ destination: HomeListNavigationDestination) {
        switch destination {
        case .camera:
            presentNavigation(CameraRouter())
        case let .detail(bizCardId):
            push(BizCardDetailRouter(mode: .detail(bizCardId)))
        }
    }
}
