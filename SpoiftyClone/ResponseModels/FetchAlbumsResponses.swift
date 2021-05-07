//
//  FetchAlbumsTracksResponse.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 25/04/21.
//

import Foundation


struct TracksArray: Codable {
    let items: [AudioTrack]
}

struct FetchAlbumDetailsResponse: Codable {
    let album_type: String
    let artists: [Artist]?
    let external_urls: [String: String]
    let id: String
    let images: [ApiImage]
    let label: String?
    let name: String
    let tracks: TracksArray
}
