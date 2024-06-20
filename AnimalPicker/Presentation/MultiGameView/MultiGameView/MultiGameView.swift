//
//  MultiGameView.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import Kingfisher
import SwiftUI

struct MultiGameView: View {
    typealias VM = MultiGameVM
    public static func vc(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, services: DIContainer.Services, roomData: RoomData, completion: (()-> Void)? = nil) -> UIViewController {
        let vm = VM.init(interactors, services: services, roomData: roomData)
        let view = Self.init(vm: vm, coordinator: coordinator)
        let vc = BaseViewController.init(view, completion: completion)
        vc.attachViewModel(vm)
        
        return vc
    }
    
    @StateObject var vm: VM
    @ObservedObject var coordinator: AppCoordinator
    
    private var safeTop: CGFloat { get { Util.safeTop() }}
    private var safeBottom: CGFloat { get { Util.safeBottom() }}
    
    @State private var nickname: String = ""
    @State private var time: Float? = nil
    
    var body: some View {
        GeometryReader { geometry in
            statusView()
            
            VStack(alignment: .leading, spacing: 0) {
                Topbar("Multi-Game", type: .back) {
                    self.coordinator.pop()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    switch MultiGameStatus(rawValue: $vm.roomData.wrappedValue.status) {
                    case .ready, .clear:
                        Lobby()
                    default:
                        GamePage()
                    }
                }
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .onChange(of: $vm.isPop.wrappedValue, perform: { newValue in
            if newValue {
                self.coordinator.pop()
            }
        })
        .onChange(of: $vm.elapsedTime.wrappedValue, perform: { newValue in
            self.time = newValue
        })
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
    }
    
    private func Lobby() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 4, content: {
                Spacer()
                if vm.roomData.managerId == vm.deviceId {
                    HStack(alignment: .center, spacing: 10, content: {
                        ZStack(alignment: .center, content: {
                            Image("ButtonText_Large_Square_Green")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40, alignment: .center)
                            
                            Text("Start")
                                .font(.kr16b)
                                .foregroundStyle(Color.white)
                                .zIndex(1)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.onClickStart()
                        }
                        
                        ZStack(alignment: .center, content: {
                            Image("ButtonText_Large_Square_Gray")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40, alignment: .center)
                            
                            Text("Delete Room")
                                .font(.kr16b)
                                .foregroundStyle(Color.white)
                                .zIndex(1)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.onClickDeleteRoom()
                        }
                    })
                } else {
                    
                    ZStack(alignment: .center, content: {
                        Image("ButtonText_Large_Square_Red")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40, alignment: .center)
                        
                        Text("Quit Room")
                            .font(.kr16b)
                            .foregroundStyle(Color.white)
                            .zIndex(1)
                    })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.onClickQuitRoom()
                    }
                }
                
            })
            
            Text("Members")
                .font(.kr18b)
                .foregroundStyle(Color.black)
                .paddingBottom(2)
            HStack(alignment: .center, spacing: 8, content: {
                FlowView(items: $vm.members.wrappedValue.map({ member in
                    FlowItem(
                        text: member.name,
                        isRemoveable: (member.id != vm.deviceId) && ($vm.isManager.wrappedValue),
                        isStar: member.id == $vm.roomData.wrappedValue.managerId
                    ) {
                        vm.onClickDeleteMember(memberId: member.id)
                    }
                })).equatable()
            })
            .paddingVertical(8)
        }
        .padding(top: 12, leading: 12, bottom: 12, trailing: 12)
    }
    
    private func GamePage() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !$vm.items.wrappedValue.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    if let answer = $vm.answer.wrappedValue {
                        Text("Select All of \(answer)!")
                            .font(.kr18b)
                            .paddingTop(16)
                        if let elapsedTime = self.time {
                            Text("Elapsed Time: \(elapsedTime)")
                                .font(.kr16b)
                                .foregroundStyle(Color.black)
                                .paddingTop(4)
                        }
                    }
                }
                .paddingHorizontal(20.0)
                .paddingVertical(12)
                
                ScrollView(.vertical, showsIndicators: false) {
                    GameItemView(
                        items: $vm.items.wrappedValue,
                        level: vm.level) { item in
                            vm.onLoadSuccess(item: item)
                        } onSelectItem: { item in
                            vm.onSelectItem(item: item)
                        }
                }
                .paddingVertical(10)
            }
        }
    }
    
    
    private func statusView() -> some View {
        VStack(alignment: .center, spacing: 0, content: {
            if $vm.myStatus.wrappedValue == .finish {
                VStack(alignment: .center, spacing: 8) {
                    VStack(alignment: .center, spacing: 0, content: {
                        Text("Rank")
                            .font(.kr32b)
                            .foregroundStyle(Color.red.opacity(0.9))
                        
                        // 랭킹
                        VStack(alignment: .leading, spacing: 0, content: {
                            ForEach($vm.members.wrappedValue.sorted(by: { lhs, rhs in
                                lhs.time < rhs.time
                            }), id: \.self) { item in
                                HStack(alignment: .center, spacing: 0, content: {
                                    Text(item.name)
                                        .font(.kr16b)
                                        .foregroundStyle(Color.black)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.2f", item.time) )
                                        .font(.kr16m)
                                        .foregroundStyle(Color.black)
                                })
                                .paddingHorizontal(20)
                                .paddingVertical(4)
                            }
                            .paddingVertical(4)
                        })
                        .frame(width: UIScreen.main.bounds.size.width - 160, height: 340, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 6).foregroundStyle(Color.white))
                        .paddingHorizontal(80)
                        .paddingBottom(20)
                        
                        ZStack(alignment: .center, content: {
                            Image("Button_Round_Green")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40, alignment: .center)
                            
                            Text("Retry")
                                .font(.kr16b)
                                .foregroundStyle(Color.white)
                                .zIndex(1)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.reset()
                        }
                        .paddingVertical(20)
                    })
                }
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
                .background($vm.myStatus.wrappedValue == .loading ? Color.black.opacity(0.9) : Color.black.opacity(0.8))
                .zIndex(1)
            } else if $vm.myStatus.wrappedValue == .clear {
                VStack(alignment: .center, spacing: 8) {
                    Text("Cleared!")
                        .font(.kr35b)
                        .foregroundStyle(Color.white)
                    
                    Text("Waiting others..")
                        .font(.kr15m)
                        .foregroundStyle(Color.black)
                        .paddingVertical(16)
                }
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
                .background($vm.myStatus.wrappedValue == .loading ? Color.black.opacity(0.9) : Color.black.opacity(0.8))
                .zIndex(1)
            } else if $vm.myStatus.wrappedValue == .loading || $vm.myStatus.wrappedValue == .loadFinish {
                VStack(alignment: .center, spacing: 8) {
                    Text("Loading...")
                        .font(.kr35b)
                        .foregroundStyle(Color.white)
                        .ignoresSafeArea()
                }
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
                .background($vm.myStatus.wrappedValue == .loading ? Color.black.opacity(0.9) : Color.black.opacity(0.8))
                .zIndex(1)
            }
        })
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
        .background(Color.clear)
        .zIndex(1)
    }
    
}
