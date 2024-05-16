//
//  BizCardDetailRouter.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import UIKit

enum BizCardDetailRouteDestination {
    case pop
    case bizCardEdit(BizCardID)
}

@MainActor
protocol BizCardDetailRouterInterface {
    func navigate(to destination: BizCardDetailRouteDestination)
}

final class BizCardDetailRouter: BaseRouter, BizCardDetailRouterInterface {
    func navigate(to destination: BizCardDetailRouteDestination) {
        switch destination {
        case .pop:
            pop()
        case let .bizCardEdit(bizCardId):
            push(DependencyViewBuilder.shared.bizCardEdit(bizCardID: bizCardId))
        }
    }
}
