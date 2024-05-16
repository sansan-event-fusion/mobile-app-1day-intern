//
//  SectionHeaderView.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {
    struct PresentationModel {
        let text: String
    }

    private let titleLabel: UILabel = .init()

    static var reuseIdentifier: String {
        return "SectionHeaderView"
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        contentView.backgroundColor = R.color.background.grayMainDove()

        titleLabel.font = .systemFont(ofSize: 14).scaled
        titleLabel.textColor = R.color.gray.mainElephant()
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        let containerView = UIStackView(arrangedSubviews: [titleLabel])
        containerView.axis = .vertical
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        titleLabel.text = nil
    }

    func apply(model: PresentationModel) {
        titleLabel.text = model.text
    }
}
