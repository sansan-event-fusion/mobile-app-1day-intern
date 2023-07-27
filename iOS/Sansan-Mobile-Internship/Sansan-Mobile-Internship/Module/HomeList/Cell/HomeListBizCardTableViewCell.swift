//
//  HomeListBizCardTableViewCell.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class HomeListBizCardTableViewCell: UITableViewCell {
    private let nameLabel: UILabel = .init()
    private let companyNameLabel: UILabel = .init()
    private let bizCardImageVIew: UIImageView = .init()

    private var tappedHandler: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }

    private func sharedInit() {
        contentView.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        contentView.backgroundColor = .white

        nameLabel.font = .boldSystemFont(ofSize: 16).scaled
        nameLabel.textColor = AppConstants.Color.sansanBlack
        nameLabel.numberOfLines = 0
        nameLabel.adjustsFontForContentSizeCategory = true

        companyNameLabel.font = .systemFont(ofSize: 12).scaled
        companyNameLabel.textColor = AppConstants.Color.sansanGray
        companyNameLabel.numberOfLines = 0
        companyNameLabel.adjustsFontForContentSizeCategory = true

        bizCardImageVIew.backgroundColor = AppConstants.Color.backGroundGray
        bizCardImageVIew.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bizCardImageVIew.heightAnchor.constraint(equalToConstant: 55),
            bizCardImageVIew.widthAnchor.constraint(equalToConstant: 88),
        ])
        bizCardImageVIew.adjustsImageSizeForAccessibilityContentSizeCategory = true

        let profileContainerView = UIStackView(arrangedSubviews: [
            nameLabel,
            companyNameLabel,
        ])
        profileContainerView.axis = .vertical
        profileContainerView.alignment = .top
        profileContainerView.spacing = 2

        let containerView = UIStackView(arrangedSubviews: [
            profileContainerView,
            bizCardImageVIew,
        ])
        containerView.spacing = 8
        containerView.alignment = .top
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    func configure(model: HomeListItemModel) {
        nameLabel.text = model.name
        companyNameLabel.text = model.companyName
        bizCardImageVIew.image = model.bizCardImage
    }
}
