//
//  BizCardDetailViewModel.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Combine
import Foundation
import UIKit.UIImage

protocol BizCardDetailViewModelInterface: AnyObject {
    var input: BizCardDetailViewModel.Input { get }
    var output: BizCardDetailViewModel.Output { get }
}

final class BizCardDetailViewModel: BaseViewModel<BizCardDetailViewModel>, BizCardDetailViewModelInterface {
    struct Input: InputType {
        let viewAppear: PassthroughSubject<Void, Never> = .init()
        let tappedEdit: PassthroughSubject<Void, Never> = .init()
    }

    struct Output: OutputType {
        let bizCard: AnyPublisher<BizCard, Never>
        let bizCardImage: AnyPublisher<UIImage, Never>
        let loading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<String, Never>
    }

    struct State: StateType {
        let bizCard: CurrentValueSubject<BizCard?, Never> = .init(nil)
    }

    struct Dependency: DependencyType {
        let router: BizCardDetailRouterInterface
        let bizCardId: BizCardID
        let bizCardStoreUseCase: BizCardStoreUseCaseInterface
    }

    static func bind(input: Input, state: State, dependency: Dependency, cancellables: inout Set<AnyCancellable>) -> Output {
        // 初回表示のみ
        let bizCardSubject = PassthroughSubject<BizCard, Never>()
        // 初回表示のみ
        let bizCardImageSubject = PassthroughSubject<UIImage, Never>()
        let loadingSubject = PassthroughSubject<Bool, Never>()
        let errorSubject = PassthroughSubject<String, Never>()

        input.viewAppear
            .receive(on: DispatchQueue.global(qos: .default))
            .sinkByAsync(receiveValue: { _ in
                do {
                    loadingSubject.send(true)
                    let bizCard = try await dependency.bizCardStoreUseCase.fetchBizCard(id: dependency.bizCardId)
                    let bizCardImage = try await dependency.bizCardStoreUseCase.fetchBizCardImage(id: dependency.bizCardId)
                    if let bizCard {
                        bizCardSubject.send(bizCard)
                    }
                    if let bizCardImage {
                        bizCardImageSubject.send(bizCardImage)
                    }
                    state.bizCard.send(bizCard)
                    loadingSubject.send(false)
                } catch {
                    loadingSubject.send(false)
                    errorSubject.send(error.localizedDescription)
                    await dependency.router.navigate(to: .pop)
                }
            })
            .store(in: &cancellables)

        input.tappedEdit
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sinkByAsync(receiveValue: { _ in
                await dependency.router.navigate(to: .bizCardEdit(dependency.bizCardId))
            })
            .store(in: &cancellables)

        return Output(
            bizCard: bizCardSubject.eraseToAnyPublisher(),
            bizCardImage: bizCardImageSubject.eraseToAnyPublisher(),
            loading: loadingSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher()
        )
    }
}
