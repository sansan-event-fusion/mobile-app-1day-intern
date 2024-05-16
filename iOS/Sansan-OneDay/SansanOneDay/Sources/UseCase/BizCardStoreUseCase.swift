//
//  BizCardStoreUseCase.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/08.
//

import Combine
import Foundation
import UIKit.UIImage

protocol BizCardStoreUseCaseInterface {
    func fetchBizCards() async throws -> [BizCard]
    func fetchBizCard(id: BizCardID) async throws -> BizCard?
    func save(bizCard: BizCard) async throws

    func fetchBizCardImage(id: BizCardID) async throws -> UIImage?
    func save(bizCardImage: UIImage, for id: BizCardID) async throws
}

enum BizCardStoreUseCaseError: Error {
    case invalidImage

    var localizedDescription: String {
        switch self {
        case .invalidImage:
            return String(localized: "bizcardstoreusecase_error_invalid_image")
        }
    }
}

class BizCardStoreUseCase: BizCardStoreUseCaseInterface {
    private let bizCardRepository: BizCardRepositoryInterface

    init(bizCardRepository: BizCardRepositoryInterface) {
        self.bizCardRepository = bizCardRepository
    }

    func fetchBizCards() async throws -> [BizCard] {
        // from Realm
        try await bizCardRepository.fetchBizCards()
    }

    func fetchBizCard(id: BizCardID) async throws -> BizCard? {
        // from Realm
        try await bizCardRepository.fetchBizCard(id: id)
    }

    func save(bizCard: BizCard) async throws {
        // to Realm
        try await bizCardRepository.save(bizCard: bizCard)
    }

    func fetchBizCardImage(id: BizCardID) async throws -> UIImage? {
        // from Realm
        let imageData = try await bizCardRepository.fetchBizCardImageData(id: id)
        guard let imageData = imageData else {
            throw BizCardStoreUseCaseError.invalidImage
        }
        return UIImage(data: imageData)
    }

    func save(bizCardImage: UIImage, for id: BizCardID) async throws {
        // to Realm
        let imageData = bizCardImage.jpegData(compressionQuality: 1.0)
        guard let imageData = imageData else {
            throw BizCardStoreUseCaseError.invalidImage
        }
        try await bizCardRepository.save(bizCardImageData: imageData, for: id)
    }
}
