//
//  AppDelegate.swift
//  Sansan-Mobile-Internship
//
//  Created by Sansan on 2019/07/12.
//  Copyright © 2018 Sansan. All rights reserved.
//

import UIKit
import SVProgressHUD

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: HomeListRouter().moduleViewController)
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = .dark

        UIButton.appearance().isExclusiveTouch = true
        UILabel.appearance().isExclusiveTouch = true
        UITableView.appearance().sectionHeaderTopPadding = 0

        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = AppConstants.Color.navigation
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = AppConstants.Color.navigation
        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.scrollEdgeAppearance = navigationBarAppearance

        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setDefaultAnimationType(.flat)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

