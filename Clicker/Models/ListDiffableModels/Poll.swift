//
//  Poll.swift
//  Clicker
//
//  Created by Kevin Chan on 2/3/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import IGListKit

enum PollState {
    case live
    case ended
    case shared
}

class Poll {
    
    var id: Int
    var text: String
    var questionType: QuestionType
    var options: [String]
    var results: [String:Any]
    var state: PollState
    // results format:
    // MULTIPLE_CHOICE: {'A': {'text': 'Blue', 'count': 3}, ...}
    // FREE_RESPONSE: {'Blue': {'text': 'Blue', 'count': 3}, ...}
    
    // MARK: - Constants
    let identifier = UUID().uuidString
    
    init(id: Int, text: String, questionType: QuestionType, options: [String], results: [String:Any], state: PollState) {
        self.id = id
        self.text = text
        self.questionType = questionType
        self.options = options
        self.results = results
        self.state = state
    }
    
    // Returns array representation of results
    // Ex) [('Blah', 3), ('Jupiter', 2)...]
    func getFRResultsArray() -> [(String, Int)] {
        var resultsArr: [(String, Int)] = []
        results.forEach { (key, val) in
            if let choiceJSON = val as? [String:Any], let numSelected = choiceJSON[ParserKeys.countKey] as? Int {
                resultsArr.append((key, numSelected))
            }
        }
        return resultsArr
    }
    
    func getTotalResults() -> Int {
        return results.reduce(0) { (res, arg1) -> Int in
            let (_, value) = arg1
            if let choiceJSON = value as? [String:Any], let numSelected = choiceJSON[ParserKeys.countKey] as? Int {
                return res + numSelected
            }
            return 0
        }
    }

}

extension Poll: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if (self === object) { return true }
        guard let object = object as? Poll else { return false }
        return id == object.id && text == object.text && questionType == object.questionType
    }
    
}
