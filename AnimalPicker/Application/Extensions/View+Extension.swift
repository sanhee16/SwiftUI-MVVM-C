//
//  View+Extension.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import SwiftUI
import Combine

extension View {
    
    public func padding(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> some View {
        return self.padding(EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }
    public func paddingTop(_ value: CGFloat) -> some View {
        return self.padding(EdgeInsets(top: value, leading: 0, bottom: 0, trailing: 0))
    }
    public func paddingLeading(_ value: CGFloat) -> some View {
        return self.padding(EdgeInsets(top: 0, leading: value, bottom: 0, trailing: 0))
    }
    public func paddingTrailing(_ value: CGFloat) -> some View {
        return self.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: value))
    }
    public func paddingBottom(_ value: CGFloat) -> some View {
        return self.padding(EdgeInsets(top: 0, leading: 0, bottom: value, trailing: 0))
    }
    public func paddingHorizontal(_ value: CGFloat) -> some View {
        return self.padding(EdgeInsets(top: 0, leading: value, bottom: 0, trailing: value))
    }
    public func paddingVertical(_ value: CGFloat) -> some View {
        return self.padding(EdgeInsets(top: value, leading: 0, bottom: value, trailing: 0))
    }    
    
    public func border(_ color: Color, lineWidth: CGFloat, cornerRadius: CGFloat) -> some View {
        return self
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: lineWidth).foregroundColor(color))
    }
    
    public func frame(both: CGFloat, aligment: Alignment = .center) -> some View {
        return self
            .frame(width: both, height: both, alignment: aligment)
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func rectReader(_ binding: Binding<CGRect>, in space: CoordinateSpace) -> some View {
        self.background(GeometryReader { (geometry) -> AnyView in
            let rect = geometry.frame(in: space)
            DispatchQueue.main.async {
                binding.wrappedValue = rect
            }
            return AnyView(Rectangle().fill(Color.clear))
        })
    }
    
    /// MarqueeText
    /// A backwards compatible wrapper for iOS 14 `onChange`
    @ViewBuilder func onValueChanged<T: Equatable>(of value: T, perform onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
    
    func skeleton(_ isLoading: Bool) -> some View {
        self.redacted(reason: isLoading ? .placeholder : [])
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
