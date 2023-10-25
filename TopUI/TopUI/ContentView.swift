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
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(model.coreUsages) { coreUsage in
                    Text("Core \(coreUsage.id) \(Int(coreUsage.usage * 100))%")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.bottom, 20)

            VStack(spacing: 0) {
                Text("Free Memory: \(String(format: "%.2f", model.memoryUsage.free))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Active Memory: \(String(format: "%.2f", model.memoryUsage.active))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Inactive Memory: \(String(format: "%.2f", model.memoryUsage.inactive))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Wired Memory: \(String(format: "%.2f", model.memoryUsage.wired))Gb")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Compressed Memory: \(String(format: "%.2f", model.memoryUsage.compressed))Gb")
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
