//
//  FlowView.swift
//  AnimalPicker
//
//  Created by Sandy on 6/17/24.
//

import Foundation
import SwiftUI

struct FlowItem {
    var text: String
    var isRemoveable: Bool
    var isStar: Bool
    var onRemove: (()->())
}


struct FlowView: View {
    @Binding var items: [FlowItem]
    @State private var totalHeight = CGFloat.zero
    
    init(items: Binding<[FlowItem]>) {
        self._items = items
    }
    
    init(items: [FlowItem]) {
        self._items = Binding.constant(items)
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(self.items.indices, id: \.self) { idx in
                drawItem(idx: idx)
                    .id(idx)
                    .padding(top: 0, leading: 0, bottom: 4, trailing: 6)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if idx == items.indices.last! {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if idx == items.indices.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func drawItem(idx: Int) -> some View {
        HStack(alignment: .center, spacing: 3, content: {
            if items[idx].isStar {
                Image("Star")
                    .resizable()
                    .scaledToFit()
                    .frame(both: 16.0, aligment: .center)
            }
            Text(items[idx].text)
                .font(.kr16b)
                .foregroundStyle(Color.white)
            if items[idx].isRemoveable {
                Image("Delete")
                    .resizable()
                    .scaledToFit()
                    .frame(both: 14.0, aligment: .center)
                    .paddingLeading(3)
                    .onTapGesture {
                        items[idx].onRemove()
                    }
            }
        })
        .zIndex(1)
        .padding(top: 12, leading: 14, bottom: 12, trailing: 14)
        .background(
            RoundedRectangle(cornerRadius: 50)
                .foregroundColor(Color.random)
                .border(.black, lineWidth: 3, cornerRadius: 50)
        )
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

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    func getHsb() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var hue: CGFloat  = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        let uiColor = UIColor(self)
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return (hue, saturation, brightness, alpha)
    }
}

