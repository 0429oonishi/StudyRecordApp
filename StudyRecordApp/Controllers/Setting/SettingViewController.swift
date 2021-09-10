//
//  SettingViewController.swift
//  ThemeColor-Sample
//
//  Created by 大西玲音 on 2021/06/28.
//

import UIKit

private enum RowType: Int, CaseIterable {
    case themeColor
    case darkMode
    case passcode
    case pushNotification
    case multilingual
    case evaluationApp
    case shareApp
    case reports
    case howToUseApp
    case backup
    case privacyPolicy
    case logout
    
    var title: String {
        switch self {
            case .themeColor: return "テーマカラー"
            case .darkMode: return "ダークモード"
            case .passcode: return "パスコード"
            case .pushNotification: return "プッシュ通知"
            case .multilingual: return "言語"
            case .howToUseApp: return "アプリの使い方"
            case .evaluationApp: return "アプリを評価する"
            case .shareApp: return "アプリを共有する"
            case .reports: return "ご意見、ご要望、不具合の報告"
            case .backup: return "バックアップ"
            case .privacyPolicy: return "プライバシーポリシー"
            case .logout: return "ログアウト"
                
        }
    }
}

protocol SettingVCDelegate: ScreenPresentationDelegate {
    
}

final class SettingViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    weak var delegate: SettingVCDelegate?
    private var userUseCase = UserUseCase(
        repository: UserRepository(
            dataStore: FirebaseUserDataStore()
        )
    )
    private let indicator = Indicator(kinds: PKHUDIndicator())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate?.screenDidPresented(screenType: .setting)
        
    }
    
}

// MARK: - func
private extension SettingViewController {
    
    func presentLogoutAlert() {
        let alert = Alert.create(title: "本当にログアウトしてもよろしいですか")
            .addAction(title: "ログアウト", style: .destructive) {
                self.indicator.show(.progress)
                self.userUseCase.logout { result in
                    switch result {
                        case .failure(let title):
                            self.indicator.flash(.error) {
                                self.showErrorAlert(title: title)
                            }
                        case .success:
                            self.indicator.flash(.success) {
                                self.presentLoginAndSignUpVC()
                            }
                    }
                }
            }
            .addAction(title: "閉じる")
        present(alert, animated: true)
    }
    
    func presentLoginAndSignUpVC() {
        present(LoginAndSignUpViewController.self,
                modalPresentationStyle: .fullScreen) { _ in
            self.delegate?.scroll(sourceScreenType: .setting,
                                  destinationScreenType: .record,
                                  completion: nil)
        }
    }
    
    func presentThemeColorActionSheet() {
        let alert = Alert.create(preferredStyle: .alert)
            .addAction(title: "デフォルト") {
                self.presentDefaultAlert()
            }
            .addAction(title: "カスタム") {
                self.present(ThemeColorViewController.self,
                             modalPresentationStyle: .fullScreen) { vc in
                    vc.colorConcept = nil
                    vc.containerType = .tile
                    vc.navTitle = "セルフ"
                }
            }
            .addAction(title: "オススメ") {
                self.present(ColorConceptViewController.self,
                             modalPresentationStyle: .fullScreen)
            }
            .addAction(title: "閉じる", style: .cancel)
        present(alert, animated: true)
    }
    
    func presentDefaultAlert() {
        let alert = Alert.create(title: "デフォルトカラーにしますか？")
            .addAction(title: "いいえ")
            .addAction(title: "はい") {
                UserDefaults.standard.save(color: nil, .main)
                UserDefaults.standard.save(color: nil, .sub)
                UserDefaults.standard.save(color: nil, .accent)
            }
        present(alert, animated: true)
    }
    
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowType = RowType.allCases[indexPath.row]
        switch rowType {
            case .themeColor:
                presentThemeColorActionSheet()
            case .darkMode:
                break
            case .passcode:
                break
            case .pushNotification:
                break
            case .multilingual:
                break
            case .evaluationApp:
                break
            case .shareApp:
                break
            case .reports:
                break
            case .howToUseApp:
                break
            case .backup:
                break
            case .privacyPolicy:
                break
            case .logout:
                break
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return RowType.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = RowType.allCases[indexPath.row]
        switch rowType {
            case .themeColor,
                 .multilingual,
                 .evaluationApp,
                 .shareApp,
                 .reports,
                 .howToUseApp,
                 .backup,
                 .privacyPolicy:
                let cell = tableView.dequeueReusableCustomCell(with: CustomTitleTableViewCell.self)
                cell.configure(titleText: rowType.title)
                return cell
            case .darkMode,
                 .passcode,
                 .pushNotification:
                let cell = tableView.dequeueReusableCustomCell(with: CustomSwitchTableViewCell.self)
                cell.configure(title: rowType.title, isOn: true)
                return cell
            case .logout:
                let cell = tableView.dequeueReusableCustomCell(with: CustomButtonTableViewCell.self)
                cell.configure(title: rowType.title)
                cell.onTapEvent = { self.presentLogoutAlert() }
                return cell
        }
    }
    
}

// MARK: - setup
private extension SettingViewController {
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCustomCell(CustomTitleTableViewCell.self)
        tableView.registerCustomCell(CustomSwitchTableViewCell.self)
        tableView.registerCustomCell(CustomButtonTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
    }
    
}
