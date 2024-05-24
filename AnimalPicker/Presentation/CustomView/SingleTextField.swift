//
//  SingleTextField.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//


import Foundation
import UIKit
import SwiftUI

struct SingleTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    @Binding var isShowText: Bool
    @Binding var textColor: UIColor
    
    private var isFirstResponder: Bool
    private var placeholder: String
    private var keyboardType: UIKeyboardType
    private var lengthLimit: Int?
    private var onDone: (()->())?
    
    init(
        placeholder: String = "",
        text: Binding<String>,
        isFocused: Binding<Bool>,
        isShowText: Binding<Bool> = .constant(true),
        textColor: Binding<UIColor> = .constant(UIColor.black),
        keyboardType: UIKeyboardType = .default,
        lengthLimit: Int? = nil,
        onDone: (() -> ())? = nil
    ) {
        self._text = text
        self._isFocused = isFocused
        self._isShowText = isShowText
        self._textColor = textColor
        
        self.isFirstResponder = false
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.lengthLimit = lengthLimit
        self.onDone = onDone
    }
    
    func makeUIView(context: UIViewRepresentableContext<SingleTextField>) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = self.placeholder
        textField.attributedPlaceholder = NSAttributedString(
                string: self.placeholder,
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
                ]
            )
        textField.isSecureTextEntry = !isShowText
        textField.keyboardType = self.keyboardType
        textField.autocapitalizationType = .none
        textField.font = .systemFont(ofSize: 13)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // onDone
        let bar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: context.coordinator, action: #selector(context.coordinator.onTapDone))
//        done.tintColor = UIColor.primary
        bar.items = [flexibleSpace, done]
        bar.sizeToFit()
        textField.inputAccessoryView = bar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<SingleTextField>) {
        uiView.text = self.text
        uiView.isSecureTextEntry = !isShowText
        if isFirstResponder && !context.coordinator.didFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didFirstResponder = true
        }
        uiView.textColor = textColor
    }
    
    func makeCoordinator() -> SingleTextField.Coordinator {
        Coordinator(parent: self, text: self.$text, isFocused: self.$isFocused, lengthLimit: self.lengthLimit, onDone: self.onDone)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SingleTextField
        @Binding var text: String
        @Binding var isFocused: Bool
        var didFirstResponder = false
        var lengthLimit: Int?
        var onDone: (()->())?
        
        init(parent: SingleTextField, text: Binding<String>, isFocused: Binding<Bool>, lengthLimit: Int?, onDone: (()->())?) {
            self.parent = parent
            self._text = text
            self._isFocused = isFocused
            self.lengthLimit = lengthLimit
            self.onDone = onDone
        }
        
        @objc func onTapDone() {
            // hide keyboard
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            self.isFocused = false
        }
        
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            let text = textField.text ?? ""
            
            if let limit = parent.lengthLimit, text.count > limit {
                let startIndex = text.startIndex
                let endIndex = text.index(startIndex, offsetBy: limit - 1)
                let fixedText = String(text[startIndex...endIndex])
                textField.text = fixedText
            }
            self.text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            self.isFocused = false
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {[weak self] in
                self?.isFocused = true
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {[weak self] in
                self?.isFocused = false
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.text = textField.text ?? ""
                self.onDone?()
                self.isFocused = false
            }
        }
    }
}
