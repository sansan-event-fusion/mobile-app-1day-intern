//
//  CameraRouter.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/24.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import UIKit

enum CameraRouterNavigationDestination {
    case close
    case registerBizCard(UIImage)
}

protocol CameraRouterInterface {
    func navigate(to destination: CameraRouterNavigationDestination)
}

final class CameraRouter: BaseRouter, CameraRouterInterface {
    init() {
        let viewController = R.storyboard.camera.instantiateInitialViewController()!
        super.init(moduleViewController: viewController)
        viewController.viewModel = CameraViewModel(
            input: .init(),
            state: .init(),
            dependency: .init(router: self)
        )
    }

    func navigate(to destination: CameraRouterNavigationDestination) {
        switch destination {
        case .close:
            moduleViewController.dismiss(animated: true)
        case .registerBizCard(let image):
            push(BizCardDetailRouter(mode: .create(image)))
        }
    }
}
