//
//  CardController+Extension.swift
//  Clicker
//
//  Created by Kevin Chan on 5/4/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import IGListKit
import UIKit

extension CardController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if (currentIndex > -1) {
            return pollsDateArray[currentIndex].polls
        } else {
            return [EmptyStateModel(userRole: userRole)]
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        print(object)
        if let _ = object as? Poll {
            let pollSectionController = PollSectionController()
            pollSectionController.session = session
            pollSectionController.userRole = userRole
            pollSectionController.socket = socket
            pollSectionController.endPollDelegate = self
            return pollSectionController
        } else {
            let emptyStateController = EmptyStateSectionController()
            emptyStateController.session = session
            emptyStateController.userRole = userRole
            emptyStateController.nameViewDelegate = self
            return emptyStateController
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension CardController: EndPollDelegate {
    
    func endedPoll() {
        //createPollButton.isUserInteractionEnabled = true
    }

}

extension CardController: StartPollDelegate {
    
    func startPoll(text: String, type: QuestionType, options: [String], isShared: Bool) {
        // TODO
        // CreatePoll(...)
        currentIndex = (pollsDateArray ?? []).count - 1
        adapter.performUpdates(animated: true) { done in
            print(done)
        }
        
    }
    
}

extension CardController: NameViewDelegate {
    
    func nameViewDidUpdateSessionName() {
        navigationTitleView.updateNameAndCode(name: session.name, code: session.code)
    }
    
}

extension CardController: SocketDelegate {
    
    func sessionConnected() { }
    
    func sessionDisconnected() { }
    
    func receivedUserCount(_ count: Int) {
        peopleButton.setTitle("\(count)", for: .normal)
    }
    
    func pollStarted(_ poll: Poll) {
        // TODO
    }
    
    func pollEnded(_ poll: Poll) { }
    
    func receivedResults(_ currentState: CurrentState) { }
    
    func saveSession(_ session: Session) { }
    
    func updatedTally(_ currentState: CurrentState) { }
    
}
