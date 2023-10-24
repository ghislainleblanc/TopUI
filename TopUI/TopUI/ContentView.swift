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
                Text("Core \(coreUsage.id) \(Int(coreUsage.usage * 100))%")
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
