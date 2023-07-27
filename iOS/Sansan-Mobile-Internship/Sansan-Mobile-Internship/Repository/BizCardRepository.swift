//
//  BizCardRepository.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation

protocol BizCardRepositoryInterface {
    func fetchBizCards() -> [BizCard]
    func fetchBizCard(id: BizCardId) -> BizCard?
    func addBizCard(_ bizCard: BizCard)
    func updateBizCard(_ bizCard: BizCard) -> Bool
}

/// 名刺情報をクラスプロパティで保持するクラス
final class BizCardOnMemoryRepository: BizCardRepositoryInterface {
    static var shared = BizCardOnMemoryRepository()

    private var bizCards: [BizCard]

    init() {
        bizCards = []
    }

    func fetchBizCards() -> [BizCard] {
        return Self.shared.bizCards
    }

    func fetchBizCard(id: BizCardId) -> BizCard? {
        return Self.shared.bizCards.first(where: { $0.id == id })
    }

    func addBizCard(_ bizCard: BizCard) {
        return Self.shared.bizCards.append(bizCard)
    }

    func updateBizCard(_ bizCard: BizCard) -> Bool {
        guard let index = Self.shared.bizCards.firstIndex(where: { $0.id == bizCard.id }) else {
            return false
        }

        Self.shared.bizCards[index] = bizCard
        return true
    }
}

