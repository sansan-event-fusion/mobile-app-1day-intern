//
//  BizCardTableViewCell.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/05.
//

import UIKit

class BizCardTableViewCell: UITableViewCell {
    struct PresentationModel {
        let name: String?
        let companyName: String?
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var titleNameLabel: UILabel!
    @IBOutlet private weak var bizCardImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        nameLabel.setScaledFont()
        companyNameLabel.setScaledFont()
        titleNameLabel.setScaledFont()
        prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        companyNameLabel.text = nil
        titleNameLabel.text = nil
        bizCardImageView.image = nil
    }

    func apply(presentationModel: PresentationModel) {
        nameLabel.text = presentationModel.name
        companyNameLabel.text = presentationModel.companyName
//        titleNameLabel.text = presentationModel.titleName // 表示しない
    }

    func apply(image: UIImage?) {
        bizCardImageView.image = image
    }
}
