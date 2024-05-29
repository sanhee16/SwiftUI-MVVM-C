//
//  SingleBoxTextField.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation
import SwiftUI

struct SingleBoxTextField<Content>: View where Content: View {
    @Binding var text: String
    @Binding var textColor: UIColor
    @State var isFocused: Bool = false
    
    private let placeholder: String
    private let keyboardType: UIKeyboardType
    private let backgroundColor: Color
    private var boxSize: CGSize
    private var lengthLimit: Int?
    
    private let onChanged: ((String) -> ())
    private var rightView: (() -> Content)? = nil
    
    init(
        text: Binding<String>,
        placeholder: String,
        backgroundColor: Color = .white,
        keyboardType: UIKeyboardType = .default,
        lengthLimit: Int? = nil,
        boxSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 42),
        textColor: Binding<UIColor> = .constant(.black),
        onChanged: @escaping (String) -> Void,
        @ViewBuilder rightView: @escaping () -> Content
    ) {
        self._text = text
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.keyboardType = keyboardType
        self.lengthLimit = lengthLimit
        self.boxSize = boxSize
        self._textColor = textColor
        self.onChanged = onChanged
        self.rightView = rightView
    }
    
    init(
        placeholder: String,
        text: Binding<String>,
        backgroundColor: Color = .white,
        keyboardType: UIKeyboardType = .default,
        lengthLimit: Int? = nil,
        boxSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 42),
        textColor: Binding<UIColor> = .constant(.black),
        onChanged: @escaping (String) -> Void
    ) where Content == EmptyView {
        self.placeholder = placeholder
        self._text = text
        self.backgroundColor = backgroundColor
        self.keyboardType = keyboardType
        self.lengthLimit = lengthLimit
        self.boxSize = boxSize
        self._textColor = textColor
        self.onChanged = onChanged
        self.rightView = nil
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            GeometryReader(content: { geometry in
                ZStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 0) {
                        SingleTextField(
                            placeholder: placeholder,
                            text: $text,
                            isFocused: $isFocused,
                            keyboardType: keyboardType,
                            lengthLimit: lengthLimit) {
                                // onDone
                            }
                            .onChange(of: text, perform: { _ in
                                onChanged(text)
                            })
                            .accentColor(.black)
                            .font(.kr13r)
                        Spacer()
                        if let rightView = rightView {
                            rightView()
                        } else {
                            if !text.isEmpty {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.black.opacity(0.5))
                                    .frame(both: 26, aligment: .center)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        text.removeAll()
                                    }
                            }
                        }
                    }
                    .padding(top: 12, leading: 10, bottom: 12, trailing: 12)
                    .frame(width: geometry.size.width, height: self.boxSize.height, alignment: .trailing)
                }
                .border(isFocused ? .black : .gray, lineWidth: 1, cornerRadius: 2)
                .background(self.backgroundColor)
            })
            .frame(height: self.boxSize.height)
        }
    }
}
