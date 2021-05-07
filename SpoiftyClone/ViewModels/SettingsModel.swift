//
//  SettingsModel.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 17/04/21.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handle: () -> Void
}
