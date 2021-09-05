//
//  StudyRecordTimeRecordViewController.swift
//  StudyRecordApp
//
//  Created by 大西玲音 on 2021/08/10.
//

import UIKit

protocol StudyRecordTimeRecordVCDelegate: AnyObject {
    func saveButtonDidTapped(history: History, isHistory: Bool)
    func deleteButtonDidTapped(index: Int)
    func editButtonDidTapped(index: Int, history: History)
}

final class StudyRecordTimeRecordViewController: UIViewController {
    
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var contentView: UIView!
    
    private enum DateType: Int, CaseIterable {
        case year
        case month
        case day
        case hour
        case minutes
        
        var component: Int {
            self.rawValue
        }
        var numbers: [Int] {
            switch self {
                case .year: return [Int](2020...2030)
                case .month: return [Int](1...12)
                case .day: return [Int](1...31)
                case .hour: return [Int](0...23)
                case .minutes: return [Int](0...59)
            }
        }
        func title(row: Int) -> String {
            switch self {
                case .year: return "\(self.numbers[row])年"
                case .month: return "\(self.numbers[row])月"
                case .day: return "\(self.numbers[row])日"
                case .hour: return "\(self.numbers[row])時間"
                case .minutes: return "\(self.numbers[row])分"
            }
        }
        var alignment: NSTextAlignment {
            switch self {
                case .year: return .right
                case .month: return .center
                case .day: return .left
                case .hour: return .center
                case .minutes: return .left
            }
        }
    }
    var history: History?
    var isHistoryDidTapped: Bool!
    var tappedHistoryIndex: Int?
    weak var delegate: StudyRecordTimeRecordVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPickerView()
        deleteButton.isHidden = !isHistoryDidTapped
        
    }
    
    @IBAction private func saveButtonDidTapped(_ sender: Any) {
        if isHistoryDidTapped {
            delegate?.editButtonDidTapped(index: tappedHistoryIndex!, history: history!)
        } else {
            delegate?.saveButtonDidTapped(history: history!, isHistory: isHistoryDidTapped)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func dismissButtonDidTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func deleteButtonDidTapped(_ sender: Any) {
        let alert = UIAlertController(title: "本当に削除しますか",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { _ in
            self.delegate?.deleteButtonDidTapped(index: self.tappedHistoryIndex!)
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - setup
private extension StudyRecordTimeRecordViewController {
    
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        if !isHistoryDidTapped {
            let year = Int(Converter.convertToString(from: Date(), format: "yyyy"))!
            let month = Int(Converter.convertToString(from: Date(), format: "M"))!
            let day = Int(Converter.convertToString(from: Date(), format: "d"))!
            history = History(year: year, month: month, day: day, hour: 0, minutes: 0)
        }
        setPickerViewDate()
    }
    
    func setPickerViewDate() {
        guard let history = history else { fatalError("historyがnil") }
        let selectingRowsAndComponents: [(row: Int, component: Int)] = [
            (row: DateType.year.numbers.firstIndex(of: history.year) ?? 0, component: DateType.year.component),
            (row: DateType.month.numbers.firstIndex(of: history.month) ?? 0, component: DateType.month.component),
            (row: DateType.day.numbers.firstIndex(of: history.day) ?? 0, component: DateType.day.component),
            (row: history.hour, component: DateType.hour.component),
            (row: history.minutes, component: DateType.minutes.component)
        ]
        selectingRowsAndComponents.forEach {
            pickerView.selectRow($0.row, inComponent: $0.component, animated: true)
        }
    }
    
}

// MARK: - UIPickerViewDelegate
extension StudyRecordTimeRecordViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        let dateType = DateType.allCases[component]
        switch dateType {
            case .year: history?.year = row + DateType.year.numbers.first!
            case .month: history?.month = row + DateType.month.numbers.first!
            case .day: history?.day = row + DateType.day.numbers.first!
            case .hour: history?.hour = row
            case .minutes: history?.minutes = row
        }
    }
    
}

// MARK: - UIPickerViewDataSource
extension StudyRecordTimeRecordViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return DateType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        let dateType = DateType.allCases[component]
        return dateType.numbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let view = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalTo: view.heightAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor),
            label.leftAnchor.constraint(equalTo: view.leftAnchor),
            label.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        let dateType = DateType.allCases[component]
        label.text = dateType.title(row: row)
        label.textAlignment = dateType.alignment
        return view
    }
    
}

// MARK: - HalfModalPresenterDelegate
extension StudyRecordTimeRecordViewController: HalfModalPresenterDelegate {
    
    var halfModalContentHeight: CGFloat {
        return contentView.frame.height
    }
    
}
