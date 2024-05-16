//
//  BizCardDetailViewController.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Combine
import SVProgressHUD
import UIKit

final class BizCardDetailViewController: UIViewController {
    @IBOutlet private var bizCardImageView: UIImageView!
    @IBOutlet private var bizCardRegistedDateLabel: UILabel!

    @IBOutlet private var nameLabel: EditableLabel! {
        didSet {
            nameLabel.valueIsEditable = false
            nameLabel.titleText = String(localized: "bizcarddetail_name_title")
        }
    }

    @IBOutlet private var companyLabel: EditableLabel! {
        didSet {
            companyLabel.valueIsEditable = false
            companyLabel.titleText = String(localized: "bizcarddetail_company_title")
        }
    }

    @IBOutlet private var telLabel: EditableLabel! {
        didSet {
            telLabel.valueIsEditable = false
            telLabel.titleText = String(localized: "bizcarddetail_tel_title")
        }
    }

    @IBOutlet private var emailLabel: EditableLabel! {
        didSet {
            emailLabel.valueIsEditable = false
            emailLabel.titleText = String(localized: "bizcarddetail_email_title")
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    var viewModel: BizCardDetailViewModelInterface!

    init() {
        super.init(nibName: R.nib.bizCardDetailViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "bizcarddetail_navigation_title")
        let navigationEditButton = UIBarButtonItem(image: R.image.edit(), primaryAction: .init(handler: { [weak self] _ in
            self?.viewModel.input.tappedEdit.send(())
        }))
        navigationItem.rightBarButtonItem = navigationEditButton
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.largeTitleDisplayMode = .never
        viewModel.input.viewAppear.send(())
    }
}

private extension BizCardDetailViewController {
    func bind() {
        viewModel.output.loading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            }
            .store(in: &cancellables)

        viewModel.output.error
            .receive(on: DispatchQueue.main)
            .sink { errorText in
                SVProgressHUD.showError(withStatus: errorText)
            }
            .store(in: &cancellables)

        viewModel.output.bizCard
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bizCard in
                guard let self else { return }
                nameLabel.valueText = bizCard.name
                companyLabel.valueText = bizCard.companyName
                telLabel.valueText = bizCard.tel
                emailLabel.valueText = bizCard.email
                bizCardRegistedDateLabel.text = String(localized: "bizcarddetail_registed_date_title")
                    + ": "
                    + bizCard.createdAt.string(format: .yyyyMMdd)
            }
            .store(in: &cancellables)

        viewModel.output.bizCardImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self else { return }
                bizCardImageView.image = image
            }
            .store(in: &cancellables)
    }
}
