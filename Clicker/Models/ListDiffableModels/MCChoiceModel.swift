//
//  MCChoiceModel.swift
//  Clicker
//
//  Created by Kevin Chan on 9/7/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import IGListKit

class MCChoiceModel {
    
    var option: String
    var isSelected: Bool
    var isAnswer: Bool
    let identifier = UUID().uuidString
    
    init(option: String, isSelected: Bool) {
        self.option = option
        self.isSelected = isSelected
        self.isAnswer = false
    }
    
    init(option: String, isAnswer: Bool) {
        self.option = option
        self.isSelected = false
        self.isAnswer = isAnswer
    }
}

extension MCChoiceModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if (self === object) { return true }
        guard let object = object as? MCChoiceModel else { return false }
        return identifier == object.identifier && option == object.option && isSelected == object.isSelected
    }
    
}
