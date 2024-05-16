//
//  UILabelExtension.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import UIKit

extension UILabel {
    func setScaledFont() {
        adjustsFontForContentSizeCategory = true
        font = font.scaled
    }
}
