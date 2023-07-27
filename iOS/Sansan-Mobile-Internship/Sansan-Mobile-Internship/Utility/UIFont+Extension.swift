//
//  UIFont+Extension.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import UIKit

extension UIFont {
    // Dynamicに対応するフォント
    var scaled: UIFont {
        return UIFontMetrics.default.scaledFont(for: self)
    }
}
