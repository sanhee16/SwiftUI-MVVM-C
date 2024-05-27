//
//  GameView.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Kingfisher
import SwiftUI

struct GameView: View {
    typealias VM = GameVM
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
    
    let spacing: CGFloat = 16.0
    let size: CGFloat = (UIScreen.main.bounds.width - (20*2 + 16*2)) / 3
    
    @State private var nickname: String = ""
    
    
    var body: some View {
        GeometryReader { geometry in
            if $vm.status.wrappedValue == .timeOut || $vm.status.wrappedValue == .clear {
                VStack(alignment: .center, spacing: 16, content: {
                    if $vm.status.wrappedValue == .timeOut {
                        Text("Time is Up")
                            .font(.kr35b)
                            .foregroundStyle(Color.white)
                        
                        // 점수
                        Text("Score: \($vm.score.wrappedValue)")
                            .font(.kr30b)
                            .foregroundStyle(Color.white)
                        
                        
                        // 랭킹 기록
                        if $vm.score.wrappedValue > 0 {
                            SingleBoxTextField(placeholder: "Nickname", text: $nickname, lengthLimit: 10) { _ in
                                
                            }
                            .frame(width: UIScreen.main.bounds.size.width - 100, height: 42, alignment: .center)
                        }
                        
                        HStack(alignment: .center, spacing: 12, content: {
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
                            
                            if $vm.score.wrappedValue > 0 {
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
                            }
                        })
                        .paddingTop(20)
                        
                        
                        
                        
                    }
                    
                    if $vm.status.wrappedValue == .clear {
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
                    }
                    
                })
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                .background(Color.black.opacity(0.8))
                .zIndex(1)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0, content: {
                    HStack {
                        Text(vm.level.rawValue)
                            .font(.kr24b)
                        Spacer()
                        Text("score: \($vm.score.wrappedValue)")
                            .font(.kr16m)
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
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: vm.level.cell.row), spacing: self.spacing, content: {
                        ForEach(vm.results, id: \.self) { item in
                            if let url = URL(string: item.url) {
                                KFImage(url)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(both: self.size, aligment: .center)
                                    .overlay {
                                        if item.isSelected {
                                            RoundedRectangle(cornerRadius: 8)
                                                .foregroundStyle(Color.black.opacity(0.7))
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .clipped()
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        vm.onSelectItem(item: item)
                                    }
                            }
                        }
                    })
                    .paddingHorizontal(20.0)
                }
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

