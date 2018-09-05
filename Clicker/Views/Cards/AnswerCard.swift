//
//  AnswerCard.swift
//  Clicker
//
//  Created by eoin on 4/17/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import SnapKit

class AnswerCard: UICollectionViewCell, CardDelegate, SocketDelegate {
    
    var freeResponses: [String]!
    
    var cardView: CardView!
    
    var choice: Int?
    var poll: Poll!
    var socket: Socket!
    var cardHeightConstraint: Constraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clickerBlack1
        setup()
    }
    
    func configureWith(socket: Socket, poll: Poll) {
        self.socket = socket
        self.poll = poll
        cardView.configureWith(poll: poll)
        cardView.setupCard()
    }
    
    func setup() {
        cardView = CardView(frame: .zero, userRole: .member, cardDelegate: self)
        cardView.highlightColor = .clickerGreen1
        addSubview(cardView)
        
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: Actions
    @objc func seeAllAction() {
        print("see all")
    }
    
    // MARK: CARD DELEGATE
    func questionBtnPressed() { }
    
    func emitTally(answer: [String : Any]) {
        socket.socket.emit(Routes.tally, answer)
    }
    
    func upvote(answer: [String : Any]) {
        socket.socket.emit(Routes.upvote, answer)
    }
    
    // MARK: SOCKET DELEGATE
    func sessionConnected() { }
    
    func sessionDisconnected() { }
    
    func receivedUserCount(_ count: Int) { }
    
    func pollStarted(_ poll: Poll) { }
    
    func pollEnded(_ poll: Poll) {
        cardView.poll.state = .ended
        DispatchQueue.main.async { self.cardView.resultsTableView.reloadData() }
        cardView.setupEnded()
    }
    
    func receivedResults(_ currentState: CurrentState) {
        print("received results!")
        cardView.poll.state = .shared
        if (poll.questionType == .multipleChoice) {
            cardView.poll.results = currentState.results
            let totalNumResults = currentState.getTotalCount()
            cardView.totalNumResults = totalNumResults
            cardView.totalResultsLabel.text = "\(totalNumResults) votes"
        } else {
            let frResults = currentState.getFRResultsArray()
            cardView.frResults = frResults
            cardView.updateTableViewHeightForFR()
        }
        DispatchQueue.main.async { self.cardView.resultsTableView.reloadData() }
        cardView.setupShared()
    }
    
    func saveSession(_ session: Session) { }
    
    func updatedTally(_ currentState: CurrentState) { }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
