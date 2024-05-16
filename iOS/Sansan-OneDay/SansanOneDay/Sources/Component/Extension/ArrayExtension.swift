//
//  ArrayExtension.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import Foundation

extension Array {
    /// subscript(safe:)
    subscript(safe index: Int) -> Element? {
        return (0..<count) ~= index ? self[index] : nil
    }

    /// Unique Array by KeyPath
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen: Set<T> = []
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }

    /// Unique Array by Element
    func unique() -> [Element] where Element: Hashable {
        return Array(Set(self))
    }
}
