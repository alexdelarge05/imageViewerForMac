//
//  File.swift
//  tief viewer
//
//  Created by Алексей Петров on 25.05.2021.
//

import Foundation
import Combine

final class CancelBag {
    var subscriptions = Set<AnyCancellable>()

    func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
}

extension AnyCancellable {

    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
