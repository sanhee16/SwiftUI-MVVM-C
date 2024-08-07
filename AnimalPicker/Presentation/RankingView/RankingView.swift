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
    
    @State private var currentLevel: Level = .easy
    
    private var safeTop: CGFloat { get { Util.safeTop() }}
    private var safeBottom: CGFloat { get { Util.safeBottom() }}
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Topbar("Single Game", type: .back) {
                    self.coordinator.pop()
                }
                drawSelector(geometry: geometry)
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(alignment: .leading, spacing: 0) {
                        if $vm.rankings.wrappedValue.isEmpty {
                            Text("No Ranking")
                                .font(.kr15m)
                                .foregroundStyle(Color.black)
                                .frame(width: geometry.size.width, alignment: .center)
                                .paddingVertical(20)
                        } else {
                            ForEach($vm.rankings.wrappedValue, id: \.self) { item in
                                rankingItem(rankingData: item)
                            }
                        }
                    }
                    .paddingVertical(16)
                })
                .layoutPriority(.greatestFiniteMagnitude)
                
                Divider()
                ZStack(alignment: .center, content: {
                    Image(currentLevel.buttonImage)
                        .resizable()
                        .frame(height: 48, alignment: .center)
                    
                    Text("Play \(currentLevel.rawValue) Level")
                        .font(.kr20b)
                        .foregroundStyle(Color.white)
                        .zIndex(1)
                })
                .contentShape(Rectangle())
                .onTapGesture {
                    self.coordinator.pushSingleGameView(level: currentLevel)
                }
                .padding(top: 14, leading: 8, bottom: 8, trailing: 8)
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .onAppear {
            vm.onAppear()
            vm.loadRankings(level: currentLevel)
        }
    }
    
    private func drawSelector(geometry: GeometryProxy) -> some View {
        HStack(alignment: .center, spacing: 0, content: {
            ForEach(vm.levels, id: \.self) { item in
                VStack(alignment: .center, spacing: 0, content: {
                    Text(item.rawValue)
                        .font(item == currentLevel ? .kr14b : .kr14r)
                        .foregroundStyle(item == currentLevel ? Color.black.opacity(0.9) : Color.gray.opacity(0.7))
                        .paddingVertical(10)
                    
                    Rectangle()
                        .foregroundStyle(item == currentLevel ? Color.black.opacity(0.9) : Color.gray.opacity(0.6))
                        .frame(width: geometry.size.width / CGFloat(vm.levels.count), height: 2, alignment: .center)
                })
                .frame(width: geometry.size.width / CGFloat(vm.levels.count), alignment: .center)
                .background(Color.white)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.currentLevel = item
                    vm.loadRankings(level: self.currentLevel)
                }
            }
        })
    }
    
    private func rankingItem(rankingData: RankingData) -> some View {
        HStack(alignment: .center, spacing: 0, content: {
            Text(rankingData.nickname)
                .font(.kr16b)
            Spacer()
            Text("Score: \(rankingData.score)")
                .font(.kr14r)
        })
        .padding(top: 10, leading: 12, bottom: 10, trailing: 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.white)
        )
        .padding(top: 5, leading: 12, bottom: 5, trailing: 12)
    }
}



