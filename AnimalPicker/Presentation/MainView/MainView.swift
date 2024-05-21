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
        let vm = VM.init(coordinator, interactors: interactors)
        let view = Self.init(vm: vm)
        let vc = BaseViewController.init(view, completion: completion)
        vc.attachViewModel(vm)

        return vc
    }
    @ObservedObject var vm: VM
    
    private var safeTop: CGFloat { get { Util.safeTop() }}
    private var safeBottom: CGFloat { get { Util.safeBottom() }}
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Text("Animal Picker")
                    .font(.kr20b)
                    .foregroundStyle(.black)
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
                            vm.onClickLevel(level: level)
                        }
                        .paddingBottom(20)
                }
                Spacer()
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
    }
}
