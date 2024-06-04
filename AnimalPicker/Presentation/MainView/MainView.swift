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
                
                Text("MultiGame")
                    .font(.kr14r)
                    .paddingVertical(15)
                    .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.green.opacity(0.8))
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.coordinator.pushGameRoomListView()
                    }
                    .paddingVertical(14)
                
                Text("Ranking")
                    .font(.kr14r)
                    .paddingVertical(15)
                    .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.green.opacity(0.8))
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.coordinator.pushRankingView()
                    }
                    .paddingVertical(14)
                
                Spacer()

                ForEach(vm.levels, id: \.self) { level in
                    Text(level.rawValue)
                        .font(.kr14r)
                        .paddingVertical(15)
                        .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.blue.opacity(0.8))
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.coordinator.pushSingleGameView(level: level)
                        }
                        .paddingBottom(20)
                }

                
                Spacer()
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
    }
}
