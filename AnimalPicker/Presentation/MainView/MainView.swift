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
    private let rainbowColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .red]
    
    @State private var duckpos: CGRect = .zero
    @State var rotating = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Topbar("Animal Picker", backgroundColor: Color.clear)
                ZStack(alignment: .bottom, content: {
                    VStack(alignment: .leading, spacing: 14) {
                        ZStack(alignment: .center, content: {
                            Image("ButtonText_Large_Square_Orange")
                                .resizable()
                                .frame(height: 48, alignment: .center)
                            
                            Text("Multi Game")
                                .font(.kr20b)
                                .foregroundStyle(Color.white)
                                .zIndex(1)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.coordinator.pushGameRoomListView()
                        }
                        .paddingTop(30)
                        
                        ZStack(alignment: .center, content: {
                            Image("ButtonText_Large_Square_Green")
                                .resizable()
                                .frame(height: 48, alignment: .center)
                            
                            Text("Single Game")
                                .font(.kr20b)
                                .foregroundStyle(Color.white)
                                .zIndex(1)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.coordinator.pushRankingView()
                        }
                        Spacer()
                    }
                    .paddingHorizontal(20)
                    .frame(width: geometry.size.width, alignment: .leading)
                    .zIndex(3)
                    drawBackground()
                })
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: rainbowColors), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
    
    private func drawBackground() -> some View {
        ZStack(alignment: .bottom, content: {
            Image("dog")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .offset(x: 150, y: -180.0)
            
            Image("lizard")
                .resizable()
                .scaledToFit()
                .frame(width: 210)
                .offset(x: -80.0, y: -220.0)
            
            
            Image("fox")
                .resizable()
                .scaledToFit()
                .frame(width: 230)
                .rotationEffect(.degrees(rotating))
                .onAppear {
                    withAnimation(.linear(duration: 1)
                        .speed(0.15).repeatForever(autoreverses: false)) {
                            rotating = 360.0
                        }
                }
                .offset(x: -140, y: -5.0)
            
            Image("duck")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .offset(x: -40.0, y: -60.0)
                .rectReader($duckpos, in: .global)
            
            ZStack(alignment: .top, content: {
                Image("speech-bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .zIndex(1)
                Text("find M\ne!")
                    .font(.kr22m)
                    .zIndex(2)
                    .paddingTop(11)
            })
            .offset(x: ($duckpos.wrappedValue.minX) - 60, y: -($duckpos.wrappedValue.size.height))
            
            Image("bonobono")
                .resizable()
                .scaledToFit()
                .frame(width: 210)
                .offset(x: 130, y: 5.0)
        })
        .offset(x: 0.0, y: 30.0)
    }
}
