//
//  ExpandableTextView.swift
//  OneTreasure
//
//  Created by Ardelia on 03/06/25.
//



//
//  ExpandableTextView.swift
//  ARIslandGame
//
//  Created by Ardelia on 22/05/25.
//


import SwiftUI

struct ExpandableTextView: View {
    let text: String
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .lineLimit(expanded ? nil : 3)
                .background(
                    Text(text)
                        .lineLimit(nil)
                        .background(GeometryReader { fullTextGeometry in
                            Color.clear.onAppear {
                                let fullHeight = fullTextGeometry.size.height
                                DispatchQueue.main.async {
                                    // Compare heights to determine if truncation is needed
                                    truncated = fullHeight > 60 // Adjust based on font and line height
                                }
                            }
                        })
                        .hidden()
                )

            if truncated {
                Button(action: {
                    withAnimation {
                        expanded.toggle()
                    }
                }) {
                    Text(expanded ? "See Less" : "See More")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(EdgeInsets(top: 2, leading: 15, bottom: 5, trailing: 15))
    }
}
