//
//  NewReleaseModel.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 18/04/21.
//

import Foundation

struct NewReleaseResponse: Codable {
    let albums: AlbumsArray
}

struct AlbumsArray: Codable {
    let items:[Album]
}

struct  Album: Codable {
    let album_type: String
    let id: String
    var images: [ApiImage]?
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}
