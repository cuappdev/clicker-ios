//
//  AskedCard.swift
//  Clicker
//
//  Created by eoin on 4/16/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import SnapKit

protocol AskedCardDelegate {
    func askedCardDidEndPoll()
}

class AskedCard: UICollectionViewCell, CardDelegate, SocketDelegate {
    
    var socket: Socket!
    var poll: Poll!
    var delegate: AskedCardDelegate!
    var cardType: CardType!
    
    // Timer
    var timer: Timer!
    var elapsedSeconds: Int = 0
    
    // Question
    var freeResponses: [String]!
    
    var timerLabel: UILabel!
    var cardView: CardView!
    
    var cardHeight: Int!
    var cardHeightConstraint: Constraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clickerBlack1
        setup()
    }
    
    func setupLive() {
        timerLabel = UILabel()
        timerLabel.text = "00:00"
        timerLabel.font = UIFont._14BoldFont
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        addSubview(timerLabel)
        
        timerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(14)
        }
        
        runTimer()
        
        cardView.setupLive()
    }
    
    func setupEnded() {
        if (timerLabel != nil && timerLabel.isDescendant(of: self)) {
            timerLabel.removeFromSuperview()
            timer.invalidate()
        }
        cardView.setupEnded()
    }
    
    func setupShared() {
        cardView.setupShared()
    }
    
    // MARK: CardView setup
    func setup() {
        cardView = CardView(frame: .zero, userRole: .admin, cardDelegate: self)
        cardView.cardDelegate = self
        cardView.highlightColor = .clickerGreen1
        addSubview(cardView)
    
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Configure after variables are set
    func configure() {
        cardView.questionLabel.text = poll.text
        cardView.poll = poll
        cardView.cardType = cardType
        cardView.configure()
        setupCard()
    }
    
    func setupCard() {
        switch (cardType) {
        case .live:
            setupLive()
        case .ended:
            setupEnded()
        default:
            setupShared()
        }
    }
    
    func sessionConnected() { }
    
    func sessionDisconnected() { }
    
    func receivedUserCount(_ count: Int) { }
    
    func pollStarted(_ poll: Poll) { }
    
    func pollEnded(_ poll: Poll) { }
    
    func receivedResults(_ currentState: CurrentState) {
        cardView.poll.results = currentState.results
        if (poll.questionType == .multipleChoice) {
            cardView.totalNumResults = currentState.getTotalCount()
            cardView.totalResultsLabel.text = "\(cardView.totalNumResults) votes"
        } else {
            let frResults = currentState.getFRResultsArray()
            cardView.frResults = frResults
            cardView.updateTableViewHeightForFR()
        }
        DispatchQueue.main.async { self.cardView.resultsTableView.reloadData() }
    }
    
    func saveSession(_ session: Session) { }
    
    func updatedTally(_ currentState: CurrentState) {
        if (poll.questionType == .multipleChoice) {
            cardView.totalNumResults = currentState.getTotalCount()
            cardView.totalResultsLabel.text = "\(cardView.totalNumResults) votes"
            cardView.poll.results = currentState.results
        } else {
            let frResults = currentState.getFRResultsArray()
            cardView.frResults = frResults
            cardView.updateTableViewHeightForFR()
        }
        DispatchQueue.main.async { self.cardView.resultsTableView.reloadData() }
    }
    
    // MARK: Start timer
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    // MARK: CARD DELEGATE
    
    func questionBtnPressed() {
        switch (cardType) {
        case .live:
            socket.socket.emit(Routes.end, [])
            delegate.askedCardDidEndPoll()
            setupEnded()
            cardType = .ended
            poll.state = .ended
        case .ended:
            socket.socket.emit(Routes.results, [])
            setupShared()
            cardType = .shared
            poll.state = .shared
        default: break
        }
    }
    
    func emitTally(answer: [String : Any]) { }
    
    func upvote(answer: [String : Any]) { }
    
    // MARK: ACTIONS
    
    // Update timer label
    @objc func updateTimerLabel() {
        elapsedSeconds += 1
        if (elapsedSeconds < 10) {
            timerLabel.text = "00:0\(elapsedSeconds)"
        } else if (elapsedSeconds < 60) {
            timerLabel.text = "00:\(elapsedSeconds)"
        } else {
            let minutes = Int(elapsedSeconds / 60)
            let seconds = elapsedSeconds - minutes * 60
            if (elapsedSeconds < 600) {
                if (seconds < 10) {
                    timerLabel.text = "0\(minutes):0\(seconds)"
                } else {
                    timerLabel.text = "0\(minutes):\(seconds)"
                }
            } else {
                if (seconds < 10) {
                    timerLabel.text = "\(minutes):0\(seconds)"
                } else {
                    timerLabel.text = "\(minutes):\(seconds)"
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
