//
//  FeaturedPlaylistResponse.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 18/04/21.
//

import Foundation

struct FeaturedPlaylistResponse : Codable {
    let playlists: PlayListArray
}

struct PlayListArray: Codable {
    let items:[Playlist]
}
