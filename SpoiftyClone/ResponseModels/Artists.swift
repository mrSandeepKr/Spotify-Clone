//
//  Artists.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name:String
    let type: String
    let external_urls: [String:String]
    let genres : [String]?
    let images : [ApiImage]?
    let popularity: Int?
    let followers : UserFollowers?
}

struct ArtistArray: Codable {
    let items: [Artist]
}
