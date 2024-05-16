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
    
    var keyBoardType: UIKeyboardType {
        set {
            valueTextField.keyboardType = newValue
            valueTextField.returnKeyType = .done
        }
        
        get { 
            valueTextField.keyboardType
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

    func handle(didEdit handler: @escaping (String) -> Void) {
        valueTextField.addAction(.init(handler: { [weak self] _ in
            guard let self = self else {
                return
            }
            handler(self.valueTextField.text ?? "")
        }), for: .editingChanged)
    }

    private func sharedInit() {
        guard let view = R.nib.editableLabel.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
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
        titleLabel.textColor = R.color.black.panther()
        titleLabel.text = nil
        valueTextField.font = .systemFont(ofSize: 18).scaled
        valueTextField.textColor = .black
        valueTextField.text = nil
        underLineView.backgroundColor = R.color.line.grayGoat()
    }
}
