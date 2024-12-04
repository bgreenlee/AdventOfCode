//
//  View+Border.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/3/24.
//
import SwiftUI

extension View {
    public func roundedBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}
