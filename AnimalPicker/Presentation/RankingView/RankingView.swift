//
//  RankingView.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//


import Foundation
import SwiftUI

struct RankingView: View {
    typealias VM = RankingVM
    public static func vc(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, completion: (()-> Void)? = nil) -> UIViewController {
        let vm = VM.init(interactors)
        let view = Self.init(vm: vm, coordinator: coordinator)
        let vc = BaseViewController.init(view, completion: completion)
        vc.attachViewModel(vm)
        
        return vc
    }
    
    @ObservedObject var vm: VM
    @ObservedObject var coordinator: AppCoordinator
    
    @State private var nickname: String = ""
    @State private var password: String = ""
    
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
    }
}

