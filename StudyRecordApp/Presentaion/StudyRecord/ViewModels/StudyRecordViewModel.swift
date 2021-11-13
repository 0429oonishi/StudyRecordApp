//
//  StudyRecordViewModel.swift
//  StudyRecordApp
//
//  Created by 大西玲音 on 2021/11/11.
//

import Foundation
import RxSwift
import RxCocoa

protocol StudyRecordViewModelInput {
    func viewWillAppear()
    func baseViewTapDidRecognized(row: Int)
    func baseViewLongPressDidRecognized()
    func memoButtonDidTapped(row: Int)
    func deleteButtonDidTappped(row: Int)
    func recordDeleteAlertDeleteButtonDidTapped(row: Int)
}

protocol StudyRecordViewModelOutput: AnyObject {
    var event: Driver<StudyRecordViewModel.Event> { get }
    var items: Driver<[StudyRecordViewModel.Item]> { get }
    var isHiddenTableView: Driver<Bool> { get }
}

protocol StudyRecordViewModelType {
    var inputs: StudyRecordViewModelInput { get }
    var outputs: StudyRecordViewModelOutput { get }
}

final class StudyRecordViewModel {
    
    private let recordUseCase = RxRecordUseCase(
        repository: RxRecordRepository(
            dataStore: RealmRecordDataStore()
        )
    )
    private let eventRelay = PublishRelay<Event>()
    private let isHiddenTableViewRelay = PublishRelay<Bool>()
    private let itemRelay = BehaviorRelay<[Item]>(value: [])
    private var records: [Record] {
        itemRelay.value.map { $0.record }
    }
    private let disposeBag = DisposeBag()
    
    init() {
        recordUseCase.readRecords()
        recordUseCase.records
            .compactMap { [weak self] in self?.convertToItems(records: $0) }
            .subscribe(onNext: { [weak self] in self?.itemRelay.accept($0) })
            .disposed(by: disposeBag)
    }
    
    enum Event {
        case presentEditStudyRecordVC(Int)
        case presentRecordDeleteAlert(Int)
        case notifyLongPress
        case notifyDelete(Bool)
        case scrollToTop(row: Int, records: [Record])
    }
    struct Item {
        let record: Record
        let studyTime: (todayText: String,
                        totalText: String)
    }
    
    private func convertToItems(records: [Record]) -> [Item] {
        return records.enumerated().map { index, record in
            Item(
                record: record,
                studyTime: recordUseCase.getStudyTime(at: index)
            )
        }
    }
    
}

// MARK: - Input
extension StudyRecordViewModel: StudyRecordViewModelInput {
    
    func viewWillAppear() {
        isHiddenTableViewRelay.accept(records.isEmpty)
        itemRelay.accept(convertToItems(records: records))
        recordUseCase.readRecords()
    }
    
    func baseViewTapDidRecognized(row: Int) {
        eventRelay.accept(.presentEditStudyRecordVC(row))
    }
    
    func baseViewLongPressDidRecognized() {
        eventRelay.accept(.notifyLongPress)
    }
    
    func memoButtonDidTapped(row: Int) {
        recordUseCase.changeOpeningAndClosing(at: row)
        recordUseCase.readRecords()
        eventRelay.accept(.scrollToTop(row: row, records: records))
    }
    
    func deleteButtonDidTappped(row: Int) {
        eventRelay.accept(.presentRecordDeleteAlert(row))
    }
    
    func recordDeleteAlertDeleteButtonDidTapped(row: Int) {
        recordUseCase.deleteRecord(record: records[row])
        recordUseCase.readRecords()
        eventRelay.accept(.notifyDelete(records.isEmpty))
        isHiddenTableViewRelay.accept(records.isEmpty)
    }
    
}

// MARK: - Output
extension StudyRecordViewModel: StudyRecordViewModelOutput {
    
    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var items: Driver<[Item]> {
        itemRelay.asDriver()
    }
    
    var isHiddenTableView: Driver<Bool> {
        isHiddenTableViewRelay.asDriver(onErrorDriveWith: .empty())
    }
    
}

extension StudyRecordViewModel: StudyRecordViewModelType {
    
    var inputs: StudyRecordViewModelInput {
        return self
    }
    
    var outputs: StudyRecordViewModelOutput {
        return self
    }
    
}
