//
//  BizCardCaptureViewModel.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Combine
import Foundation
import UIKit.UIImage

protocol BizCardCaptureViewModelInterface: AnyObject {
    var input: BizCardCaptureViewModel.Input { get }
    var output: BizCardCaptureViewModel.Output { get }
}

final class BizCardCaptureViewModel: BaseViewModel<BizCardCaptureViewModel>, BizCardCaptureViewModelInterface {
    struct Input: InputType {
        let viewAppear: PassthroughSubject<Void, Never> = .init()
        let tappedClose: PassthroughSubject<Void, Never> = .init()
        let captureShot: PassthroughSubject<UIImage, Never> = .init()
    }

    struct Output: OutputType {}

    struct State: StateType {
        let isCaptured: CurrentValueSubject<Bool, Never> = .init(false)
    }

    struct Dependency: DependencyType {
        let router: BizCardCaptureRouterInterface
    }

    static func bind(input: Input, state: State, dependency: Dependency, cancellables: inout Set<AnyCancellable>) -> Output {
        input.viewAppear
            .sinkByAsync(receiveValue: { _ in
                state.isCaptured.send(false)
            })
            .store(in: &cancellables)
        
        input.tappedClose
            .throttle(for: .milliseconds(250), scheduler: DispatchQueue.main, latest: false)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sinkByAsync(receiveValue: { _ in
                await dependency.router.navigate(to: .dismiss)
            })
            .store(in: &cancellables)

        input.captureShot
            .filter { _ in !state.isCaptured.value }
            .throttle(for: .milliseconds(250), scheduler: DispatchQueue.main, latest: false)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sinkByAsync(receiveValue: { image in
                state.isCaptured.send(true)
                await dependency.router.navigate(to: .bizCardRegister(image))
            })
            .store(in: &cancellables)

        return Output()
    }
}
