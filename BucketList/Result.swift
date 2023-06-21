//
//  Result.swift
//  BucketList
//
//  Created by Uriel Ortega on 21/06/23.
//

import Foundation

struct Result: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable {
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    
    var description: String {
        // Try to read the terms dictionary.
                // Inside, try to read the 'description' key.
                                // If that works, try to read the first item in that array.
        terms?["description"]?.first ?? "No further information"
    }
    
    static func < (lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
}
