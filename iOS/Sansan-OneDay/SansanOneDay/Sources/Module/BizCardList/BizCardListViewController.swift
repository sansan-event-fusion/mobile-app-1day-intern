//
//  BizCardListViewController.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import Combine
import SVProgressHUD
import UIKit

struct BizCardListSectionModel: Hashable {
    let title: String
}

struct BizCardListItemModel: Hashable {
    let bizCard: BizCard
    let bizCardImage: UIImage?

    func hash(into hasher: inout Hasher) {
        hasher.combine(bizCard)
    }

    static func == (lhs: BizCardListItemModel, rhs: BizCardListItemModel) -> Bool {
        lhs.bizCard == rhs.bizCard
    }
}

final class BizCardListViewController: UIViewController {
    private typealias SnapShot = NSDiffableDataSourceSnapshot<BizCardListSectionModel, BizCardListItemModel>
    private typealias DataSource = UITableViewDiffableDataSource<BizCardListSectionModel, BizCardListItemModel>

    @IBOutlet private weak var tableView: UITableView!
    private var dataSource: DataSource!
    private var searchController: UISearchController!
    private var cancellable: Set<AnyCancellable> = .init()

    var viewModel: BizCardListViewModelInterface!

    init() {
        super.init(nibName: R.nib.bizCardListViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "bizcardlist_navigation_title")

        searchController = {
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.delegate = self
            let searchBar = searchController.searchBar
            searchBar.placeholder = String(localized: "bizcardlist_search_placeholder")
            searchBar.setTextFieldBackgroundColor(color: R.color.colorToken.searchBarBackground()!)
            return searchController
        }()
        searchController.hidesNavigationBarDuringPresentation = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true

        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bizCardTableViewCell, for: indexPath)!
            cell.apply(presentationModel: .init(name: item.bizCard.name, companyName: item.bizCard.companyName))
            cell.apply(image: item.bizCardImage)
            cell.separatorInset = .zero
            return cell
        })

        tableView.register(R.nib.bizCardTableViewCell)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
        tableView.dataSource = dataSource
        tableView.delegate = self

        configureCameraButton()
        bind()
        viewModel.input.searchText.send(nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.largeTitleDisplayMode = .always
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.input.viewDidAppear.send(())
    }

    private func bind() {
        viewModel.output.bizCards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bizCards in
                guard let self else { return }
                var snapShot = SnapShot()
                bizCards.forEach { arg in
                    let (section, items) = arg
                    snapShot.appendSections([section])
                    snapShot.appendItems(items, toSection: section)
                }
                dataSource.apply(snapShot)
            }
            .store(in: &cancellable)

        viewModel.output.loading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            }
            .store(in: &cancellable)
    }

    /// 名刺スキャンボタンの設定
    private func configureCameraButton() {
        let cameraButton = R.nib.hoverButtonView(withOwner: self)!
        view.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            cameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        cameraButton.set(icon: R.image.camera()!, title: String(localized: "bizcardlist_scan_title")) { [weak self] in
            self?.viewModel.input.tappedScan.send(())
        }
    }
}

extension BizCardListViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {}

    func willDismissSearchController(_ searchController: UISearchController) {}

    func updateSearchResults(for searchController: UISearchController) {
        // ここで検索文字列を受け取る
        // viewModel.input.searchText.send(searchController.searchBar.text)
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        // キャンセルボタンを押した時にここがよばれる
        searchController.dismiss(animated: true)
    }
}

extension BizCardListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SectionHeaderView.reuseIdentifier
        ) as! SectionHeaderView
        let snapshot = dataSource.snapshot()
        guard let section = snapshot.sectionIdentifiers[safe: section] else { return nil }
        headerView.apply(model: .init(text: section.title))
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // estimate値はFigmaの高さ
        return 36
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // estimate値はFigmaの高さ
        return 92
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.input.tappedBizCard.send(item.bizCard.id)
    }
}
