//
//  UISearchBarExtension.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import UIKit

extension UISearchBar {
    func setTextColor(color: UIColor) {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.attributedText = NSAttributedString(string: self.text != nil ? self.text! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
        }
    }

    func setPlaceholderColor(color: UIColor) {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: color])
        }
    }

    func setTextFieldBackgroundColor(color: UIColor) {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = color
        }
    }

    func setIconColor(color: UIColor) {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            if let leftView = textField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = color
            }
        }
    }

    func setClearButtonColor(color: UIColor) {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                let image = clearButton.image(for: .highlighted)?.withRenderingMode(.alwaysTemplate)
                clearButton.setImage(image, for: .normal)
                clearButton.tintColor = color
            }
        }
    }
}
