//
//  CellViewModels.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 23/04/21.
//

import Foundation

struct NewReleaseCellViewModel {
    let name: String
    let artworkURL : URL?
    let numberOfTracks: Int
    let artistName: String
}

struct FeaturedPlaylistCellViewModel {
    let name: String
    let artworkURL: URL?
}

struct TracksCellViewModel {
    let name: String
    let artistName: String
    let artworkURL: URL?
}

struct CategoryViewCellViewModel {
    let label: String
    let url: URL?
}
