//
//  PublisherExtension.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/15.
//

import Combine
import Foundation

extension Publisher where Self.Failure == Never {
    /// sinkメソッド内のクロージャをasync Taskで実行する。Cancellableのライフサイクルに合わせてTaskもCancelされる。
    func sinkByAsync(receiveValue: @escaping (Output) async -> Void) -> AnyCancellable {
        var task: Task<Void, Never>?

        let cancellable = sink { value in
            task = Task { await receiveValue(value) }
        }

        return AnyCancellable { [task, cancellable] in
            task?.cancel()
            cancellable.cancel()
        }
    }
}
