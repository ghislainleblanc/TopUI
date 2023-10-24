//
//  ContentModel.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import Foundation

@MainActor
class ContentModel: ObservableObject {
    func runTopCommand() -> String? {
        let task = Process()
        task.launchPath = "/usr/bin/top"
        task.arguments = ["-l", "1", "-n", "1"] // Run top for 1 iteration and 1 sample
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
    
    func parseTopOutput(_ topOutput: String) {
        // Split the top output into lines
        let lines = topOutput.components(separatedBy: "\n")
        
        // Process and parse the lines to extract the information you need
        for line in lines {
            // Add your parsing logic here
            print(line)
        }
    }
}
