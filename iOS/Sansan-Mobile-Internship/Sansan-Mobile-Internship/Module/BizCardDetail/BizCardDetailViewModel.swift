//
//  BizCardDetailViewModel.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/24.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

protocol BizCardDetailViewModelInterface: AnyObject {
    var input: BizCardDetailViewModel.Input { get }
    var output: BizCardDetailViewModel.Output { get }
}

final class BizCardDetailViewModel: BaseViewModel<BizCardDetailViewModel>, BizCardDetailViewModelInterface {
    struct Input: InputType {
        let viewDidLoad = PublishRelay<Void>()
        let viewWillAppear = PublishRelay<Void>()
        let didTapBackButton = PublishRelay<Void>()
        let didTapEditButton = PublishRelay<Void>()
        let didTapSaveButton = PublishRelay<(name: String?, companyName: String?, tel: String?, email: String?)>()
    }

    struct Output: OutputType {
        let isEditable: Observable<Bool>
        let isLoading: Observable<Bool>
        let showError: Observable<String>
        let title: Observable<String>
        let bizCardImage: Observable<UIImage>
        let registeredDate: Observable<String>
        let saveTitle: Observable<String>

        let values: Observable<(name: String?, companyName: String?, tel: String?, email: String?)>
    }

    struct State: StateType {
        let bizCard: BehaviorRelay<BizCard?> = .init(value: nil)
        let bizCardImage: BehaviorRelay<UIImage?> = .init(value: nil)
    }

    struct Dependency: DependencyType {
        let router: BizCardDetailRouterInterface
        let mode: BizCardDetailPresentationMode
        let annotateImageAPI: AnnotateImageAPIInterface
        let bizCardAnnotateUseCase: BizCardAnnotateUseCaseInterface
        let bizCardFactory: BizCardFactoryInterface
        let bizCardStoreUseCase: BizCardStoreUseCaseInterface
        let dateFormatUseCase: DateFormatUseCaseInterface
    }

    static func bind(input: Input, state: State, dependency: Dependency, disposeBag: DisposeBag) -> Output {
        let isEditable: PublishRelay<Bool> = .init()
        let isLoading: PublishRelay<Bool> = .init()
        let showError: PublishRelay<String> = .init()
        let title: PublishRelay<String> = .init()
        let bizCardImage: PublishRelay<UIImage> = .init()
        let registeredDate: PublishRelay<String> = .init()
        let saveTitle: PublishRelay<String> = .init()

        let values: PublishRelay<(name: String?, companyName: String?, tel: String?, email: String?)> = .init()

        func ocrBizCard(image: UIImage) {
            // 画像をbase64にエンコードしたものをAPIに渡す
            guard let base64Data = image.pngData()?.base64EncodedString() else { return }
            dependency.annotateImageAPI.postAnnotateImage(imageBase64String: base64Data)
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe(
                    onSuccess: { annotateImageResponse in
                        guard let annotateImage = annotateImageResponse.responses.first else { return }
                        let annotateResult = dependency.bizCardAnnotateUseCase.annotate(for: annotateImage)
                        values.accept((annotateResult.name, annotateResult.comanyName, annotateResult.tel, annotateResult.email))
                        isLoading.accept(false)
                    },
                    onFailure: { _ in
                        showError.accept(R.string.localizable.error_message())
                    }
                )
                .disposed(by: disposeBag)
        }

        func loadBizCard(bizCardId: BizCardId) {
            if let image = dependency.bizCardStoreUseCase.fetchImage(id: bizCardId) {
                state.bizCardImage.accept(image)
                bizCardImage.accept(image)
            }

            if let bizCard = dependency.bizCardStoreUseCase.fetchBizCard(id: bizCardId) {
                state.bizCard.accept(bizCard)
                let dateText = dependency.dateFormatUseCase.formatToYYYYMM(date: bizCard.createdAt)
                registeredDate.accept(R.string.localizable.bizcard_registered_date(dateText))
                values.accept((bizCard.name, bizCard.companyName, bizCard.tel, bizCard.email))
            }
            isLoading.accept(false)
        }

        input.viewDidLoad
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)) // ユーザーの操作を阻害しない
            .subscribe(onNext: { _ in
                isLoading.accept(true)
                switch dependency.mode {
                case let .create(image):
                    isEditable.accept(true)
                    title.accept(R.string.localizable.bizcard_preview())
                    state.bizCardImage.accept(image)
                    bizCardImage.accept(image)
                    let dateText = dependency.dateFormatUseCase.formatToYYYYMM(date: .init())
                    registeredDate.accept(R.string.localizable.bizcard_registered_date(dateText))
                    saveTitle.accept(R.string.localizable.registration())
                    ocrBizCard(image: image)

                case let .edit(bizCardId):
                    isEditable.accept(true)
                    title.accept(R.string.localizable.bizcard_edit())
                    saveTitle.accept(R.string.localizable.save())
                    loadBizCard(bizCardId: bizCardId)

                case let .detail(bizCardId):
                    isEditable.accept(false)
                    title.accept(R.string.localizable.bizcard_detail())
                    loadBizCard(bizCardId: bizCardId)
                }
            })
            .disposed(by: disposeBag)

        input.viewWillAppear
            .subscribe(onNext: { _ in
                // 画面が表示されたらstateのbizCardIdを再読み込みする
                guard let bizCardId = state.bizCard.value?.id else { return }
                loadBizCard(bizCardId: bizCardId)
            })
            .disposed(by: disposeBag)

        input.didTapBackButton
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                dependency.router.navigate(.back)
            })
            .disposed(by: disposeBag)

        input.didTapSaveButton
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { name, companyName, tel, email in
                switch dependency.mode {
                case .create:
                    // 名刺画像が存在しない場合はエラーを出す
                    guard let bizCardImage = state.bizCardImage.value else {
                        showError.accept(R.string.localizable.error_message())
                        return
                    }

                    let newBizCard = dependency.bizCardFactory
                        .createBizCard(name: name?.presence, companyName: companyName?.presence, tel: tel?.presence, email: email?.presence)
                    state.bizCard.accept(newBizCard)
                    dependency.bizCardStoreUseCase.addImage(id: newBizCard.id, image: bizCardImage)
                    dependency.bizCardStoreUseCase.addBizCard(newBizCard)
                    dependency.router.navigate(.close)

                case .edit:
                    guard let bizCard = state.bizCard.value else { return }
                    let newBizCard = dependency.bizCardFactory
                        .editBizCard(of: bizCard, name: name?.presence, companyName: companyName?.presence, tel: tel?.presence, email: email?.presence)
                    // 名刺更新に失敗したらエラーを出す
                    let isSuccess = dependency.bizCardStoreUseCase.updateBizCard(newBizCard)
                    guard isSuccess else {
                        showError.accept(R.string.localizable.error_message())
                        return
                    }
                    state.bizCard.accept(newBizCard)
                    dependency.router.navigate(.back)
                case .detail:
                    fatalError("Invalid mode")
                }
            })
            .disposed(by: disposeBag)

        input.didTapEditButton
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                guard let bizCardId = state.bizCard.value?.id else { return }
                dependency.router.navigate(.edit(bizCardId))
            })
            .disposed(by: disposeBag)

        return .init(
            isEditable: isEditable.asObservable(),
            isLoading: isLoading.asObservable(),
            showError: showError.asObservable(),
            title: title.asObservable(),
            bizCardImage: bizCardImage.asObservable(),
            registeredDate: registeredDate.asObservable(),
            saveTitle: saveTitle.asObservable(),
            values: values.asObservable()
        )
    }
}
