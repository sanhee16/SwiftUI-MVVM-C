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
    
    @State private var roomName: String = ""
    @State private var nickname: String = ""
    @State private var password: String = ""
    
    @State private var emptyRoomname: Bool = false
    @State private var isSetPassword: Bool = false
    @State private var emptyNickname: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0, content: {
                Topbar("Create Game Room", type: .close) {
                    self.coordinator.dismiss(false)
                }
                .paddingBottom(16)
                
                Group {
                    Text("Room Name")
                        .font(.kr16b)
                        .foregroundColor(Color.black)
                    + Text(" *")
                        .font(.kr16b)
                        .foregroundColor(Color.red)
                }
                .paddingBottom(2)
                SingleBoxTextField(placeholder: "Enter the Room Name", text: $roomName) { _ in
                    self.emptyRoomname = false
                }
                .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                .paddingBottom(6)
                Text(emptyRoomname ? "Empty Room name" : "")
                    .font(.kr12m)
                    .foregroundStyle(.red.opacity(0.9))
                    .paddingBottom(8)
                Group {
                    Text("Nickname")
                        .font(.kr16b)
                        .foregroundColor(Color.black)
                    + Text(" *")
                        .font(.kr16b)
                        .foregroundColor(Color.red)
                }
                .paddingBottom(2)
                SingleBoxTextField(placeholder: "Enter the Nickname", text: $nickname, keyboardType: .default, lengthLimit: 10) { _ in
                    self.emptyNickname = false
                }
                .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                .paddingBottom(6)
                Text(emptyNickname ? "Empty Nickname" : "")
                    .font(.kr12m)
                    .foregroundStyle(.red.opacity(0.9))
                    .paddingBottom(8)

                
                Text("Password")
                    .font(.kr16b)
                    .paddingBottom(2)
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: isSetPassword ? "checkmark.square.fill" : "checkmark.square")
                        .resizable()
                        .foregroundColor(isSetPassword ? Color.blue.opacity(0.8) : Color.gray.opacity(0.8))
                        .frame(both: 26.0)
                        .onTapGesture {
                            self.isSetPassword.toggle()
                        }
                    
                    SingleBoxTextField(placeholder: "Enter the Password", text: $password, keyboardType: .numberPad, lengthLimit: 4) { _ in }
                        .onTapGesture {
                            self.isSetPassword = true
                        }
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
                            .foregroundStyle((self.roomName.isEmpty || self.nickname.isEmpty) ? Color.gray.opacity(0.8) : Color.blue.opacity(0.8) )
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if roomName.isEmpty {
                            self.emptyRoomname = true
                        } else if nickname.isEmpty {
                            self.emptyNickname = true
                        } else {
                            vm.onClickCreateRoom(roomName: roomName, password: password, nickname: nickname)
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
        .onAppear {
            vm.onAppear()
        }
        .onChange(of: $vm.isPop.wrappedValue, perform: { newValue in
            if newValue {
                self.coordinator.dismiss(false)
            }
        })
    }
}

