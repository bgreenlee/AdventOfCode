//
//  BundleExtensions.swift
//  
//
//  Created by Brad Greenlee on 12/5/20.
//

import Foundation

extension Bundle {
    // File-reading simplified
    static func readFile(_ path: String) throws -> String? {
        var dir = ""
        var filename = path
        if let idx = path.lastIndex(of: "/") {
            dir = String(path[..<idx])
            filename = String(path[path.index(after: idx)...])
        }

        if let inputURL = Bundle.module.url(forResource: filename, withExtension: "", subdirectory: dir) {
            return try String(contentsOf: inputURL)
        }
        return nil
    }
}
