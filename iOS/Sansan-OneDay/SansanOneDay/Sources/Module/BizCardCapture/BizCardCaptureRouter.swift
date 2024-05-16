//
//  BizCardCaptureRouter.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import UIKit

enum BizCardCaptureRouteDestination {
    case bizCardRegister(UIImage)
    case dismiss
}

@MainActor
protocol BizCardCaptureRouterInterface {
    func navigate(to destination: BizCardCaptureRouteDestination)
}

final class BizCardCaptureRouter: BaseRouter, BizCardCaptureRouterInterface {
    func navigate(to destination: BizCardCaptureRouteDestination) {
        switch destination {
        case let .bizCardRegister(image):
            push(DependencyViewBuilder.shared.bizCardRegister(image: image))

        case .dismiss:
            dismiss()
        }
    }
}
