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
                Topbar(vm.level.rawValue, type: .back) {
                    self.coordinator.pop()
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Members")
                        .font(.kr18b)
                    
                }
                .padding(top: 12, leading: 8, bottom: 12, trailing: 8)
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
