//
//  CameraViewModel.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/24.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

protocol CameraViewModelInterface: AnyObject {
    var input: CameraViewModel.Input { get }
    var output: CameraViewModel.Output { get }
}

final class CameraViewModel: BaseViewModel<CameraViewModel>, CameraViewModelInterface {
    struct Input: InputType {
        let shutterButtonTapped = PublishRelay<Void>()
        let closeButtonTapped = PublishRelay<Void>()
        let viewWillAppear = PublishRelay<Void>()
        let viewWillDisappear = PublishRelay<Void>()
        let captured = PublishRelay<UIImage>()
    }

    struct Output: OutputType {
        let startCaptureSession: Observable<Void>
        let stopCaptureSession: Observable<Void>
        let shootCamera: Observable<Void>
    }

    struct State: StateType {}
    struct Dependency: DependencyType {
        let router: CameraRouterInterface
    }

    static func bind(input: Input, state: State, dependency: Dependency, disposeBag: DisposeBag) -> Output {
        input.closeButtonTapped
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe { _ in
                dependency.router.navigate(to: .close)
            }
            .disposed(by: disposeBag)

        input.captured
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe { image in
                dependency.router.navigate(to: .registerBizCard(image))
            }
            .disposed(by: disposeBag)

        let shootCameraObservable = input
            .shutterButtonTapped
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .asObservable()

        return .init(
            startCaptureSession: input.viewWillAppear.asObservable(),
            stopCaptureSession: input.viewWillDisappear.asObservable(),
            shootCamera: shootCameraObservable
        )
    }
}
