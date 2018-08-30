//
//  PollTypeModel.swift
//  Clicker
//
//  Created by Kevin Chan on 8/27/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import Foundation
import IGListKit

enum PollType {
    case created
    case joined
}

class PollTypeModel {
    
    var pollType: PollType!
    let identifier = UUID().uuidString
    
    init(pollType: PollType) {
        self.pollType = pollType
    }
}

extension PollTypeModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if (self === object) { return true }
        guard let object = object as? PollTypeModel else { return false }
        return pollType == object.pollType
    }
}
