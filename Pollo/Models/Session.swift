//
//  Session.swift
//  Pollo
//
//  Created by Kevin Chan on 10/30/17.
//  Copyright © 2017 CornellAppDev. All rights reserved.
//

import IGListKit

struct Code: Codable {
    var code: String
}

class Session: Codable {

    let identifier = UUID().uuidString
    var code: String
    var description: String?
    var id: String
    var isLive: Bool?
    var name: String
    var updatedAt: String?

    init(id: String, name: String, code: String) {
        self.code = code
        self.id = id
        self.name = name
    }

    init(id: String, name: String, code: String, latestActivity: String?, isLive: Bool?) {
        self.code = code
        self.description = latestActivity
        self.id = id
        self.isLive = isLive
        self.name = name
    }

}

extension Session: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? Session else { return false }
        return identifier == object.identifier
    }
    
}
