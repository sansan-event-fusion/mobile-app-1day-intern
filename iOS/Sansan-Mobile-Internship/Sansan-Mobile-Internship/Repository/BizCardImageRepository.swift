//
//  BizCardImageRepository.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import UIKit

protocol BizCardImageRepositoryInterface {
    func fetchImage(id: BizCardId) -> UIImage?
    func addImage(id: BizCardId, image: UIImage)
}

/// 名刺画像をBizCardIdと紐づけてクラスプロパティで保持するクラス
final class BizCardImageOnMemoryRepository: BizCardImageRepositoryInterface {
    static var shared = BizCardImageOnMemoryRepository()

    private var images: [BizCardId: UIImage]

    init() {
        images = [:]
    }

    func fetchImage(id: BizCardId) -> UIImage? {
        return Self.shared.images[id]
    }

    func addImage(id: BizCardId, image: UIImage) {
        return Self.shared.images[id] = image
    }
}

