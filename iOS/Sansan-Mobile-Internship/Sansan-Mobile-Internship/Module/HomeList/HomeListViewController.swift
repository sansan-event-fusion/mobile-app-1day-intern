//
//  HomeListViewController.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/22.
//  Copyright © 2023 Sansan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

/// 名刺一覧画面
final class HomeListViewController: UIViewController {
    private typealias Section = HomeListSectionModel
    private typealias Item = HomeListItemModel
    private class DataSource: UITableViewDiffableDataSource<Section, Item> {}

    private let tableView: UITableView = .init(frame: .zero, style: .plain)
    private let disposeBag = DisposeBag()
    private var dataSource: DataSource!

    var viewModel: HomeListViewModelInterface!

    override func viewDidLoad() {
        view.backgroundColor = .white
        configureNavigation()
        configureTableView()
        configureCameraButton()
        binding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppear.accept(())
    }
}

// MARK: Binding
private extension HomeListViewController {
    /// ViewModelのOutputを購読する
    func binding() {
        viewModel.output.sectionItems
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, sectionItems in
                var snapShot = owner.dataSource.snapshot()
                snapShot.deleteAllItems()
                snapShot.appendSections(sectionItems)
                sectionItems.forEach { section in
                    snapShot.appendItems(section.items, toSection: section)
                }
                owner.dataSource.apply(snapShot, animatingDifferences: false)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: Layout
private extension HomeListViewController {
    /// Navigation周りの設定
    func configureNavigation() {
        navigationItem.titleView = UIImageView(image: R.image.sansan_navigation_logo())
        navigationItem.rightBarButtonItem = .init(
            image: R.image.add_bizcard(),
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem?.tintColor = .white

        navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.viewModel.input.didTapAddBizCardButton.accept(())
            })
            .disposed(by: disposeBag)
    }

    /// TableView周りの設定
    func configureTableView() {
        // 課題: TableViewをソートできるようにする
        // 実装例
        // 1. TableViewの上にソートバーのViewを差し込みレイアウトする (別途Viewの作成が必要)
        // 2. ソートバーがタップされたらViewModelにそのイベントを伝えるInputを定義する
        // 3. SortOptionのenumを定義する (case .createdAtASC: 登録日(昇順), case .createdAtDESC: 登録日(降順))
        // 4. ViewModelのOutputを介して､有効なソートオプションのリスト[SortOption]を流す
        // 5. View側でUIAlertControllerのActionSheetでソートオプションの選択肢を表示する
        // 6. UIAlertControllerの選択結果をViewModelに伝える｡
        // 7. ViewModelでソートオプションに従ってソートを行ってからOutputにsectionItemを流す

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.register(HomeListHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeListHeaderView.reuseIdentifier)
        tableView.register(R.nib.homeListBizCardTableViewCell)
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.homeListBizCardTableViewCell, for: indexPath)!
            cell.configure(model: item)
            cell.selectionStyle = .none
            cell.separatorInset = .zero
            return cell
        })

        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundColor = AppConstants.Color.backGroundGray
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .black
    }

    /// 名刺スキャンボタンの設定
    func configureCameraButton() {
        let cameraButton = R.nib.cameraButtonDropView(withOwner: self)!
        view.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            cameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        cameraButton.tapHandler = { [weak self] in
            self?.viewModel.input.didTapCameraButton.accept(())
        }
    }
}

// MARK: Delegate
extension HomeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: HomeListHeaderView.reuseIdentifier
        ) as! HomeListHeaderView
        let snapshot = dataSource.snapshot()
        guard let section = snapshot.sectionIdentifiers[safe: section] else { return nil }
        headerView.configure(model: section)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // estimate値はFigmaの高さ
        return 37
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // estimate値はFigmaの高さ
        return 91
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.input.didTapBizCard
            .accept(item.id)
    }
}
