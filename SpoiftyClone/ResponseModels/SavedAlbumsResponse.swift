//
//  SavedAlbumsResponse.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 06/05/21.
//

import Foundation

struct SavedAlbumResposeObject: Codable {
    let album: Album
    let genres : [String]?
    let images: [ApiImage]?
    let release_data: String?
    let popularity: Int?
    let tracks: [AudioTrack]?
}

struct SavedAlbumRespose : Codable {
    let items : [SavedAlbumResposeObject]
}
