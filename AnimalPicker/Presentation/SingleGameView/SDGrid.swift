//
//  SDGrid.swift
//  AnimalPicker
//
//  Created by Sandy on 5/29/24.
//

import Foundation
import SwiftUI

struct SDGrid<Data, Content>: View where Data: RandomAccessCollection, Content: View {
    let columnCount: Int
    let spacing: CGFloat
    public var data: Data
    public var content: (Data.Element) -> Content
    var lastIdx: Int = 0
    var chunks: [[Data.Element]]
    
    init(columnCount: Int, spacing: CGFloat, data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.columnCount = columnCount
        self.spacing = spacing
        self.data = data
        self.chunks = []
        self.content = content
        
        var list: [Data.Element] = []
        var cnt: Int = 0
        for i in 0..<self.data.count {
            if cnt == columnCount {
                cnt = 0
                if !list.isEmpty {
                    chunks.append(list)
                    list.removeAll()
                }
            }
            list.append(self.data[self.data.index(self.data.startIndex, offsetBy: i)])
            cnt += 1
        }
        
        if !list.isEmpty {
            chunks.append(list)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: self.spacing, content: {
            ForEach(chunks.indices, id: \.self) { i in
                HStack(alignment: .center, spacing: self.spacing) {
                    ForEach(chunks[i].indices, id: \.self) { j in
                        content(chunks[i][j])
                    }
                }
            }
        })
    }
}
