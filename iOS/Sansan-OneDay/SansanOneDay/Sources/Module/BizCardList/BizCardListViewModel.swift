//
//  BizCardListViewModel.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Combine
import Foundation
import UIKit.UIImage

protocol BizCardListViewModelInterface: AnyObject {
    var input: BizCardListViewModel.Input { get }
    var output: BizCardListViewModel.Output { get }
}

final class BizCardListViewModel: BaseViewModel<BizCardListViewModel>, BizCardListViewModelInterface {
    struct BizCardSet {
        let bizCard: BizCard
        let image: UIImage?
    }

    struct Input: InputType {
        let viewDidAppear: PassthroughSubject<Void, Never> = .init()
        let searchText: PassthroughSubject<String?, Never> = .init()
        let tappedScan: PassthroughSubject<Void, Never> = .init()
        let tappedBizCard: PassthroughSubject<BizCardID, Never> = .init()
    }

    struct Output: OutputType {
        let bizCards: AnyPublisher<[(BizCardListSectionModel, [BizCardListItemModel])], Never>
        let loading: AnyPublisher<Bool, Never>
    }

    struct State: StateType {
        let bizCards: CurrentValueSubject<[BizCardSet], Never> = .init([])
    }

    struct Dependency: DependencyType {
        let router: BizCardListRouterInterface
        let bizCardStoreUseCase: BizCardStoreUseCaseInterface
        let bizCardOCRUseCase: BizCardOCRUseCaseInterface
    }

    static func bind(input: Input, state: State, dependency: Dependency, cancellables: inout Set<AnyCancellable>) -> Output {
        let loadingSubject = PassthroughSubject<Bool, Never>()

        input.viewDidAppear
            .receive(on: DispatchQueue.global(qos: .default))
            .sinkByAsync(receiveValue: { _ in
                do {
                    loadingSubject.send(true)
                    let bizCards = try await dependency.bizCardStoreUseCase.fetchBizCards()
                    loadingSubject.send(false)
                    var bizCardsList: [BizCardSet] = []
                    for bizCard in bizCards {
                        let bizCardImage = try await dependency.bizCardStoreUseCase.fetchBizCardImage(id: bizCard.id)
                        bizCardsList.append(.init(bizCard: bizCard, image: bizCardImage))
                    }
                    state.bizCards.send(bizCardsList)
                } catch {
                    NSLog(error.localizedDescription)
                }
            })
            .store(in: &cancellables)

        input.tappedScan
            .throttle(for: .milliseconds(250), scheduler: DispatchQueue.main, latest: false)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sinkByAsync(receiveValue: { _ in
                await dependency.router.navigate(to: .bizCardCapture)
            })
            .store(in: &cancellables)

        input.tappedBizCard
            .throttle(for: .milliseconds(250), scheduler: DispatchQueue.main, latest: false)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sinkByAsync(receiveValue: { id in
                await dependency.router.navigate(to: .bizCardDetail(id))
            })
            .store(in: &cancellables)

        // TODO: 名刺一覧表示
        // Fetchした名刺と検索ワードでフィルタした上で、ソートも行う
        let bizCards = Publishers.CombineLatest(state.bizCards, input.searchText)
            .receive(on: DispatchQueue.global(qos: .background))
            .map { $0.0 }
            .map { bizCardsSet -> [(BizCardListSectionModel, [BizCardListItemModel])] in
                let bizCardListItems = bizCardsSet.map { bizCardSet -> BizCardListItemModel in
                    .init(bizCard: bizCardSet.bizCard, bizCardImage: bizCardSet.image)
                }

                // 日付でソート
                let sortedBizCards = bizCardListItems.sorted {
                    $0.bizCard.createdAt > $1.bizCard.createdAt
                }

                // yymmddで順序を維持しつつキーを抽出
                let sectionKeys = sortedBizCards.map { bizCardListItem in
                    bizCardListItem.bizCard.createdAt.string(format: .yyyyMMdd)
                }.unique()

                // yymmddでグループ化
                let sectionedBizCards = Dictionary(grouping: sortedBizCards) { bizCardListItem in
                    bizCardListItem.bizCard.createdAt.string(format: .yyyyMMdd)
                }

                return sectionKeys.map { sectionKey in
                    (BizCardListSectionModel(title: sectionKey), sectionedBizCards[sectionKey] ?? [])
                }
            }
            .eraseToAnyPublisher()

        return Output(
            bizCards: bizCards,
            loading: loadingSubject.eraseToAnyPublisher()
        )
    }
}
