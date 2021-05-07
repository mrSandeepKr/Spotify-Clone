//
//  UserProfile.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import Foundation

struct UserProfile: Codable {
    let display_name: String
    let external_urls: [String: String]
    let followers: UserFollowers
    let href: String
    let id: String?
    let images: [ApiImage]
    let type: String
    let uri: String
    let product: String?
    let email: String?
    let country: String?
}

struct UserFollowers: Codable {
    let href:String?
    let total: Int?
}
