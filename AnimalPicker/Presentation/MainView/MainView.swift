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
                    
                    Text("MultiGame")
                        .font(.kr20b)
                        .foregroundStyle(Color.white)
                        .paddingVertical(12)
                        .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Level.multi.backgroundColor)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.coordinator.pushGameRoomListView()
                        }
                        .shadow(color: Level.multi.backgroundColor.opacity(0.75), radius: 3, x: 2, y: 2)
                        .paddingBottom(24)
                    
                    Text("Single Game")
                        .font(.kr17b)
                        .foregroundStyle(Color.black)
                        .paddingVertical(8)
                    
                    Text("Ranking")
                        .font(.kr20b)
                        .foregroundStyle(Color.black)
                        .paddingVertical(12)
                        .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.white)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.coordinator.pushRankingView()
                        }
                        .clipped()
                        .shadow(color: .black.opacity(0.25), radius: 3, x: 2, y: 2)
                        .paddingBottom(28)
                    
                    ForEach(vm.levels, id: \.self) { level in
                        Text(level.rawValue)
                            .font(.kr20b)
                            .foregroundStyle(Color.white)
                            .paddingVertical(12)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(level.backgroundColor)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.coordinator.pushSingleGameView(level: level)
                            }
                            .shadow(color: level.backgroundColor.opacity(0.75), radius: 3, x: 2, y: 2)
                            .paddingBottom(16)
                    }
                }
                .paddingHorizontal(20)
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
    }
}
