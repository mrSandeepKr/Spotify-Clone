//
//  Utils.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 24/04/21.
//

import Foundation
import UIKit

struct Utils {
    static let defaultImage = UIImage(systemName: "photo")
    static let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
    static let playImage = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
    static let defaulTrackImage = UIImage(named: "defaultTrackImage")
    static let defaultPlaylistImage = UIImage(named: "defaultPlaylistImage")
    
    static func setUserIdForCurrentUser() {
        let userID = getUserId()
        
        if userID.isEmpty {
            DispatchQueue.background(background: {
                ApiCaller.shared.getUserProfile { res in
                    switch res {
                    case .success(let profile):
                        UserDefaults.standard.setValue(profile.id, forKey: "userID")
                        print("Have set UserID")
                        break
                    default :
                        break
                    }
                }
            })
        }
    }
    
    static func getUserId() -> String {
        return  UserDefaults.standard.string(forKey: "userID") ?? ""
    }
}
