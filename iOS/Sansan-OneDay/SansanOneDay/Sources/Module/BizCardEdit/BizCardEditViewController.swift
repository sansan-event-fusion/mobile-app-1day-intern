//
//  BizCardEditViewController.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Combine
import SVProgressHUD
import UIKit

final class BizCardEditViewController: UIViewController {
    @IBOutlet private var bizCardImageView: UIImageView!
    @IBOutlet private var bizCardRegistedDateLabel: UILabel!

    @IBOutlet private var nameLabel: EditableLabel! {
        didSet {
            nameLabel.valueIsEditable = true
            nameLabel.titleText = String(localized: "bizcardedit_name_title")
            nameLabel.keyBoardType = .default
            nameLabel.handle { [weak self] text in
                self?.viewModel.input.editName.send(text)
            }
        }
    }

    @IBOutlet private var companyLabel: EditableLabel! {
        didSet {
            companyLabel.valueIsEditable = true
            companyLabel.titleText = String(localized: "bizcardedit_company_title")
            companyLabel.keyBoardType = .default
            companyLabel.handle { [weak self] text in
                self?.viewModel.input.editCompany.send(text)
            }
        }
    }

    @IBOutlet private var telLabel: EditableLabel! {
        didSet {
            telLabel.valueIsEditable = true
            telLabel.titleText = String(localized: "bizcardedit_tel_title")
            telLabel.keyBoardType = .phonePad
            telLabel.handle { [weak self] text in
                self?.viewModel.input.editTel.send(text)
            }
        }
    }

    @IBOutlet private var emailLabel: EditableLabel! {
        didSet {
            emailLabel.valueIsEditable = true
            emailLabel.titleText = String(localized: "bizcardedit_email_title")
            emailLabel.keyBoardType = .emailAddress
            emailLabel.handle { [weak self] text in
                self?.viewModel.input.editEmail.send(text)
            }
        }
    }

    @IBOutlet private var saveButton: UIButton! {
        didSet {
            saveButton.setTitle(String(localized: "bizcardedit_save_button"), for: .normal)
            saveButton.addAction(.init(handler: { [weak self] _ in
                self?.viewModel.input.save.send(())
            }), for: .touchUpInside)
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    var viewModel: BizCardEditViewModelInterface!

    init() {
        super.init(nibName: R.nib.bizCardEditViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        bind()
        viewModel.input.viewDidLoad.send(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

private extension BizCardEditViewController {
    func bind() {
        viewModel.output.title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.title = title
            }
            .store(in: &cancellables)

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
                bizCardRegistedDateLabel.text = String(localized: "bizcardedit_registed_date_title")
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
