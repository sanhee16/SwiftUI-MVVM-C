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
            VStack(alignment: .leading, spacing: 0) {
                Topbar("Multi-Game", type: .back) {
                    self.coordinator.pop()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Members")
                        .font(.kr18b)
                    HStack(alignment: .center, spacing: 8, content: {
                        ForEach($vm.members.wrappedValue, id: \.self) { item in
                            Text(item.name)
                                .font(.kr15r)
                                .foregroundStyle(Color.black)
                                .padding(top: 8, leading: 10, bottom: 8, trailing: 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundColor(item.id == vm.deviceId ? Color.blue.opacity(0.6) : Color.white)
                                        .shadow(color: .black.opacity(0.65), radius: 2, x: 1, y: 1)
                                )
                        }
                    })
                    .paddingVertical(8)
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
}
