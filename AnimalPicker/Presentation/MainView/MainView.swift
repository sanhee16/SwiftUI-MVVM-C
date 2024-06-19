//
//  MainView.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import SwiftUI

struct MainView: View {
    typealias VM = MainVM
    public static func vc(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, completion: (()-> Void)? = nil) -> UIViewController {
        let vm = VM.init(interactors)
        let view = Self.init(vm: vm, coordinator: coordinator)
        let vc = BaseViewController.init(view, isAvailableToSwipe: false, completion: completion)
        vc.attachViewModel(vm)

        return vc
    }
    
    @StateObject var vm: VM
    @ObservedObject var coordinator: AppCoordinator
    
    private var safeTop: CGFloat { get { Util.safeTop() }}
    private var safeBottom: CGFloat { get { Util.safeBottom() }}
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Topbar("Animal Picker")
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Multi Game")
                        .font(.kr17b)
                        .foregroundStyle(Color.black)
                        .paddingVertical(8)
                    
                    ZStack(alignment: .center, content: {
                        Image("ButtonText_Large_Square_Orange")
                            .resizable()
                            .frame(height: 48, alignment: .center)
                        
                        Text("MultiGame")
                            .font(.kr20b)
                            .foregroundStyle(Color.white)
                            .zIndex(1)
                    })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.coordinator.pushGameRoomListView()
                    }
                    .paddingBottom(24)
                    
                    Text("Single Game")
                        .font(.kr17b)
                        .foregroundStyle(Color.black)
                        .paddingVertical(8)
                    
                    ZStack(alignment: .center, content: {
                        Image("ButtonText_Large_Square_Gray")
                            .resizable()
                            .frame(height: 48, alignment: .center)
                        
                        Text("Ranking")
                            .font(.kr20b)
                            .foregroundStyle(Color.white)
                            .zIndex(1)
                    })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.coordinator.pushRankingView()
                    }
                    .paddingBottom(24)
                    
                    ForEach(vm.levels, id: \.self) { level in
                        ZStack(alignment: .center, content: {
                            Image(level.buttonImage)
                                .resizable()
                                .frame(height: 48, alignment: .center)
                            
                            Text(level.rawValue)
                                .font(.kr20b)
                                .foregroundStyle(Color.white)
                                .zIndex(1)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.coordinator.pushSingleGameView(level: level)
                        }
                        .paddingBottom(8)
                    }
                }
                .paddingHorizontal(20)
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
    }
}
