//
//  AskedUnsharedCard.swift
//  Clicker
//
//  Created by eoin on 4/16/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit

class AskedUnsharedCard: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, SocketDelegate {
    
    var socket: Socket!
    var poll: Poll!
    var endPollDelegate: EndPollDelegate!
    var totalNumResults: Int = 0
    var freeResponses: [String]!
    var isMCQuestion: Bool!
    
    var cellColors: UIColor!
    
    var cardView: UIView!
    var questionLabel: UILabel!
    var resultsTableView: UITableView!
    var visibiltyLabel: UILabel!
    var shareResultsButton: UIButton!
    var totalResultsLabel: UILabel!
    var eyeView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    func setupCell() {
        isMCQuestion = true
        
        socket?.addDelegate(self)
        
        backgroundColor = .clickerDeepBlack
        setupViews()
        layoutViews()
    }
    
    func setupViews() {
        cellColors = .clickerHalfGreen
        
        cardView = UIView()
        cardView.layer.cornerRadius = 15
        cardView.layer.borderColor = UIColor.clickerBorder.cgColor
        cardView.layer.borderWidth = 1
        cardView.layer.shadowRadius = 2.5
        cardView.backgroundColor = .clickerNavBarLightGrey
        addSubview(cardView)
        
        questionLabel = UILabel()
        questionLabel.font = ._22SemiboldFont
        questionLabel.textColor = .clickerBlack
        questionLabel.textAlignment = .left
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.numberOfLines = 0
        cardView.addSubview(questionLabel)
        
        resultsTableView = UITableView()
        resultsTableView.backgroundColor = .clear
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.separatorStyle = .none
        resultsTableView.isScrollEnabled = false
        resultsTableView.register(ResultCell.self, forCellReuseIdentifier: "resultCellID")
        cardView.addSubview(resultsTableView)
        
        visibiltyLabel = UILabel()
        visibiltyLabel.text = "Only you can see these results"
        visibiltyLabel.font = ._12MediumFont
        visibiltyLabel.textAlignment = .left
        visibiltyLabel.textColor = .clickerMediumGray
        cardView.addSubview(visibiltyLabel)
        
        shareResultsButton = UIButton()
        shareResultsButton.setTitleColor(.clickerDeepBlack, for: .normal)
        shareResultsButton.backgroundColor = .clear
        shareResultsButton.setTitle("End Question", for: .normal)
        shareResultsButton.titleLabel?.font = ._16SemiboldFont
        shareResultsButton.titleLabel?.textAlignment = .center
        shareResultsButton.layer.cornerRadius = 25.5
        shareResultsButton.layer.borderColor = UIColor.clickerDeepBlack.cgColor
        shareResultsButton.layer.borderWidth = 1.5
        shareResultsButton.addTarget(self, action: #selector(shareQuestionAction), for: .touchUpInside)
        cardView.addSubview(shareResultsButton)
        
        totalResultsLabel = UILabel()
        totalResultsLabel.text = "\(totalNumResults) votes"
        totalResultsLabel.font = ._12MediumFont
        totalResultsLabel.textAlignment = .right
        totalResultsLabel.textColor = .clickerMediumGray
        cardView.addSubview(totalResultsLabel)
        
        eyeView = UIImageView(image: #imageLiteral(resourceName: "solo_eye"))
        cardView.addSubview(eyeView)
    }
    
    func layoutViews() {
        
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.height.equalTo(390)
            make.width.equalTo(339)
            make.centerX.equalToSuperview()
        }
        
        questionLabel.snp.updateConstraints{ make in
            questionLabel.sizeToFit()
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(17)
        }
        
        resultsTableView.snp.updateConstraints{ make in
            make.top.equalTo(questionLabel.snp.bottom).offset(13.5)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(206)
        }
        
        visibiltyLabel.snp.updateConstraints{ make in
            make.top.equalTo(resultsTableView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(46)
            make.width.equalTo(200)
            make.height.equalTo(14.5)
        }
        
        eyeView.snp.makeConstraints { make in
            make.height.equalTo(14.5)
            make.width.equalTo(14.5)
            make.centerY.equalTo(visibiltyLabel.snp.centerY)
            make.left.equalToSuperview().offset(25)
        }
        
        totalResultsLabel.snp.updateConstraints{ make in
            make.right.equalToSuperview().offset(-22.5)
            make.width.equalTo(50)
            make.top.equalTo(visibiltyLabel.snp.top)
            make.height.equalTo(14.5)
        }
        
        shareResultsButton.snp.updateConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(47)
            make.top.equalTo(visibiltyLabel.snp.bottom).offset(15)
            make.width.equalTo(303)
        }
        
        
    }
    
    // MARK - TABLEVIEW
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCellID", for: indexPath) as! ResultCell
        cell.choiceTag = indexPath.row
        cell.selectionStyle = .none
        cell.highlightView.backgroundColor = cellColors
        
        // UPDATE HIGHLIGHT VIEW WIDTH
        let mcOption: String = intToMCOption(indexPath.row)
        var count: Int = 0
        if let choiceInfo = poll.results![mcOption] as? [String:Any] {
            cell.optionLabel.text = choiceInfo["text"] as? String
            count = choiceInfo["count"] as! Int
            cell.numberLabel.text = "\(count)"
        }
        
        if (totalNumResults > 0) {
            let percentWidth = CGFloat(Float(count) / Float(totalNumResults))
            let totalWidth = cell.frame.width
            cell.highlightWidthConstraint.update(offset: percentWidth * totalWidth)
        } else {
            cell.highlightWidthConstraint.update(offset: 0)
        }
        
        // ANIMATE CHANGE
        UIView.animate(withDuration: 0.5, animations: {
            cell.layoutIfNeeded()
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poll.options!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    func sessionConnected() {
        
    }
    
    func sessionDisconnected() {
        
    }
    
    func pollStarted(_ poll: Poll) {
    }
    
    func pollEnded(_ poll: Poll) {
    }
    
    func receivedResults(_ currentState: CurrentState) {
    }
    
    func saveSession(_ session: Session) {
    }
    
    func updatedTally(_ currentState: CurrentState) {
        totalNumResults = currentState.getTotalCount()
        poll.results = currentState.results
        self.resultsTableView.reloadData()
    }
    
    @objc func shareQuestionAction() {
        socket.socket.emit("server/poll/results", [])
        shareResultsButton.removeFromSuperview()
        eyeView.image = #imageLiteral(resourceName: "results_shared")
        visibiltyLabel.text = "Shared with group"
        visibiltyLabel.textColor = .clickerGreen
        visibiltyLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-23.5)
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}