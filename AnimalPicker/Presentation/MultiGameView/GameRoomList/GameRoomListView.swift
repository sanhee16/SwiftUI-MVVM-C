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
                if let myRoom = $vm.myRoom.wrappedValue {
                    Text("My Room")
                        .font(.kr20b)
                        .padding(top: 10, leading: 20, bottom: 10, trailing: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.green)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            
                        }
                } else {
                    Text("Create Room")
                        .font(.kr20b)
                        .padding(top: 10, leading: 20, bottom: 10, trailing: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.yellow)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.coordinator.presentCreateRoomView()
                        }
                }
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    ForEach($vm.list.wrappedValue, id: \.self) { item in
                        Text(item.name)
                            .font(.kr16b)
                            .padding(top: 10, leading: 20, bottom: 10, trailing: 20)
                            .contentShape(Rectangle())
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
}


