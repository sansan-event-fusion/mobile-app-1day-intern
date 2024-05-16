import ProjectDescription

// xcstring
let project = Project(
    name: "SansanOneDay",
    packages: [
        .remote(
            url: "https://github.com/SVProgressHUD/SVProgressHUD.git",
            requirement: .upToNextMajor(from: "2.0.0")
        ),
        .remote(
            url: "https://github.com/mac-cain13/R.swift",
            requirement: .upToNextMajor(from: "7.0.0")
        ),
        .remote(url: "https://github.com/realm/realm-swift.git", requirement: .exact("10.45.0"))
    ],
    settings: .settings(configurations: [
        .debug(name: "Confg", xcconfig: "Resources/Config.xcconfig"),
        .release(name: "Config", xcconfig: "Resources/Config.xcconfig")
    ]),
    targets: [
        .target(
            name: "SansanOneDay",
            destinations: .iOS,
            product: .app,
            bundleId: "com.sansan.OneDay",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Sansan1Day",
                    "CFBundleName": "SansanOneDay",
                    "LSApplicationCategoryType": "public.app-category.productivity",
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ]
                            ]
                        ]
                    ],
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "GOOGLE_API_KEY": "$(GOOGLE_API_KEY)",
                    // camera使う
                    "NSCameraUsageDescription": "カメラを使用します",
                    // defaultLocalization
                    "CFBundleDevelopmentRegion": "Japanese",
                    "CFBundleLocalizations": ["ja"],
                    "UIUserInterfaceStyle": "Light",
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**", "Sources/**/*.xib"],
            dependencies: [
                .package(product: "SVProgressHUD", type: .runtime),
                .package(product: "RswiftLibrary"),
                .package(product: "RswiftGenerateInternalResources", type: .plugin),
                .package(product: "RealmSwift", type: .runtime)
            ]
        ),
        .target(
            name: "SansanOneDayTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.sansan.OneDayTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "SansanOneDay")]
        )
    ]
)
