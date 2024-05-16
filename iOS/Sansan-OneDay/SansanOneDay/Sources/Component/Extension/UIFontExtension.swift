//
//  UIFontExtension.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import UIKit

extension UIFont {
    /// Dynamic Typeに対応するフォント
    var scaled: UIFont {
        return UIFontMetrics.default.scaledFont(for: self)
    }
}
