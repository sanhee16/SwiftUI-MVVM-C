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
        let vm = VM.init(coordinator, interactors: interactors, level: level)
        let view = Self.init(vm: vm)
        let vc = BaseViewController.init(view, completion: completion)
        vc.attachViewModel(vm)
        
        return vc
    }
    @ObservedObject var vm: VM
    
    private var safeTop: CGFloat { get { Util.safeTop() }}
    private var safeBottom: CGFloat { get { Util.safeBottom() }}
    
    let spacing: CGFloat = 16.0
    let size: CGFloat = (UIScreen.main.bounds.width - (20*2 + 16*2)) / 3
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(vm.level.rawValue)
                        .font(.kr20b)
                    Spacer()
                }
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
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        vm.onSelectItem(item: item)
                                    }
                            }
                        }
                        .paddingHorizontal(20.0)
                    })
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

