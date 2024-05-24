//
//  SplashView.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import SwiftUI

struct SplashView: View {
    typealias VM = SplashVM
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
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                Text("Splash!")
                    .font(.kr45b)
                    .foregroundStyle(.black)
                Spacer()
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .ignoresSafeArea()
        .background(Color.primary)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.coordinator.pushAuthView()
            }
        }
    }
}
