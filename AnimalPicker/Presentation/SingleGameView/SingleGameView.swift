//
//  SingleGameView.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Kingfisher
import SwiftUI

struct SingleGameView: View {
    typealias VM = SingleGameVM
    public static func vc(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, level: Level, completion: (()-> Void)? = nil) -> UIViewController {
        let vm = VM.init(interactors, level: level)
        let view = Self.init(vm: vm, coordinator: coordinator)
        let vc = BaseViewController.init(view, completion: completion)
        vc.attachViewModel(vm)
        
        return vc
    }
    
    @StateObject var vm: VM
    @ObservedObject var coordinator: AppCoordinator
    
    private var safeTop: CGFloat { get { Util.safeTop() }}
    private var safeBottom: CGFloat { get { Util.safeBottom() }}
    
    @State private var nickname: String = ""
    
    
    var body: some View {
        GeometryReader { geometry in
            if $vm.status.wrappedValue != .onGaming {
                statusView()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Topbar(vm.level.rawValue, type: .back) {
                    self.coordinator.pop()
                }
                VStack(alignment: .leading, spacing: 0, content: {
                    HStack(spacing: 0) {
                        Text(vm.level.rawValue)
                            .font(.kr24b)
                        Spacer()
                        Text("score: \($vm.score.wrappedValue)")
                            .font(.kr16m)
                        if $vm.bonusScore.wrappedValue > 0 {
                            Text("(Bonus: \($vm.bonusScore.wrappedValue))")
                                .font(.kr16m)
                                .foregroundStyle(Color.red.opacity(0.8))
                                .paddingLeading(4)
                        }
                    }
                    
                    if let answer = $vm.answer.wrappedValue {
                        Text("Select All of \(answer.plural)!")
                            .font(.kr18b)
                            .paddingTop(16)
                        if let leftTime = $vm.leftTime.wrappedValue {
                            Text("Left Time: \(leftTime)")
                                .font(leftTime < 4 ? .kr16b : .kr16r)
                                .foregroundStyle(leftTime < 4 ? Color.red : Color.black)
                                .paddingTop(4)
                        }
                    }
                })
                .paddingHorizontal(20.0)
                .paddingVertical(12)
                
                ScrollView(.vertical, showsIndicators: false) {
                    GameItemView(
                        items: vm.items,
                        level: vm.level) { item in
                            vm.onLoadSuccess(item: item)
                        } onSelectItem: { item in
                            vm.onSelectItem(item: item)
                        }
                }
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .onChange(of: $vm.isPop.wrappedValue, perform: { newValue in
            if newValue {
                self.coordinator.pop()
            }
        })
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        
    }
    private func statusView() -> some View {
        VStack(alignment: .center, spacing: 8, content: {
            switch $vm.status.wrappedValue {
            case .timeOut, .enterRanking:
                Text("Time's Up")
                    .font(.kr32b)
                    .foregroundStyle(Color.red.opacity(0.9))
                
                // 점수
                Text("Score: \($vm.score.wrappedValue + $vm.bonusScore.wrappedValue)")
                    .font(.kr28b)
                    .foregroundStyle(Color.white)
                
                // 랭킹 기록하기
                HStack(alignment: .center, spacing: 12, content: {
                    if $vm.status.wrappedValue == .enterRanking {
                        SingleBoxTextField(placeholder: "Nickname", text: $nickname, lengthLimit: 10) { _ in
                            
                        }
                        .onAppear {
                            nickname.removeAll()
                        }
                        
                        if $vm.status.wrappedValue == .enterRanking {
                            Text("Register")
                                .font(.kr16m)
                                .foregroundStyle(Color.white)
                                .frame(width: 100, height: 40, alignment: .center)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle($nickname.wrappedValue.isEmpty ? Color.gray : Color.yellow)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !$nickname.wrappedValue.isEmpty {
                                        vm.onUploadRanking($nickname.wrappedValue)
                                    }
                                }
                                .paddingBottom(10)
                        }
                    }
                })
                .frame(width: UIScreen.main.bounds.size.width - 100, height: 40, alignment: .center)
                .paddingTop(10)
                
                // 랭킹 기록
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 0, content: {
                        Spacer()
                        Text("Rankings")
                            .font(.kr24b)
                            .foregroundStyle(Color.black.opacity(0.85))
                        Spacer()
                    })
                    .paddingTop(10)
                    
                    if $vm.rankings.wrappedValue.isEmpty {
                        Spacer()
                        HStack(alignment: .center, spacing: 0, content: {
                            Spacer()
                            Text("No Ranking")
                                .font(.kr16m)
                                .foregroundStyle(Color.black.opacity(0.8))
                            Spacer()
                        })
                        Spacer()
                    } else {
                        ScrollView(.vertical, showsIndicators: false, content: {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach($vm.rankings.wrappedValue.indices, id: \.self) { idx in
                                    rankingItem(rankingData: $vm.rankings.wrappedValue[idx], idx: idx)
                                    if idx < $vm.rankings.wrappedValue.count - 1 {
                                        Rectangle()
                                            .frame(height: 1, alignment: .center)
                                            .foregroundStyle(Color.black.opacity(0.15))
                                            .paddingHorizontal(12)
                                    }
                                }
                            }
                            .paddingVertical(12)
                        })
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width - 100, height: 340, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 6).foregroundStyle(Color.white))
                .paddingBottom(20)
                
                Text("Retry")
                    .font(.kr16m)
                    .foregroundStyle(Color.white)
                    .frame(width: 100, height: 40, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.red)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.reset()
                    }
                    .paddingVertical(20)
                
            case .clear:
                Text("Cleared!")
                    .font(.kr35b)
                    .foregroundStyle(Color.white)
                
                HStack(alignment: .center, spacing: 12, content: {
                    Text("Next")
                        .font(.kr15m)
                        .foregroundStyle(Color.black)
                        .frame(width: 100, height: 40, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.yellow)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.nextLevel()
                        }
                })
            case .loading:
                Text("Loading...")
                    .font(.kr35b)
                    .foregroundStyle(Color.white)
                    .ignoresSafeArea()
            default:
                EmptyView()
            }
            
        })
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
        .background($vm.status.wrappedValue == .loading ? Color.black.opacity(0.9) : Color.black.opacity(0.8))
        .zIndex(1)
    }
    
    private func rankingItem(rankingData: RankingData, idx: Int) -> some View {
        HStack(alignment: .center, spacing: 0, content: {
            Text("\(idx + 1)")
                .font(.kr16b)
                .paddingTrailing(10)
            Text(rankingData.nickname)
                .font(.kr14b)
            Spacer()
            Text("\(rankingData.score)")
                .font(.kr14r)
        })
        .padding(top: 10, leading: 12, bottom: 10, trailing: 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor($vm.myRankingId.wrappedValue == rankingData.id ? Color.yellow.opacity(0.15) : Color.white)
        )
        .padding(top: 4, leading: 12, bottom: 4, trailing: 12)
    }
}
