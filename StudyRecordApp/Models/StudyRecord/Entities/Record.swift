//
//  Record.swift
//  StudyRecordApp
//
//  Created by 大西玲音 on 2021/06/05.
//

import RealmSwift

// 共通の型
struct Record {
    var title: String
    var time: Time
    var isExpanded: Bool
    var graphColor: GraphColor
    var memo: String
    var order: Int
}

struct Time {
    var today: Int
    var total: Int
}

struct GraphColor {
    var redValue: CGFloat
    var greenValue: CGFloat
    var blueValue: CGFloat
    var alphaValue: CGFloat
}

// Realmに依存した型
final class RecordRealm: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var time: TimeRealm? = TimeRealm()
    @objc dynamic var isExpanded: Bool = false
    @objc dynamic var graphColor: GraphColorRealm? = GraphColorRealm()
    @objc dynamic var memo: String = ""
    @objc dynamic var order: Int = 0
}

final class TimeRealm: Object {
    @objc dynamic var today: Int = 0
    @objc dynamic var total: Int = 0
}

final class GraphColorRealm: Object {
    @objc dynamic var redValue: Float = 0.0
    @objc dynamic var greenValue: Float = 0.0
    @objc dynamic var blueValue: Float = 0.0
    @objc dynamic var alphaValue: Float = 0.0
}

extension Record {
    
    init(record: Record) {
        self.init(title: record.title,
                  time: record.time,
                  isExpanded: record.isExpanded,
                  graphColor: record.graphColor,
                  memo: record.memo,
                  order: record.order)
    }
    
}

 extension UIColor {
    
    convenience init(record: Record) {
        self.init(red: record.graphColor.redValue,
                  green: record.graphColor.greenValue,
                  blue: record.graphColor.blueValue,
                  alpha: record.graphColor.alphaValue)
    }
    
}

extension GraphColor {
    
    init(record: RecordRealm) {
        self.init(redValue: CGFloat(record.graphColor?.redValue ?? 0.0),
                  greenValue: CGFloat(record.graphColor?.greenValue ?? 0.0),
                  blueValue: CGFloat(record.graphColor?.blueValue ?? 0.0),
                  alphaValue: CGFloat(record.graphColor?.alphaValue ?? 0.0))
    }
    
    init(record: Record) {
        self.init(redValue: CGFloat(record.graphColor.redValue),
                  greenValue: CGFloat(record.graphColor.greenValue),
                  blueValue: CGFloat(record.graphColor.blueValue),
                  alphaValue: CGFloat(record.graphColor.alphaValue))
    }
    
    init(color: UIColor) {
        self.init(redValue: color.redValue,
                  greenValue: color.greenValue,
                  blueValue: color.blueValue,
                  alphaValue: color.alphaValue)
    }
    
}

