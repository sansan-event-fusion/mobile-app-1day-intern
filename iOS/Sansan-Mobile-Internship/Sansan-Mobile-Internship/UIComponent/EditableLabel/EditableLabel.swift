//
//  EditableLabel.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/24.
//  Copyright © 2023 Sansan. All rights reserved.
//

import UIKit

final class EditableLabel: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueTextField: UITextField!
    @IBOutlet private weak var underLineView: UIView!

    var titleText: String? {
        set {
            titleLabel.text = newValue
        }

        get {
            titleLabel.text
        }
    }

    var valueText: String? {
        set {
            valueTextField.text = newValue
        }

        get {
            valueTextField.text
        }
    }

    var valueIsEditable: Bool {
        set {
            valueTextField.isUserInteractionEnabled = newValue
            underLineView.isHidden = !newValue
        }

        get {
            valueTextField.isUserInteractionEnabled
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        let bundle = Bundle(for: type(of: self))
        guard let view = UINib(nibName: "EditableLabel", bundle: bundle)
            .instantiate(withOwner: self, options: nil)
            .first as? UIView else {
            abort()
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        titleLabel.font = .systemFont(ofSize: 14).scaled
        titleLabel.textColor = AppConstants.Color.sansanGray
        titleLabel.text = nil
        valueTextField.font = .systemFont(ofSize: 18).scaled
        valueTextField.textColor = .black
        valueTextField.text = nil
        underLineView.backgroundColor = AppConstants.Color.backGroundGray
    }
}
