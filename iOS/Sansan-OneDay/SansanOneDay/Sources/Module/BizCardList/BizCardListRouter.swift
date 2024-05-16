//
//  BizCardListRouter.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import UIKit

enum BizCardListRouteDestination {
    case bizCardDetail(BizCardID)
    case bizCardCapture
}

@MainActor
protocol BizCardListRouterInterface {
    func navigate(to destination: BizCardListRouteDestination)
}

final class BizCardListRouter: BaseRouter, BizCardListRouterInterface {
    func navigate(to destination: BizCardListRouteDestination) {
        switch destination {
        case let .bizCardDetail(bizCardId):
            push(DependencyViewBuilder.shared.bizCardDetail(bizCardId: bizCardId))
        case .bizCardCapture:
            presentNavigation(DependencyViewBuilder.shared.bizCardCapture())
        }
    }
}
