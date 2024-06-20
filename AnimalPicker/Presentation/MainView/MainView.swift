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
    
    @State private var duckpos: CGRect = .zero
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Topbar("Animal Picker", backgroundColor: Color.clear)
                ZStack(alignment: .bottom, content: {
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
            LinearGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
    
    private func drawBackground() -> some View {
        ZStack(alignment: .bottom, content: {
            Image("dog")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .offset(x: 140, y: -20.0)
            Image("duck")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .offset(x: -40.0, y: -80.0)
                .rectReader($duckpos, in: .global)
            
            ZStack(alignment: .top, content: {
                Image("speech-bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .zIndex(1)
                Text("find Me!")
                    .font(.kr20m)
                    .zIndex(2)
                    .paddingTop(15)
            })
            .offset(x: ($duckpos.wrappedValue.minX) - 60, y: -($duckpos.wrappedValue.size.height))
            
            Image("lizard")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .offset(x: 80.0, y: 0.0)
            Image("fox")
                .resizable()
                .scaledToFit()
                .frame(width: 230)
                .offset(x: -120, y: -10.0)
        })
        .offset(x: 0.0, y: 30.0)
    }
}
