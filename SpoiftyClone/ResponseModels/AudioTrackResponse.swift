//
//  AudioTrack.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import Foundation

struct AudioTrack: Codable {
    var album: Album?
    let artists: [Artist]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String : String]
    let id: String
    let name: String
    let popularity: Int?
    let preview_url: String?
    let uri: String
}
