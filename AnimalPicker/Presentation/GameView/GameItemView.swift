//
//  GameItemView.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import Kingfisher
import SwiftUI


struct GameItemView: View {
    private let size: CGFloat
    private let spacing: CGFloat = 16.0
    private let level: Level

    var items: [GameItem]
    
    let onLoadSuccess: (GameItem) -> ()
    let onSelectItem: (GameItem) -> ()
    
    init(items: [GameItem], level: Level, onLoadSuccess: @escaping ((GameItem) -> ()), onSelectItem: @escaping ((GameItem) -> ())) {
        self.items = items
        self.level = level
        self.onLoadSuccess = onLoadSuccess
        self.onSelectItem = onSelectItem
        self.size = (UIScreen.main.bounds.width - (20 * 2 + self.spacing * CGFloat(level.cell.row - 1))) / CGFloat(level.cell.row)
    }
    
    var body: some View {
        SDGrid(columnCount: level.cell.row, spacing: self.spacing, data: items) { item in
            if let url = URL(string: item.url) {
                KFImage(url)
                    .onSuccess({ _ in
                        onLoadSuccess(item)
                    })
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
                        onSelectItem(item)
                    }
            }
        }
        .paddingHorizontal(20.0)
    }
}
