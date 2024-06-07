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
    
    
    var body: some View {
        GeometryReader { geometry in
            
            if $vm.myStatus.wrappedValue == .clear {
                statusView()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Topbar("Multi-Game", type: .back) {
                    self.coordinator.pop()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 4, content: {
                        Text("Members")
                            .font(.kr18b)
                        Spacer()
                        Text("Ready")
                            .font(.kr15m)
                            .foregroundStyle(Color.white)
                            .padding(top: 8, leading: 10, bottom: 8, trailing: 10)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle($vm.myStatus.wrappedValue == .none ? Color.yellow : Color.gray)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                vm.onClickReady()
                            }
                        if vm.roomData.managerDeviceId == vm.deviceId {
                            Text("Start")
                                .font(.kr15m)
                                .foregroundStyle(Color.white)
                                .padding(top: 8, leading: 10, bottom: 8, trailing: 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(MultiGameStatus(rawValue: $vm.roomData.wrappedValue.status) == .ready ? Color.green : Color.gray)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    vm.onClickStart()
                                }
                        }
                    })
                    HStack(alignment: .center, spacing: 8, content: {
                        ForEach($vm.members.wrappedValue, id: \.self) { item in
                            Text(item.name)
                                .font(.kr15r)
                                .foregroundStyle(Color.black)
                                .padding(top: 8, leading: 10, bottom: 8, trailing: 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundColor(MultiGameStatus(rawValue: item.status) == .ready ? Color.yellow : Color.white)
                                        .shadow(color: .black.opacity(0.65), radius: 2, x: 1, y: 1)
                                )
                        }
                    })
                    .paddingVertical(8)
                    
                    if !$vm.items.wrappedValue.isEmpty {
                        ScrollView(.vertical, showsIndicators: false) {
                            GameItemView(
                                items: $vm.items.wrappedValue,
                                level: .multi) { item in
                                    vm.onLoadSuccess(item: item)
                                } onSelectItem: { item in
                                    vm.onSelectItem(item: item)
                                }
                        }
                        .paddingVertical(10)
                    }
                }
                .padding(top: 12, leading: 12, bottom: 12, trailing: 12)
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .onChange(of: $vm.isPop.wrappedValue, perform: { newValue in
            if newValue {
                self.coordinator.pop()
            }
        })
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
    }
    
    
    private func statusView() -> some View {
        VStack(alignment: .center, spacing: 8, content: {
            switch $vm.myStatus.wrappedValue {
            case .finish:
                Text("Rank")
                    .font(.kr32b)
                    .foregroundStyle(Color.red.opacity(0.9))
                
                // 랭킹
                VStack(alignment: .leading, spacing: 0) {
                    ForEach($vm.members.wrappedValue, id: \.self) { item in
                        if MultiGameStatus(rawValue: item.status) == .clear {
                            HStack(alignment: .center, spacing: 0, content: {
                                Text(item.name)
                                    .font(.kr16b)
                                    .foregroundStyle(Color.black)
                                
                                Spacer()
                                Text(String(format: "Time: %.1f", item.time) )
                                    .font(.kr16m)
                                    .foregroundStyle(Color.black)
                            })
                        }
                    }
                }
                .paddingHorizontal(80)
                .frame(width: UIScreen.main.bounds.size.width - 160, height: 340, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 6).foregroundStyle(Color.white))
                .paddingBottom(20)
                
                Text("Retry")
                    .font(.kr16m)
                    .foregroundStyle(Color.white)
                    .frame(width: 100, height: 40, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.red)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.reset()
                    }
                    .paddingVertical(20)
                
            case .clear:
                Text("Cleared!")
                    .font(.kr35b)
                    .foregroundStyle(Color.white)
                
                Text("Waiting others..")
                    .font(.kr15m)
                    .foregroundStyle(Color.black)
                    .paddingVertical(16)
                
            case .loading:
                Text("Loading...")
                    .font(.kr35b)
                    .foregroundStyle(Color.white)
                    .ignoresSafeArea()
            default:
                EmptyView()
            }
            
        })
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
        .background($vm.myStatus.wrappedValue == .loading ? Color.black.opacity(0.9) : Color.black.opacity(0.8))
        .zIndex(1)
    }
    
}
