//
//  FetchAllCategoryResponse.swift
//  SpoiftyClone
//
//  Created by Aakash Kumar on 27/04/21.
//

import Foundation

struct FetchAllCategoryResponse: Codable {
    let categories : CategoryList
}

struct CategoryList: Codable {
    let items: [CategoryObject]
}

struct CategoryObject: Codable {
    let href : String
    let icons: [ApiImage]
    let id: String
    let name: String
}
