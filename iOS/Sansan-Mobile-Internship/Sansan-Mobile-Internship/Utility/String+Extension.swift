//
//  String+Extension.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/25.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation

extension String {
    public var presence: String? {
        isEmpty ? nil : self
    }
}
