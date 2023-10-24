//
//  ContentView.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var model = ContentModel()

    var body: some View {
        VStack {
            ForEach(model.coreUsages) { coreUsage in
                HStack(spacing: 10) {
                    Text("Core: \(coreUsage.id)")

                    Text("\(Int(coreUsage.usage * 100))%")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .padding(.leading, 20)
        .padding(.top, 20)
    }
}

#Preview {
    ContentView()
}
