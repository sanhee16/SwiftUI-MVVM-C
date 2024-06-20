//
//  EnterRoomView.swift
//  AnimalPicker
//
//  Created by Sandy on 6/4/24.
//

import Foundation
import SwiftUI
import UIKit

struct EnterRoomView: View {
    typealias VM = EnterRoomVM
    public static func vc(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, services: DIContainer.Services, roomData: RoomData) -> UIViewController {
        let vm = VM.init(interactors, services: services, roomData: roomData)
        let view = Self.init(vm: vm, coordinator: coordinator, roomData: roomData)
        let vc = BaseViewController.init(view)
        vc.view.backgroundColor = UIColor(.black.opacity(0.3))
        vc.controller.view.backgroundColor = UIColor(.black.opacity(0.3))
        vc.modalPresentationStyle = .overCurrentContext
        
        vc.attachViewModel(vm)
        return vc
    }
    
    @ObservedObject var vm: VM
    @ObservedObject var coordinator: AppCoordinator
    let roomData: RoomData
    
    static let WIDTH: CGFloat = UIScreen.main.bounds.width
    static let HEIGHT: CGFloat = UIScreen.main.bounds.height
    
    @State private var password: String = ""
    @State private var nickname: String = ""
    @State private var wrongPassword: Bool = false
    @State private var emptyNickname: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0, content: {
                Topbar("Enter Room", type: .close) {
                    self.coordinator.dismiss(false)
                }
                .paddingBottom(16)
                
                Text("Nickname *")
                    .font(.kr16b)
                    .foregroundStyle(Color.black)
                SingleBoxTextField(placeholder: "Enter the nickname", text: $nickname, keyboardType: .default, lengthLimit: 10) { _ in
                    self.emptyNickname = false
                }
                .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                .paddingBottom(6)
                Text(emptyNickname ? "Empty Nickname" : "")
                    .font(.kr12m)
                    .foregroundStyle(.red.opacity(0.9))
                    .paddingBottom(8)
                
                if let _ = roomData.password {
                    Text("Password")
                        .font(.kr16b)
                        .foregroundStyle(Color.black)
                    
                    SingleBoxTextField(placeholder: "Enter the Password", text: $password, keyboardType: .numberPad, lengthLimit: 4) { _ in
                        self.wrongPassword = false
                    }
                    .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                    .paddingBottom(6)
                    Text(wrongPassword ? "Wrong Password" : "")
                        .font(.kr12m)
                        .foregroundStyle(.red.opacity(0.9))
                        .paddingBottom(10)
                }
                
                Text("Enter Room")
                    .font(.kr18b)
                    .foregroundStyle(Color.white)
                    .paddingVertical(12)
                    .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(self.nickname.isEmpty ? Color.gray.opacity(0.8) : Color.blue.opacity(0.8))
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if nickname.isEmpty {
                            self.emptyNickname = true
                        } else if let roomPW = roomData.password, !String(roomPW).isEmpty {
                            if password == String(roomPW) {
                                self.vm.enterRoom(nickname: nickname)
                            } else {
                                HapticUtil.notification(.error).run()
                                self.wrongPassword = true
                            }
                        } else {
                            self.vm.enterRoom(nickname: nickname)
                        }
                    }
            })
            .frame(width: UIScreen.main.bounds.width - 40 - 28, alignment: .center)
            .padding(14)
        }
        .onChange(of: $vm.enterRoom.wrappedValue, perform: { value in
            if value {
                self.coordinator.dismiss(false)
            }
        })
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

