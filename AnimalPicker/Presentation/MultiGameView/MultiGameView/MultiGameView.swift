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
            if $vm.myStatus.wrappedValue == .finish || $vm.myStatus.wrappedValue == .clear || $vm.myStatus.wrappedValue == .loading {
                statusView()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Topbar("Multi-Game", type: .back) {
                    self.coordinator.pop()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center, spacing: 4, content: {
                            Text("Members")
                                .font(.kr18b)
                            Spacer()
                            
                            if vm.roomData.managerId == vm.deviceId {
                                Text("Start")
                                    .font(.kr15m)
                                    .foregroundStyle(Color.white)
                                    .padding(top: 8, leading: 10, bottom: 8, trailing: 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundStyle(Color.green)
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
                                            .foregroundColor(Color.white)
                                            .shadow(color: .black.opacity(0.65), radius: 2, x: 1, y: 1)
                                    )
                            }
                        })
                        .paddingVertical(8)
                    }
                    .padding(top: 12, leading: 12, bottom: 12, trailing: 12)
                    
                    if !$vm.items.wrappedValue.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            if let answer = $vm.answer.wrappedValue {
                                Text("Select All of \(answer)!")
                                    .font(.kr18b)
                                    .paddingTop(16)
                                if let elapsedTime = $vm.elapsedTime.wrappedValue {
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
            if $vm.myStatus.wrappedValue == .finish {
                VStack(alignment: .center, spacing: 0, content: {
                    Text("Rank")
                        .font(.kr32b)
                        .foregroundStyle(Color.red.opacity(0.9))
                    
                    // 랭킹
                    ForEach($vm.members.wrappedValue, id: \.self) { item in
                        HStack(alignment: .center, spacing: 0, content: {
                            Text(item.name)
                                .font(.kr16b)
                                .foregroundStyle(Color.black)
                            
                            Spacer()
                            
                            Text(String(format: "%.2f", item.time) )
                                .font(.kr16m)
                                .foregroundStyle(Color.black)
                        })
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
                })
            } else if $vm.myStatus.wrappedValue == .clear {
                Text("Cleared!")
                    .font(.kr35b)
                    .foregroundStyle(Color.white)
                
                Text("Waiting others..")
                    .font(.kr15m)
                    .foregroundStyle(Color.black)
                    .paddingVertical(16)
            } else if $vm.myStatus.wrappedValue == .loading {
                Text("Loading...")
                    .font(.kr35b)
                    .foregroundStyle(Color.white)
                    .ignoresSafeArea()
            }
        })
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
        .background($vm.myStatus.wrappedValue == .loading ? Color.black.opacity(0.9) : Color.black.opacity(0.8))
        .zIndex(1)
    }
    
}
