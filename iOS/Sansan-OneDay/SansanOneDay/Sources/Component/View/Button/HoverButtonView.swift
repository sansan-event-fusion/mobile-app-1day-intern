//
//  HoverButtonView.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/24.
//  Copyright © 2023 Sansan. All rights reserved.
//

import UIKit

class HoverButtonView: UIView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!

    private var tapHandler: (() -> Void) = {}

    func set(icon: UIImage, title: String, tapHandler: @escaping () -> Void) {
        imageView.image = icon
        textLabel.text = title
        self.tapHandler = tapHandler
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.shadowOffset = .init(width: 0.0, height: 4)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.25
        layer.cornerRadius = 23
    }
}

// MARK: DropAnimation

extension HoverButtonView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dropIn()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        dropOut()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if isInView(point: touch.location(in: self)) {
            dropIn()
        } else {
            dropOut()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dropOut()
        guard let touch = touches.first else { return }
        if isInView(point: touch.location(in: self)) {
            tapHandler()
        }
    }

    private func isInView(point: CGPoint) -> Bool {
        guard point.x >= 0, point.x <= frame.width else { return false }
        guard point.y >= 0, point.y <= frame.height else { return false }
        return true
    }

    private func dropIn() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    private func dropOut() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
