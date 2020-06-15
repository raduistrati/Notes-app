//
//  Note.swift
//  Notes
//
//  Created by Radu Istrati on 15.05.20.
//  Copyright © 2020 Radu Istrati. All rights reserved.
//

import UIKit

class Note: NSObject, Codable {
    var title: String
    var body: String
    var uuid: UUID
    
    init(title: String, body: String, uuid: UUID) {
        self.title = title
        self.body = body
        self.uuid = uuid
    }
}
