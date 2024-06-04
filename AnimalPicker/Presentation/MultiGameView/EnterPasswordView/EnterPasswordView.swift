//
//  EnterPasswordView.swift
//  AnimalPicker
//
//  Created by Sandy on 6/4/24.
//

import Foundation
import SwiftUI
import UIKit

struct EnterPasswordView: View {
    public static func vc(_ coordinator: AppCoordinator, roomId: String, correctPassword: String) -> UIViewController {
        let view = Self.init(coordinator: coordinator, correctPassword: correctPassword)
        let vc = BaseViewController.init(view)
        vc.view.backgroundColor = UIColor(.black.opacity(0.3))
        vc.controller.view.backgroundColor = UIColor(.black.opacity(0.3))
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
    
    @ObservedObject var coordinator: AppCoordinator
    
    static let WIDTH: CGFloat = UIScreen.main.bounds.width
    static let HEIGHT: CGFloat = UIScreen.main.bounds.height
    
    @State private var password: String = ""
    @State private var wrongPassword: Bool = false
    let correctPassword: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0, content: {
                Topbar("Enter Password", type: .close) {
                    self.coordinator.dismiss()
                }
                .paddingBottom(16)
                
                SingleBoxTextField(placeholder: "Password", text: $password, keyboardType: .numberPad, lengthLimit: 4) { _ in
                    self.wrongPassword = false
                }
                .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                .paddingBottom(6)
                Text(wrongPassword ? "Wrong Password" : "")
                    .font(.kr12m)
                    .foregroundStyle(.red.opacity(0.9))
                .paddingBottom(8)
                
                Text("Enter Room")
                    .font(.kr18b)
                    .foregroundStyle(Color.white)
                    .paddingVertical(12)
                    .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(self.password.isEmpty ? Color.gray.opacity(0.8) : Color.blue.opacity(0.8))
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if password == correctPassword {
                            
                        } else {
                            self.wrongPassword = true
                        }
                    }
            })
            .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
            .padding(14)
        }
        .frame(width: UIScreen.main.bounds.width - 40, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color.white)
        )
        .contentShape(Rectangle())
        .onTapGesture{
            
        }
    }
}

