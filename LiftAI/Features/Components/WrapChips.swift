//
//  WrapChips.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

public struct WrapChips: View {
    private let items: [String]
    private let spacing: CGFloat

    public init(items: [String], spacing: CGFloat = 8) {
        self.items = items
        self.spacing = spacing
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)], spacing: spacing) {
            ForEach(items, id: \.self) { text in
                Text(text)
                    .font(.caption)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Capsule().fill(Color.secondary.opacity(0.15)))
            }
        }
    }
}

public struct FlexibleFlow<Data: Collection, Content: View>: View where Data.Element: Hashable {
    private let data: Data
    private let spacing: CGFloat
    private let alignment: HorizontalAlignment
    private let content: (Data.Element) -> Content

    public init(data: Data, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        GeometryReader { geo in
            _FlexibleContent(width: geo.size.width, spacing: spacing, alignment: alignment, data: data, content: content)
        }
        .frame(height: 120) // simple, predictable height for short chip lists
    }
}

private struct _FlexibleContent<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let width: CGFloat
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let data: Data
    let content: (Data.Element) -> Content

    @State private var currentX: CGFloat = 0
    @State private var currentY: CGFloat = 0

    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
                    .alignmentGuide(.leading) { d in
                        if currentX + d.width > width {
                            currentX = 0
                            currentY -= d.height + spacing
                        }
                        let result = currentX
                        currentX += d.width + spacing
                        return result
                    }
                    .alignmentGuide(.top) { d in
                        let result = currentY
                        return result
                    }
            }
        }
        .onAppear { reset() }
        .onChange(of: width) { _ in reset() }
        .onChange(of: data.count) { _ in reset() }

    }
    private func reset() { currentX = 0; currentY = 0 }
}
