//
//  AuthResponse.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 15/04/21.
//

import Foundation


struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let token_type: String
}
