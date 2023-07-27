//
//  BizCardFactory.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/25.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation

protocol BizCardFactoryInterface {
    func createBizCard(name: String?, companyName: String?, tel: String?, email: String?) -> BizCard
    func editBizCard(of bizCard: BizCard, name: String?, companyName: String?, tel: String?, email: String?) -> BizCard
}

/// 名刺情報(BizCard)を作成or編集するUseCase
struct BizCardFactory: BizCardFactoryInterface {
    init() {}

    func createBizCard(name: String?, companyName: String?, tel: String?, email: String?) -> BizCard {
        let bizCard = BizCard(
            id: .init(rawValue: UUID().uuidString),
            name: name,
            companyName: companyName,
            tel: tel,
            email: email,
            createdAt: .init()
        )
        return bizCard
    }

    func editBizCard(of bizCard: BizCard, name: String?, companyName: String?, tel: String?, email: String?) -> BizCard {
        let editedBizCard = BizCard(
            id: bizCard.id,
            name: name,
            companyName: companyName,
            tel: tel,
            email: email,
            createdAt: bizCard.createdAt
        )
        return editedBizCard
    }
}
