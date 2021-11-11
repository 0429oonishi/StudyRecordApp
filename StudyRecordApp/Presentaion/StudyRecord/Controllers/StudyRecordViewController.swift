//
//  StudyRecordViewController.swift
//  StudyRecordApp
//
//  Created by 大西玲音 on 2021/06/04.
//

import UIKit
import RxSwift
import RxCocoa
// MARK: - ToDo リアルタイムで同期して更新する処理も実装する(realm)

protocol EditButtonSelectable {
    var isEdit: Bool { get }
    func deleteButtonDidTappped(isEmpty: Bool)
    func baseViewLongPressDidRecognized()
}

protocol StudyRecordVCDelegate: ScreenPresentationDelegate,
                                EditButtonSelectable {
}

final class StudyRecordViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var registerButton: CustomButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private let viewModel: StudyRecordViewModelType = StudyRecordViewModel()
    private let disposeBag = DisposeBag()
    weak var delegate: StudyRecordVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupRegisterButton()
        setupDescriptionLabel()
        setObserver()
        setupBindings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.inputs.viewWillAppear()
        
    }
    
    private func setupBindings() {
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.present(AdditionalStudyRecordViewController.self,
                                   modalPresentationStyle: .fullScreen)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                    case .presentEditStudyRecordVC(let row):
                        strongSelf.presentEditStudyRecordVC(row: row)
                    case .notifyLongPress:
                        strongSelf.delegate?.baseViewLongPressDidRecognized()
                    case .presentRecordDeleteAlert(let row):
                        strongSelf.presentDeleteAlert(row: row)
                    case .notifyDelete(let isEmpty):
                        strongSelf.delegate?.deleteButtonDidTappped(isEmpty: isEmpty)
                    case .reloadTableView:
                        strongSelf.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isHiddenTableView
            .drive(onNext: { [weak self] isHidden in
                guard let strongSelf = self else { return }
                strongSelf.tableView.isHidden = isHidden
                strongSelf.delegate?.screenDidPresented(screenType: .record,
                                                        isEnabledNavigationButton: !isHidden)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.items
            .bind(to: tableView.rx.items) { tableView, row, element in
                let cell = tableView.dequeueReusableCustomCell(with: RecordTableViewCell.self)
                let isEdit = self.delegate?.isEdit ?? false
                cell.configure(record: element.record,
                               studyTime: element.studyTime)
                cell.changeMode(isEdit: isEdit,
                                isEvenIndex: row.isMultiple(of: 2))
                cell.tag = row
                cell.delegate = self
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
}

// MARK: - func
private extension StudyRecordViewController {
    
    func presentEditStudyRecordVC(row: Int) {
        present(EditStudyRecordViewController.self,
                modalPresentationStyle: .fullScreen) { vc in
            vc.selectedRow = row
        }
    }
    
    func presentDeleteAlert(row: Int) {
        let alert = Alert.create(message: L10n.doYouReallyWantToDeleteThis)
            .addAction(title: L10n.delete, style: .destructive) {
                self.viewModel.inputs.recordDeleteAlertDeleteButtonDidTapped(row: row)
                self.dismiss(animated: true)
            }
            .addAction(title: L10n.close) {
                self.dismiss(animated: true)
            }
        present(alert, animated: true)
    }
    
}

// MARK: - UITableViewDelegate
extension StudyRecordViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
}

// MARK: - RecordTableViewCellDelegate
extension StudyRecordViewController: RecordTableViewCellDelegate {
    
    func baseViewTapDidRecognized(row: Int) {
        viewModel.inputs.baseViewTapDidRecognized(row: row)
    }
    
    func baseViewLongPressDidRecognized() {
        viewModel.inputs.baseViewLongPressDidRecognized()
    }
    
    func memoButtonDidTapped(row: Int) {
        viewModel.inputs.memoButtonDidTapped(row: row, tableView: tableView)
    }
    
    func deleteButtonDidTappped(row: Int) {
        viewModel.inputs.deleteButtonDidTappped(row: row)
    }
    
}

// MARK: - setup
private extension StudyRecordViewController {
    
    func setupTableView() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.registerCustomCell(RecordTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func setupRegisterButton() {
        registerButton.setTitle(L10n.register)
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.text = L10n.recordedDataIsNotRegistered
    }
    
    func setObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadLocalData),
                                               name: .reloadLocalData,
                                               object: nil)
    }
    
    @objc
    func reloadLocalData() {
        tableView.reloadData()
    }
    
}
