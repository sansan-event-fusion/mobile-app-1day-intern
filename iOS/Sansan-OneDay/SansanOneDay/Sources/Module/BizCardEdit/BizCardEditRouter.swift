//
//  BizCardEditRouter.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import UIKit

enum BizCardEditRouteDestination {
    case dismiss
    case pop
}

@MainActor
protocol BizCardEditRouterInterface {
    func navigate(to destination: BizCardEditRouteDestination)
}

final class BizCardEditRouter: BaseRouter, BizCardEditRouterInterface {
    func navigate(to destination: BizCardEditRouteDestination) {
        switch destination {
        case .dismiss:
            dismiss()
        case .pop:
            pop()
        }
    }
}
