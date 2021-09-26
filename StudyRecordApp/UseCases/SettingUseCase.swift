//
//  SettingUseCase.swift
//  StudyRecordApp
//
//  Created by 大西玲音 on 2021/09/11.
//

import Foundation

final class SettingUseCase {
    
    private let repository: SettingRepositoryProtocol
    init(repository: SettingRepositoryProtocol) {
        self.repository = repository
    }
    
    var setting: Setting {
        if repository.readAll().isEmpty {
            let setting = Setting(isDarkMode: false,
                                  darkModeSettingType: .app,
                                  isPasscodeSetted: false,
                                  passcode: "",
                                  isPushNotificationSetted: true,
                                  language: .japanese,
                                  identifier: UUID().uuidString)
            repository.create(setting: setting)
            return setting
        }
        return repository.read(at: 0)
    }
    
    func update(setting: Setting) {
        repository.update(setting: setting)
    }
    
    func change(isDarkMode: Bool) {
        let newSetting = Setting(isDarkMode: isDarkMode,
                                 darkModeSettingType: setting.darkModeSettingType,
                                 isPasscodeSetted: setting.isPasscodeSetted,
                                 passcode: setting.passcode,
                                 isPushNotificationSetted: setting.isPushNotificationSetted,
                                 language: setting.language,
                                 identifier: setting.identifier)
        repository.update(setting: newSetting)
    }
    
    func change(darkModeSettingType: DarkModeSettingType) {
        let newSetting = Setting(isDarkMode: setting.isDarkMode,
                                 darkModeSettingType: darkModeSettingType,
                                 isPasscodeSetted: setting.isPasscodeSetted,
                                 passcode: setting.passcode,
                                 isPushNotificationSetted: setting.isPushNotificationSetted,
                                 language: setting.language,
                                 identifier: setting.identifier)
        repository.update(setting: newSetting)
    }
    
    func change(isPasscodeSetted: Bool) {
        let newSetting = Setting(isDarkMode: setting.isDarkMode,
                                 darkModeSettingType: setting.darkModeSettingType,
                                 isPasscodeSetted: isPasscodeSetted,
                                 passcode: setting.passcode,
                                 isPushNotificationSetted: setting.isPushNotificationSetted,
                                 language: setting.language,
                                 identifier: setting.identifier)
        repository.update(setting: newSetting)
    }
    
    func change(isPushNotificationSetted: Bool) {
        let newSetting = Setting(isDarkMode: setting.isDarkMode,
                                 darkModeSettingType: setting.darkModeSettingType,
                                 isPasscodeSetted: setting.isPasscodeSetted,
                                 passcode: setting.passcode,
                                 isPushNotificationSetted: isPushNotificationSetted,
                                 language: setting.language,
                                 identifier: setting.identifier)
        repository.update(setting: newSetting)
    }
    
    func change(language: Language) {
        let newSetting = Setting(isDarkMode: setting.isDarkMode,
                                 darkModeSettingType: setting.darkModeSettingType,
                                 isPasscodeSetted: setting.isPasscodeSetted,
                                 passcode: setting.passcode,
                                 isPushNotificationSetted: setting.isPushNotificationSetted,
                                 language: language,
                                 identifier: setting.identifier)
        repository.update(setting: newSetting)
    }
    
    var isPasscodeCreated: Bool {
        return !setting.passcode.isEmpty
    }
    
    func isSame(passcode: String) -> Bool {
        return setting.passcode == passcode
    }
    
    func create(passcode: String) {
        updatePasscode(passcode: passcode)
    }
    
    func update(passcode: String) {
        updatePasscode(passcode: passcode)
    }
    
    private func updatePasscode(passcode: String) {
        let newSetting = Setting(isDarkMode: setting.isDarkMode,
                                 darkModeSettingType: setting.darkModeSettingType,
                                 isPasscodeSetted: setting.isPasscodeSetted,
                                 passcode: passcode,
                                 isPushNotificationSetted: setting.isPushNotificationSetted,
                                 language: setting.language,
                                 identifier: setting.identifier)
        repository.update(setting: newSetting)
    }
    
}
