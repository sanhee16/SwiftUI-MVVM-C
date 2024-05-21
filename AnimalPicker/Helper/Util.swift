//
//  Util.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import SwiftUI
import Combine

class Util {
    static let apiKey: String = ""
    
    static func primaryAttributedText(_ primaryText: String) -> AttributedString {
        var attributedString = AttributedString(primaryText)
        attributedString.foregroundColor = .primary
        return attributedString
    }
    
    static func colorAttributedText(_ text: String, color: Color) -> AttributedString {
        var attributedString = AttributedString(text)
        attributedString.foregroundColor = color
        return attributedString
    }
    
    static func primaryAttributedText(_ fullString: String, primaryText: String?) -> AttributedString {
        var attributedString = AttributedString(fullString)
        guard let primaryText = primaryText, let primaryRange = attributedString.range(of: primaryText) else { return attributedString }
        
        attributedString[primaryRange].foregroundColor = .primary
        return attributedString
    }
    
    static func safeAreaInsets() -> UIEdgeInsets? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
    }
    
    static func safeBottom() -> CGFloat {
        return safeAreaInsets()?.bottom ?? 0
    }
    
    static func safeTop() -> CGFloat {
        return safeAreaInsets()?.top ?? 0
    }
    
    static func getPercentage(selectionCount: Int?, totalCount: Int?) -> Float {
        guard let selectionCount = selectionCount, let totalCount = totalCount else {
            return 0.0
        }
        return Float(Float(selectionCount) / Float(totalCount)) * 100
    }
    
    static func copyToClipBoard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    static func pasteFromClipBoard() -> String? {
        return UIPasteboard.general.string
    }
    
    static func mediumWeek() -> String {
        let date = Date()
        let calendar = Calendar.current
        
        // 현재 날짜의 연도, 월, 주 가져오기
        let components = calendar.dateComponents([.year, .month, .weekOfMonth], from: date)
        
        if let month = components.month, let weekOfMonth = components.weekOfMonth {
            return "\(month)월 \(weekOfMonth)째주"
        }
        return ""
    }
    
    static func currentStartTime() -> Date? {
        let currentDate = Date()

        // 현재 날짜의 캘린더 가져오기
        let calendar = Calendar.current

        // 현재 날짜에서 시, 분, 초 구성 요소를 0으로 설정하기
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let midnightDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(from: components)!)

        return midnightDate
    }
    
    static func currentEndTime() -> Date? {
        let currentDate = Date()

        // 현재 날짜의 캘린더 가져오기
        let calendar = Calendar.current
        if let nextMidnightDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: currentDate)!) {
            // 현재 날짜의 23:59:59 가져오기
            let oneSecondBeforeMidnight = calendar.date(byAdding: .second, value: -1, to: nextMidnightDate)
            return oneSecondBeforeMidnight
        }
        return nil
    }
}

