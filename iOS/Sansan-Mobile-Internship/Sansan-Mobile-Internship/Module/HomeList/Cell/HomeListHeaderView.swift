//
//  HomeListHeaderView.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import UIKit

class HomeListHeaderView: UITableViewHeaderFooterView {
    private let titleLabel: UILabel = .init()

    static var reuseIdentifier: String {
        return "HomeListHeaderView"
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        contentView.backgroundColor = AppConstants.Color.backGroundGray

        titleLabel.font = .systemFont(ofSize: 14).scaled
        titleLabel.textColor = AppConstants.Color.sansanGray
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
            containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        titleLabel.text = ""
    }

    func configure(model: HomeListSectionModel) {
        titleLabel.text = model.dateText
    }
}
