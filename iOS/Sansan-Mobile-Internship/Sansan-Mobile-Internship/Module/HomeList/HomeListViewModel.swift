//
//  HomeListViewModel.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

protocol HomeListViewModelInterface: AnyObject {
    var input: HomeListViewModel.Input { get }
    var output: HomeListViewModel.Output { get }
}

/// ViewからのInputに応じで処理を行いOutputとして公開する
final class HomeListViewModel: BaseViewModel<HomeListViewModel>, HomeListViewModelInterface {
    /// Viewからのイベントを受け取りたい変数を定義する
    struct Input: InputType {
        // PublishRelayは初期値がない
        let viewWillAppear = PublishRelay<Void>()
        let didTapBizCard = PublishRelay<BizCardId>()
        let didTapCameraButton = PublishRelay<Void>()
        let didTapAddBizCardButton = PublishRelay<Void>()
    }

    /// Viewに購読させたい変数を定義する
    struct Output: OutputType {
        // Observableは値を流すことができない購読専用 (ViewからOutputに値を流せなくする)
        let sectionItems: Observable<[HomeListSectionModel]>
    }

    /// 状態変数を定義する(MVVMでいうModel相当)
    struct State: StateType {
        // BehaviorRelayは初期値があり､現在の値を保持することができる｡
        let bizCards: BehaviorRelay<[BizCard]> = .init(value: [])
    }

    /// Presentationレイヤーより上の依存物(APIやUseCase)や引数を定義する
    struct Dependency: DependencyType {
        let router: HomeListRouterInterface
        let bizCardStoreUseCase: BizCardStoreUseCaseInterface
        let dateFormatUseCase: DateFormatUseCaseInterface
    }

    init(
        router: HomeListRouterInterface,
        bizCardStoreUseCase: BizCardStoreUseCaseInterface,
        dateFormatUseCase: DateFormatUseCaseInterface
    ) {
        super.init(
            input: .init(),
            state: .init(),
            dependency: .init(
                router: router,
                bizCardStoreUseCase: BizCardStoreUseCase(
                    bizCardRepository: BizCardOnMemoryRepository(),
                    bizCardImageRepository: BizCardImageOnMemoryRepository()
                ),
                dateFormatUseCase: DateFormatUseCase()
            )
        )
    }

    /// Input, Stateからプレゼンテーションロジックを実装し､Outputにイベントを流す｡
    static func bind(input: Input, state: State, dependency: Dependency, disposeBag: DisposeBag) -> Output {
        input.viewWillAppear
            .subscribe { _ in
                let bizCards = dependency.bizCardStoreUseCase.fetchBizCards()
                state.bizCards.accept(bizCards)
            }
            .disposed(by: disposeBag)

        input.didTapBizCard
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance) /// 連続タップによる誤動作を防ぐため 800ms に一度のみイベントを有効にする
            .subscribe { bizCardId in
                guard let bizCardId = bizCardId.element else { return }
                dependency.router.navigate(.detail(bizCardId))
            }
            .disposed(by: disposeBag)

        input.didTapCameraButton
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe { _ in
                dependency.router.navigate(.camera)
            }
            .disposed(by: disposeBag)

        input.didTapAddBizCardButton
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe { _ in
                // オプション課題: PHPickerViewControllerを用いてアルバムから名刺を選択できるようにする
                // 1. Outputを介してPHPickerViewControllerをViewに表示させる
                // 2. 選択したUIImageをViewModelが受け取れるようにする
                // 3. RouterでBizCardDetail(create(UIImage))で遷移し､名刺を作成できるようにする
            }
            .disposed(by: disposeBag)

        // Stateが持つBizCardをTableViewで表示するために整形する
        let sectionItemsObservable = state.bizCards.map { bizCards -> [HomeListSectionModel] in
            let items = bizCards.map { bizCard -> (date: String, item: HomeListItemModel) in
                let dateText = dependency.dateFormatUseCase.formatToYYYYMM(date: bizCard.createdAt)
                let image = dependency.bizCardStoreUseCase.fetchImage(id: bizCard.id)
                let item = HomeListItemModel(bizCard: bizCard, image: image)
                return (dateText, item)
            }
            let groupedItems = Dictionary(grouping: items, by: { $0.date }).map { key, value in
                HomeListSectionModel(dateText: key, items: value.map(\.item))
            }
            return groupedItems.sorted(by: { $0.dateText > $1.dateText })
        }

        return .init(
            sectionItems: sectionItemsObservable
        )
    }
}
