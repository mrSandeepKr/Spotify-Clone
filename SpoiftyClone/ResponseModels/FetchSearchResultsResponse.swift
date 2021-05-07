//
//  FetchSearchResultsResponse.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 28/04/21.
//

import Foundation

struct SearchResultsSection {
    let title: String
    let info : [SearchResultDataObject]
}

enum SearchResultDataObject {
    case albums(model: Album)
    case tracks(model: AudioTrack)
    case artists(model: Artist)
    case playlists(model: Playlist)
}

struct FetchSearchResultsResponse : Codable {
    let albums : AlbumsArray?
    let artists: ArtistArray?
    let playlists: PlayListArray?
    let tracks: TracksArray?
}
