//
//  BizCardDetailViewController.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/24.
//  Copyright © 2023 Sansan. All rights reserved.
//

import RxCocoa
import RxGesture
import RxSwift
import SVProgressHUD
import UIKit

class BizCardDetailViewController: UIViewController {
    @IBOutlet private var bizCardImageView: UIImageView!
    @IBOutlet private var bizCardRegistedDateLabel: UILabel!
    @IBOutlet private var nameLabel: EditableLabel!
    @IBOutlet private var companyLabel: EditableLabel!
    @IBOutlet private var telLabel: EditableLabel!
    @IBOutlet private var emailLabel: EditableLabel!
    @IBOutlet private var saveButton: UIButton!

    private let leftBarButton = UIBarButtonItem(image: R.image.back_navigation(), style: .plain, target: nil, action: nil)
    private let rightBarButton = UIBarButtonItem(image: R.image.edit_navigation(), style: .plain, target: nil, action: nil)

    private let disposeBag = DisposeBag()

    var viewModel: BizCardDetailViewModelInterface!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureView()
        binding()
        viewModel.input.viewDidLoad.accept(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppear.accept(())
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

private extension BizCardDetailViewController {
    func configureNavigation() {
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.setRightBarButton(rightBarButton, animated: true)
        navigationItem.rightBarButtonItem?.tintColor = .white
        setEdgeSwipeBackIsActive(to: true)
    }

    func configureView() {
        nameLabel.titleText = R.string.localizable.person_name()
        companyLabel.titleText = R.string.localizable.company_name()
        telLabel.titleText = R.string.localizable.tel_bumber()
        emailLabel.titleText = R.string.localizable.email_address()
    }

    func binding() {
        rightBarButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.viewModel.input.didTapEditButton.accept(())
            }
            .disposed(by: disposeBag)

        leftBarButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.viewModel.input.didTapBackButton.accept(())
            }
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(with: self) { owner, _ in
                let name = owner.nameLabel.valueText
                let companyName = owner.companyLabel.valueText
                let tel = owner.telLabel.valueText
                let email = owner.emailLabel.valueText
                owner.viewModel.input.didTapSaveButton.accept((name, companyName, tel, email))
            }
            .disposed(by: disposeBag)

        viewModel.output
            .isEditable
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isEditable in
                owner.rightBarButton.isEnabled = !isEditable
                owner.nameLabel.valueIsEditable = isEditable
                owner.companyLabel.valueIsEditable = isEditable
                owner.telLabel.valueIsEditable = isEditable
                owner.emailLabel.valueIsEditable = isEditable
                owner.saveButton.isHidden = !isEditable
            }
            .disposed(by: disposeBag)

        viewModel.output
            .title
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, title in
                owner.title = title
            }
            .disposed(by: disposeBag)

        viewModel.output
            .bizCardImage
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, bizCardImage in
                owner.bizCardImageView.image = bizCardImage
            }
            .disposed(by: disposeBag)

        viewModel.output
            .saveTitle
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, saveTitle in
                owner.saveButton.setTitle(saveTitle, for: .normal)
            }
            .disposed(by: disposeBag)

        viewModel.output
            .registeredDate
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, registeredDate in
                owner.bizCardRegistedDateLabel.text = registeredDate
            }
            .disposed(by: disposeBag)

        viewModel.output
            .isLoading
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { _, isLoading in
                if isLoading {
                    SVProgressHUD.show(withStatus: R.string.localizable.loading_message())
                } else {
                    SVProgressHUD.dismiss()
                }
            }
            .disposed(by: disposeBag)

        viewModel.output
            .showError
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { _, errorText in
                SVProgressHUD.showError(withStatus: errorText)
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
            .disposed(by: disposeBag)

        viewModel.output
            .values
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, values in
                owner.nameLabel.valueText = values.name
                owner.companyLabel.valueText = values.companyName
                owner.telLabel.valueText = values.tel
                owner.emailLabel.valueText = values.email
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Edge Swipe Gesture to Return
extension BizCardDetailViewController: UIGestureRecognizerDelegate {}
private extension BizCardDetailViewController {
    func setEdgeSwipeBackIsActive(to isActive: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = isActive ? self : nil
    }
}
