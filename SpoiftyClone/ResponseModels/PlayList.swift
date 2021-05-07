//
//  PlayList.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import Foundation

// Response on getting the Featured Playlist List
struct Playlist: Codable {
    let description: String?
    let external_urls: [String: String]
    let id: String
    let images: [ApiImage]?
    let name: String
    let owner: User
}

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}

// Reponse of Fetching the Playlist Details
struct PlaylistDetail : Codable {
    let description : String
    let external_urls: [String: String]
    let followers : UserFollowers
    let href :String
    let id: String
    let images: [ApiImage]
    let primary_color: String?
    let owner: User
    let snapshot_id: String?
    let tracks: PlaylistTracksResponse?
}

struct PlaylistTracksResponse : Codable {
    let items: [PlaylistTrackItem]
}

struct PlaylistTrackItem: Codable {
    let added_at: String?
    let is_local : Bool?
    let track: AudioTrack
    let artists: [Artist]?
    let duration_ms: String?
    let episode: Int?
    let explicit: Int?
}

