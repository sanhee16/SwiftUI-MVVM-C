//
//  SDHashTagView.swift
//  AnimalPicker
//
//  Created by Sandy on 6/17/24.
//

import Foundation
import SwiftUI

struct SDHashTagView: View {
    @Binding var tags: [String]
    @State private var totalHeight = CGFloat.zero

    let onRemove: (String) -> ()
    
    init(tags: Binding<[String]>, onRemove: @escaping (String) -> ()) {
        self._tags = tags
        self.onRemove = onRemove
    }
    
    init(tags: [String], onRemove: @escaping (String) -> ()) {
        self._tags = Binding.constant(tags)
        self.onRemove = onRemove
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry) { item in
                    self.onRemove(item)
                }
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy, onRemove: @escaping (String) -> ()) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(self.tags.indices, id: \.self) { idx in
                itemWithVBox(for: self.tags[idx])
                    .onTapGesture {
                        onRemove(self.tags[idx])
                        self.tags.remove(at: idx)
                    }
                    .id(idx)
                    .padding(top: 0, leading: 0, bottom: 4, trailing: 6)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if idx == self.tags.indices.last! {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if idx == self.tags.indices.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func item(for text: String) -> some View {
        return Text(text)
            .font(.kr14r)
            .foregroundColor(.black)
            .lineLimit(1)
    }
    
    private func itemWithBorder(for text: String) -> some View {
        return Text(text)
            .font(.kr14r)
            .foregroundColor(.black)
            .lineLimit(1)
            .padding(top: 2, leading: 6, bottom: 2, trailing: 6)
            .border(.gray, lineWidth: 1, cornerRadius: 6)
    }
    
    private func itemWithVBox(for text: String) -> some View {
        return HStack(alignment: .center, spacing: 8, content: {
            Text(text)
                .font(.kr20r)
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text("x")
                .font(.kr18r)
                .foregroundColor(.gray)
        })
        .padding(top: 6, leading: 10, bottom: 6, trailing: 10)
        .background(RoundedRectangle(cornerRadius: 4).foregroundStyle(.gray.opacity(0.3)))
        .contentShape(Rectangle())
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

