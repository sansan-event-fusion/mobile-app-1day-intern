//
//  DependencyViewBuilder.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/08.
//

import UIKit

final class DependencyViewBuilder {
    static let shared = DependencyViewBuilder(container: DependencyContainer.shared)

    private let container: DependencyContainerInterface

    init(container: DependencyContainerInterface) {
        self.container = container
    }

    func bizCardList() -> UIViewController {
        let viewController = BizCardListViewController()
        let viewModel = BizCardListViewModel(
            input: .init(),
            state: .init(),
            dependency: .init(
                router: BizCardListRouter(moduleViewController: viewController),
                bizCardStoreUseCase: container.bizCardStoreUseCase,
                bizCardOCRUseCase: container.bizCardOCRUseCase
            )
        )
        viewController.viewModel = viewModel

        return viewController
    }

    func bizCardDetail(bizCardId: BizCardID) -> UIViewController {
        let viewController = BizCardDetailViewController()
        let viewModel = BizCardDetailViewModel(
            input: .init(),
            state: .init(),
            dependency: .init(
                router: BizCardDetailRouter(moduleViewController: viewController),
                bizCardId: bizCardId, 
                bizCardStoreUseCase: container.bizCardStoreUseCase
            )
        )
        viewController.viewModel = viewModel

        return viewController
    }

    func bizCardCapture() -> UIViewController {
        let viewController = BizCardCaptureViewController()
        let viewModel = BizCardCaptureViewModel(
            input: .init(),
            state: .init(),
            dependency: .init(router: BizCardCaptureRouter(moduleViewController: viewController))
        )
        viewController.viewModel = viewModel

        return viewController
    }

    func bizCardRegister(image: UIImage) -> UIViewController {
        let viewController = BizCardEditViewController()
        let viewModel = BizCardEditViewModel(
            input: .init(),
            state: .init(),
            dependency: .init(
                router: BizCardEditRouter(moduleViewController: viewController),
                operation: .register(image),
                bizCardOCRUseCase: container.bizCardOCRUseCase,
                bizCardFactoryUseCase: container.bizCardFactoryUseCase,
                bizCardStoreUseCase: container.bizCardStoreUseCase
            )
        )
        viewController.viewModel = viewModel

        return viewController
    }

    func bizCardEdit(bizCardID: BizCardID) -> UIViewController {
        let viewController = BizCardEditViewController()
        let viewModel = BizCardEditViewModel(
            input: .init(),
            state: .init(),
            dependency: .init(
                router: BizCardEditRouter(moduleViewController: viewController),
                operation: .edit(bizCardID),
                bizCardOCRUseCase: container.bizCardOCRUseCase,
                bizCardFactoryUseCase: container.bizCardFactoryUseCase,
                bizCardStoreUseCase: container.bizCardStoreUseCase
            )
        )
        viewController.viewModel = viewModel

        return viewController
    }
}
