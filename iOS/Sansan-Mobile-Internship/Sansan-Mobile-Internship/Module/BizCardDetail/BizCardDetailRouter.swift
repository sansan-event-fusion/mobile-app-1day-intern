//
//  BizCardDetailRouter.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/24.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import UIKit

enum BizCardDetailNavigationDestination {
    case back
    case close
    case edit(BizCardId)
}

protocol BizCardDetailRouterInterface {
    func navigate(_ destination: BizCardDetailNavigationDestination)
}

enum BizCardDetailPresentationMode {
    case create(UIImage)
    case edit(BizCardId)
    case detail(BizCardId)
}

final class BizCardDetailRouter: BaseRouter, BizCardDetailRouterInterface {
    init(mode: BizCardDetailPresentationMode) {
        let viewController = R.storyboard.bizCardDetail.instantiateInitialViewController()!
        super.init(moduleViewController: viewController)
        viewController.viewModel = BizCardDetailViewModel(
            input: .init(),
            state: .init(),
            dependency: .init(
                router: self,
                mode: mode,
                annotateImageAPI: AnnotateImageAPI(apiKey: AppConstants.API.key),
                bizCardAnnotateUseCase: BizCardAnnotateUseCase(),
                bizCardFactory: BizCardFactory(),
                bizCardStoreUseCase: BizCardStoreUseCase(
                    bizCardRepository: BizCardOnMemoryRepository(),
                    bizCardImageRepository: BizCardImageOnMemoryRepository()
                ),
                dateFormatUseCase: DateFormatUseCase()
            )
        )
    }

    func navigate(_ destination: BizCardDetailNavigationDestination) {
        switch destination {
        case .back:
            moduleViewController.navigationController?.popViewController(animated: true)
        case .close:
            moduleViewController.dismiss(animated: true)
        case let .edit(bizCardId):
            push(BizCardDetailRouter(mode: .edit(bizCardId)))
        }
    }
}
