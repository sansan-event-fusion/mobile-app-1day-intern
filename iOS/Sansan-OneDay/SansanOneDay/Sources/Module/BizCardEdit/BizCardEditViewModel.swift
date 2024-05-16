//
//  BizCardEditViewModel.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Combine
import Foundation
import UIKit.UIImage

// 名刺登録時と編集時で処理内容が異なるため、操作を表すenumを用意
enum BizCardEditOperation {
    case register(UIImage)
    case edit(BizCardID)
}

protocol BizCardEditViewModelInterface: AnyObject {
    var input: BizCardEditViewModel.Input { get }
    var output: BizCardEditViewModel.Output { get }
}

final class BizCardEditViewModel: BaseViewModel<BizCardEditViewModel>, BizCardEditViewModelInterface {
    struct Input: InputType {
        let viewDidLoad: PassthroughSubject<Void, Never> = .init()
        let save: PassthroughSubject<Void, Never> = .init()
        let editName: PassthroughSubject<String?, Never> = .init()
        let editCompany: PassthroughSubject<String?, Never> = .init()
        let editTel: PassthroughSubject<String?, Never> = .init()
        let editEmail: PassthroughSubject<String?, Never> = .init()
    }

    struct Output: OutputType {
        let title: AnyPublisher<String, Never>
        let bizCard: AnyPublisher<BizCard, Never>
        let bizCardImage: AnyPublisher<UIImage, Never>
        let loading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<String, Never>
    }

    struct State: StateType {
        let bizCard: CurrentValueSubject<BizCard?, Never> = .init(nil)
    }

    struct Dependency: DependencyType {
        let router: BizCardEditRouterInterface
        let operation: BizCardEditOperation
        let bizCardOCRUseCase: BizCardOCRUseCaseInterface
        let bizCardFactoryUseCase: BizCardFactoryUseCaseInterface
        let bizCardStoreUseCase: BizCardStoreUseCaseInterface
    }

    static func bind(input: Input, state: State, dependency: Dependency, cancellables: inout Set<AnyCancellable>) -> Output {
        enum BizCardEditError: Error {
            case emptyOCRResult
            case saveError

            var localizedDescription: String {
                switch self {
                case .emptyOCRResult:
                    return String(localized: "bizcardedit_error_empty_ocr_result")
                case .saveError:
                    return String(localized: "bizcardedit_error_save")
                }
            }
        }

        let titleSubject = PassthroughSubject<String, Never>()
        // 初回表示のみ
        let bizCardSubject = PassthroughSubject<BizCard, Never>()
        // 初回表示のみ
        let bizCardImageSubject = PassthroughSubject<UIImage, Never>()
        let loadingSubject = PassthroughSubject<Bool, Never>()
        let errorSubject = PassthroughSubject<String, Never>()

        input.viewDidLoad
            .receive(on: DispatchQueue.global(qos: .default))
            .sinkByAsync(receiveValue: { _ in
                switch dependency.operation {
                case let .register(image):
                    titleSubject.send(String(localized: "bizcardregister_navigation_title"))
                    bizCardImageSubject.send(image)
                    do {
                        loadingSubject.send(true)
                        let annotationImages = try await dependency.bizCardOCRUseCase.recognize(image: image)
                        guard let annotationImage = annotationImages.first else { throw BizCardEditError.emptyOCRResult }
                        let bizCard = dependency.bizCardFactoryUseCase.createBizCard(from: annotationImage)
                        bizCardSubject.send(bizCard)
                        state.bizCard.send(bizCard)
                        loadingSubject.send(false)
                    } catch {
                        loadingSubject.send(false)
                        errorSubject.send(error.localizedDescription)
                    }
                case let .edit(bizCardID):
                    titleSubject.send(String(localized: "bizcardedit_navigation_title"))
                    do {
                        loadingSubject.send(true)
                        let bizCard = try await dependency.bizCardStoreUseCase.fetchBizCard(id: bizCardID)
                        let bizCardImage = try await dependency.bizCardStoreUseCase.fetchBizCardImage(id: bizCardID)
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
                    }
                }
            })
            .store(in: &cancellables)

        input.save
            .throttle(for: .milliseconds(250), scheduler: DispatchQueue.main, latest: false)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sinkByAsync(receiveValue: { _ in
                switch dependency.operation {
                case let .register(image):
                    do {
                        guard let bizCard = state.bizCard.value else { throw BizCardEditError.saveError }
                        loadingSubject.send(true)
                        try await dependency.bizCardStoreUseCase.save(bizCard: bizCard)
                        try await dependency.bizCardStoreUseCase.save(bizCardImage: image, for: bizCard.id)
                        loadingSubject.send(false)
                        await dependency.router.navigate(to: .dismiss)
                    } catch {
                        loadingSubject.send(false)
                        errorSubject.send(error.localizedDescription)
                    }
                case .edit:
                    do {
                        guard let bizCard = state.bizCard.value else { throw BizCardEditError.saveError }
                        loadingSubject.send(true)
                        try await dependency.bizCardStoreUseCase.save(bizCard: bizCard)
                        loadingSubject.send(false)
                        await dependency.router.navigate(to: .pop)
                    } catch {
                        loadingSubject.send(false)
                        errorSubject.send(error.localizedDescription)
                    }
                }
            })
            .store(in: &cancellables)

        input.editName
            .receive(on: DispatchQueue.global(qos: .default))
            .sink { text in
                guard let bizCard = state.bizCard.value else { return }
                state.bizCard.send(.init(id: bizCard.id, name: text, companyName: bizCard.companyName, tel: bizCard.tel, email: bizCard.email, createdAt: bizCard.createdAt))
            }
            .store(in: &cancellables)

        input.editCompany
            .receive(on: DispatchQueue.global(qos: .default))
            .sink { text in
                guard let bizCard = state.bizCard.value else { return }
                state.bizCard.send(.init(id: bizCard.id, name: bizCard.name, companyName: text, tel: bizCard.tel, email: bizCard.email, createdAt: bizCard.createdAt))
            }
            .store(in: &cancellables)

        input.editTel
            .receive(on: DispatchQueue.global(qos: .default))
            .sink { text in
                guard let bizCard = state.bizCard.value else { return }
                state.bizCard.send(.init(id: bizCard.id, name: bizCard.name, companyName: bizCard.companyName, tel: text, email: bizCard.email, createdAt: bizCard.createdAt))
            }
            .store(in: &cancellables)

        input.editEmail
            .receive(on: DispatchQueue.global(qos: .default))
            .sink { text in
                guard let bizCard = state.bizCard.value else { return }
                state.bizCard.send(.init(id: bizCard.id, name: bizCard.name, companyName: bizCard.companyName, tel: bizCard.tel, email: text, createdAt: bizCard.createdAt))
            }
            .store(in: &cancellables)

        return Output(
            title: titleSubject.eraseToAnyPublisher(),
            bizCard: bizCardSubject.eraseToAnyPublisher(),
            bizCardImage: bizCardImageSubject.eraseToAnyPublisher(),
            loading: loadingSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher()
        )
    }
}
