//
//  HomeListItemModel.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import UIKit

struct HomeListItemModel: Hashable {
    let id: BizCardId
    let name: String
    let companyName: String
    let bizCardImage: UIImage?

    init(bizCard: BizCard, image: UIImage?) {
        id = bizCard.id
        name = bizCard.name?.presence ?? "--"
        companyName = bizCard.companyName?.presence ?? "--"
        bizCardImage = image
    }
}

