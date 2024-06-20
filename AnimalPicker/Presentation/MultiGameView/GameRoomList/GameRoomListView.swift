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
                Topbar("Multi-Game", type: .back) {
                    self.coordinator.pop()
                }
                
                //MARK: Participating Room
//                if let participatingRoom = $vm.participatingRoom.wrappedValue {
//                    Text("Participating Room")
//                        .font(.kr18b)
//                        .padding(8)
//                    
//                    participateButton(room: participatingRoom)
//                        .onTapGesture {
//                            self.coordinator.pushMultiGameView(roomData: participatingRoom)
//                        }
//                }

                //MARK: Total Room
                Text("Rooms")
                    .font(.kr18m)
                    .padding(top: 20, leading: 8, bottom: 8, trailing: 0)
                ScrollView(.vertical, showsIndicators: false, content: {
                    ForEach($vm.list.wrappedValue, id: \.self) { item in
                        drawRoomItem(room: item)
                    }
                })
                .layoutPriority(.greatestFiniteMagnitude)
                
                
                Divider()
                ZStack(alignment: .center, content: {
                    Image("ButtonText_Large_Square_Red")
                        .resizable()
                        .frame(height: 48, alignment: .center)
                    
                    Text($vm.participatingRoom.wrappedValue == nil ? "Create Room" : "Enter Room")
                        .font(.kr20b)
                        .foregroundStyle(Color.white)
                        .zIndex(1)
                })
                .contentShape(Rectangle())
                .onTapGesture {
                    if let participatingRoom = $vm.participatingRoom.wrappedValue {
                        self.coordinator.pushMultiGameView(roomData: participatingRoom)
                    } else {
                        self.coordinator.presentCreateRoomView()
                    }
                }
                .padding(top: 14, leading: 8, bottom: 8, trailing: 8)
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
    
    private func participateButton(room: RoomData?) -> some View {
        HStack(alignment: .center, spacing: 6, content: {
            if let _ = room?.password {
                Image(systemName: "lock.fill")
                    .resizable()
                    .frame(width: 12.0, height: 16.0)
            }
            Text(room?.name ?? "Create Room")
                .font(.kr16r)
                .foregroundStyle(.black)
        })
        .padding(top: 12, leading: 14, bottom: 12, trailing: 14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.yellow)
        )
        .contentShape(Rectangle())
        .paddingHorizontal(8)
    }
    
    private func drawRoomItem(room: RoomData) -> some View {
        HStack(alignment: .center, spacing: 6, content: {
            if let _ = room.password {
                Image(systemName: "lock.fill")
                    .resizable()
                    .frame(width: 12.0, height: 16.0)
            }
            Text(room.name)
                .font(.kr19b)
                .foregroundStyle(.black)
            Spacer()
            if $vm.participatingRoom.wrappedValue == nil {
                ZStack(alignment: .center, content: {
                    Image("ButtonText_Large_Square_Green")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30, alignment: .center)
                    Text("Join")
                        .font(.kr16b)
                        .foregroundStyle(Color.white)
                        .zIndex(1)
                })
                .contentShape(Rectangle())
                .onTapGesture {
                    if let _ = $vm.participatingRoom.wrappedValue {
                        
                    } else {
                        if let room = vm.isExistedMember(roomId: room.id) {
                            self.coordinator.pushMultiGameView(roomData: room)
                        } else {
                            self.coordinator.presentEnterRoomView(roomData: room) {
                                if let room = vm.isExistedMember(roomId: room.id) {
                                    self.coordinator.pushMultiGameView(roomData: room)
                                }
                            }
                        }
                    }
                }
            }
        })
        .padding(top: 12, leading: 14, bottom: 12, trailing: 14)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.white)
        )
    }
}


