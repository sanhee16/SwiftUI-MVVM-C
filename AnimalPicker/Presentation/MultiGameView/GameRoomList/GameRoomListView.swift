//
//  GameRoomListView.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import SwiftUI

struct GameRoomListView: View {
    typealias VM = GameRoomListVM
    public static func vc(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, services: DIContainer.Services, completion: (()-> Void)? = nil) -> UIViewController {
        let vm = VM.init(interactors, services: services)
        let view = Self.init(vm: vm, coordinator: coordinator)
        let vc = BaseViewController.init(view, completion: completion)
        vc.attachViewModel(vm)
        
        return vc
    }
    
    @ObservedObject var vm: VM
    @ObservedObject var coordinator: AppCoordinator
    
    private var safeTop: CGFloat { get { Util.safeTop() }}
    private var safeBottom: CGFloat { get { Util.safeBottom() }}
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(alignment: .center, spacing: 0, content: {
                    Spacer()
                    if let myRoom = $vm.myRoom.wrappedValue {
                        Text("My Room")
                            .font(.kr20b)
                            .frame(width: 130, height: 50, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.green)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                
                            }
                            .paddingHorizontal(8)
                    } else {
                        Text("Create Room")
                            .font(.kr20b)
                            .frame(width: 130, height: 50, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.yellow)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.coordinator.presentCreateRoomView()
                            }
                            .paddingHorizontal(8)
                    }
                })
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    ForEach($vm.list.wrappedValue, id: \.self) { item in
                        drawRoom(room: item)
                    }
                })
                .paddingTop(30)
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .onAppear {
            vm.onAppear()
        }
        .onAppear {
            vm.onDisappear()
        }
    }
    
    private func drawRoom(room: RoomData) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(room.name)
                .font(.kr16b)
                .foregroundStyle(.black)
            
            HStack(alignment: .center, spacing: 0, content: {
                if let password = room.password {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .frame(width: 12.0, height: 16.0)
                }
                Spacer()
            })
        }
        .padding(top: 20, leading: 16, bottom: 20, trailing: 16)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.green.opacity(0.9))
        )
        .onTapGesture {
            if let password = room.password {
                self.coordinator.presentEnterPasswordView(roomId: room.id, correctPassword: String(password))
            }
        }
        .padding(top: 4, leading: 10, bottom: 12, trailing: 10)
    }
}


