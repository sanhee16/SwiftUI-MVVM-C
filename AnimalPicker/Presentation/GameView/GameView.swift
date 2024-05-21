//
//  GameView.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import SwiftUI

struct GameView: View {
    typealias VM = GameVM
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

