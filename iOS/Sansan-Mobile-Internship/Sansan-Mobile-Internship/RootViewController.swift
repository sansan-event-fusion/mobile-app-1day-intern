//
//  RootViewController.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import UIKit

final class RootViewController: UIViewController {
    private let containerView: UIView = .init()
    private var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        switchToMain()
    }

    private func switchToMain() {
        let navigationController = UINavigationController(rootViewController: HomeListRouter().moduleViewController)
        switchContainer(to: navigationController)
    }

    private func switchContainer(to viewController: UIViewController) {
        if let previousViewController = self.currentViewController {
            previousViewController.willMove(toParent: nil)
            previousViewController.view.removeFromSuperview()
            previousViewController.removeFromParent()
        }

        addChild(viewController)
        self.containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        self.currentViewController = viewController
        view.layoutSubviews()
    }
}
