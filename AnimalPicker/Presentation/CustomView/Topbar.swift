//
//  Topbar.swift
//  AnimalPicker
//
//  Created by Sandy on 5/27/24.
//

import Foundation
import SwiftUI

enum TopbarType: String {
    case back = "chevron.left"
    case close = "xmark"
    case none = ""
}

struct Topbar: View {
    static let PADDING: CGFloat = 10.0
    var title: AttributedString
    var type: TopbarType
    var textColor: Color
    var backgroundColor: Color
    var callback: (() -> Void)?
    
    init(_ title: String = "", type: TopbarType = .none, textColor: Color = .black, backgroundColor: Color = .white, onTap: (() -> Void)? = nil) {
        self.title = AttributedString(title)
        self.type = type
        self.callback = onTap
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    init(_ title: AttributedString = "", type: TopbarType = .none, textColor: Color = .black, backgroundColor: Color = .white, onTap: (() -> Void)? = nil) {
        self.title = title
        self.type = type
        self.callback = onTap
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack(alignment: .center, spacing: 0) {
                if type != .none {
                    Image(systemName: type.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(both: 16)
                        .padding(.leading, Self.PADDING)
                        .onTapGesture {
                            callback?()
                        }
                }
                Spacer()
            }
            Text(title)
                .font(.kr20b)
                .foregroundColor(textColor)
        }
        .frame(height: 52, alignment: .center)
        .background(backgroundColor)
    }
}
