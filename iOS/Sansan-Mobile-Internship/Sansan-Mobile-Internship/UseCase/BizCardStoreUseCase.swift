//
//  BizCardStoreUseCase.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import UIKit

protocol BizCardStoreUseCaseInterface {
    func fetchBizCards() -> [BizCard]
    func fetchBizCard(id: BizCardId) -> BizCard?
    func addBizCard(_ bizCard: BizCard)
    func updateBizCard(_ bizCard: BizCard) -> Bool
    func fetchImage(id: BizCardId) -> UIImage?
    func addImage(id: BizCardId, image: UIImage)
}

/// 名刺情報をRepositoryと読み書きするUseCase
struct BizCardStoreUseCase: BizCardStoreUseCaseInterface {
    private let bizCardRepository: BizCardRepositoryInterface
    private let bizCardImageRepository: BizCardImageRepositoryInterface

    init(
        bizCardRepository: BizCardRepositoryInterface,
        bizCardImageRepository: BizCardImageRepositoryInterface
    ) {
        self.bizCardRepository = bizCardRepository
        self.bizCardImageRepository = bizCardImageRepository
    }

    func fetchBizCards() -> [BizCard] {
        return bizCardRepository.fetchBizCards()
    }

    func fetchBizCard(id: BizCardId) -> BizCard? {
        return bizCardRepository.fetchBizCard(id: id)
    }

    func addBizCard(_ bizCard: BizCard) {
        bizCardRepository.addBizCard(bizCard)
    }

    func updateBizCard(_ bizCard: BizCard) -> Bool {
        return bizCardRepository.updateBizCard(bizCard)
    }

    func fetchImage(id: BizCardId) -> UIImage? {
        return bizCardImageRepository.fetchImage(id: id)
    }

    func addImage(id: BizCardId, image: UIImage) {
        bizCardImageRepository.addImage(id: id, image: image)
    }
}
