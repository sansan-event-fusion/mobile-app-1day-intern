//
//  BizCardRepository.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import Foundation

protocol BizCardRepositoryInterface {
    func fetchBizCards() async throws -> [BizCard]
    func fetchBizCard(id: BizCardID) async throws -> BizCard?
    func save(bizCard: BizCard) async throws

    func fetchBizCardImageData(id: BizCardID) async throws -> Data?
    func save(bizCardImageData: Data, for id: BizCardID) async throws
}

class BizCardLocalRepository: BizCardRepositoryInterface {
    private let bizCardAccessor: BizCardAccessorInterface
    private let bizCardImageAccessor: BizCardImageAccessorInterface

    init(bizCardAccessor: BizCardAccessorInterface, bizCardImageAccessor: BizCardImageAccessorInterface) {
        self.bizCardAccessor = bizCardAccessor
        self.bizCardImageAccessor = bizCardImageAccessor
    }

    func fetchBizCards() throws -> [BizCard] {
        try bizCardAccessor.fetchBizCards()
    }

    func fetchBizCard(id: BizCardID) throws -> BizCard? {
        try bizCardAccessor.fetchBizCard(id: id)
    }

    func save(bizCard: BizCard) throws {
        Task {
            try await bizCardAccessor.save(bizCard: bizCard)
        }
    }

    func fetchBizCardImageData(id: BizCardID) throws -> Data? {
        try bizCardImageAccessor.fetchBizCardImageData(id: id)
    }

    func save(bizCardImageData: Data, for id: BizCardID) throws {
        Task {
            try await bizCardImageAccessor.save(bizCardImageData: bizCardImageData, for: id)
        }
    }
}
