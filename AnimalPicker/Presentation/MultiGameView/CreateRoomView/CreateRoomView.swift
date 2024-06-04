//
//  CreateRoomView.swift
//  AnimalPicker
//
//  Created by Sandy on 6/4/24.
//

import Foundation
import SwiftUI
import UIKit

struct CreateRoomView: View {
    typealias VM = CreateRoomVM
    public static func vc(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, services: DIContainer.Services) -> UIViewController {
        let vm = VM.init(interactors: interactors, services: services)
        let view = Self.init(vm: vm, coordinator: coordinator)
        let vc = BaseViewController.init(view)
        vc.attachViewModel(vm)
        vc.view.backgroundColor = UIColor(.black.opacity(0.3))
        vc.controller.view.backgroundColor = UIColor(.black.opacity(0.3))
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
    @ObservedObject var vm: VM
    @ObservedObject var coordinator: AppCoordinator
    
    static let WIDTH: CGFloat = UIScreen.main.bounds.width
    static let HEIGHT: CGFloat = UIScreen.main.bounds.height
    
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var isSetPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0, content: {
                Topbar("Create Game Room", type: .close) {
                    self.coordinator.dismiss()
                }
                .paddingBottom(16)
                
                
                SingleBoxTextField(placeholder: "Room Name", text: $name) { _ in }
                    .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                    .paddingBottom(8)
                
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: isSetPassword ? "checkmark.square.fill" : "checkmark.square")
                        .resizable()
                        .foregroundColor(isSetPassword ? Color.blue.opacity(0.8) : Color.gray.opacity(0.8))
                        .frame(both: 26.0)
                        .onTapGesture {
                            self.isSetPassword.toggle()
                        }
                    
                    SingleBoxTextField(placeholder: "Password", text: $password, keyboardType: .numberPad, lengthLimit: 4) { _ in }
                        .disabled(!isSetPassword)
                }
                .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                .paddingBottom(20)
                
                Text("Create Room")
                    .font(.kr18b)
                    .foregroundStyle(Color.white)
                    .paddingVertical(12)
                    .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(self.name.isEmpty ? Color.gray.opacity(0.8) : Color.blue.opacity(0.8) )
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.onClickCreateRoom(name: name, password: password)
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
        .onAppear {
            vm.onAppear()
        }
        .onChange(of: $vm.isPop.wrappedValue, perform: { newValue in
            if newValue {
                self.coordinator.dismiss()
            }
        })
    }
}

