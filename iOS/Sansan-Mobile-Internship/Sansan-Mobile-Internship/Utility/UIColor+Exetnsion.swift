//
//  UIColor+Exetnsion.swift
//  Sansan-Mobile-Internship
//
//  Created by Sansan on 2019/07/12.
//  Copyright © 2018 Sansan. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red255 red: Int, green255 green: Int, blue255 blue: Int, alpha: Double = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}
