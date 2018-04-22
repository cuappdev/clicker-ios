//
//  BlackViewController.swift
//  Clicker
//
//  Created by eoin on 4/15/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import Presentr

class BlackAskController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StartPollDelegate, SocketDelegate {
    
    // empty student vars
    var monkeyView: UIImageView!
    var nothingToSeeLabel: UILabel!
    var waitingLabel: UILabel!
    var downArrowImageView: UIImageView!
    var createPollButton: UIButton!
    
    // admin group vars
    var mainCollectionView: UICollectionView!
    
    var tabController: UITabBarController!
    var socket: Socket!
    var sessionId: Int!
    var code: String!
    var datePollsArr: [(String, [Poll])] = []
    var livePoll: Poll!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clickerDeepBlack
        setupNavBar()
        if (datePollsArr.count == 0) {
            setupEmptyStudentPoll()
        }
    }
    
    @objc func createPollBtnPressed() {
        let presenter = Presentr(presentationType: .fullScreen)
        presenter.backgroundOpacity = 0.6
        presenter.roundCorners = true
        presenter.cornerRadius = 15
        presenter.dismissOnSwipe = true
        presenter.dismissOnSwipeDirection = .bottom
        let pollBuilderVC = PollBuilderViewController()
        pollBuilderVC.startPollDelegate = self
        customPresentViewController(presenter, viewController: pollBuilderVC, animated: true, completion: nil)
    }
    
    func setupEmptyStudentPoll() {
        setupEmptyStudentPollViews()
        setupEmptyStudentPollConstraints()
    }
    
    func removeEmptyStudentPoll() {
        monkeyView.removeFromSuperview()
        nothingToSeeLabel.removeFromSuperview()
        waitingLabel.removeFromSuperview()
        downArrowImageView.removeFromSuperview()
    }
    
    func setupEmptyStudentPollViews() {
        monkeyView = UIImageView(image: #imageLiteral(resourceName: "monkey_emoji"))
        monkeyView.contentMode = .scaleAspectFit
        view.addSubview(monkeyView)
        
        nothingToSeeLabel = UILabel()
        nothingToSeeLabel.text = "Nothing to see here."
        nothingToSeeLabel.font = ._16SemiboldFont
        nothingToSeeLabel.textColor = .clickerBorder
        nothingToSeeLabel.textAlignment = .center
        view.addSubview(nothingToSeeLabel)
        
        waitingLabel = UILabel()
        waitingLabel.text = "You haven't asked any polls yet!\nTry it out below."
        waitingLabel.font = ._14MediumFont
        waitingLabel.textColor = .clickerMediumGray
        waitingLabel.textAlignment = .center
        waitingLabel.lineBreakMode = .byWordWrapping
        waitingLabel.numberOfLines = 0
        view.addSubview(waitingLabel)
        
        createPollButton = UIButton()
        createPollButton.setTitle("Create a poll", for: .normal)
        createPollButton.backgroundColor = .clear
        createPollButton.layer.cornerRadius = 24
        createPollButton.layer.borderWidth = 1
        createPollButton.layer.borderColor = UIColor.white.cgColor
        createPollButton.addTarget(self, action: #selector(createPollBtnPressed), for: .touchUpInside)
        view.addSubview(createPollButton)
        
        
        downArrowImageView = UIImageView(image: #imageLiteral(resourceName: "down arrow"))
        downArrowImageView.contentMode = .scaleAspectFit
        view.addSubview(downArrowImageView)
    }
    
    func setupEmptyStudentPollConstraints() {
        monkeyView.snp.makeConstraints { make in
            make.width.equalTo(31)
            make.height.equalTo(34)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(142)
        }
        
        nothingToSeeLabel.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(19)
            make.centerX.equalToSuperview()
            make.top.equalTo(monkeyView.snp.bottom).offset(21)
        }
        
        waitingLabel.snp.makeConstraints { make in
            make.width.equalTo(220)
            make.height.equalTo(36)
            make.centerX.equalToSuperview()
            make.top.equalTo(nothingToSeeLabel.snp.bottom).offset(11)
        }
        
        createPollButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.45)
            make.height.equalToSuperview().multipliedBy(0.08)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-22)
        }
        
        downArrowImageView.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(createPollButton.snp.top).offset(-20)
        }
    }
    
    func setupAdminGroup() {
        setupAdminGroupViews()
        setupAdminGroupConstraints()
    }
    
    func setupAdminGroupViews() {
        let layout = UICollectionViewFlowLayout()
        mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(DateCell.self, forCellWithReuseIdentifier: "dateCellID")
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.backgroundColor = .clear
        mainCollectionView.isPagingEnabled = true
        view.addSubview(mainCollectionView)
    }

    func setupAdminGroupConstraints() {
        mainCollectionView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.bottom.equalTo(createPollButton.snp.top).offset(-12)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - COLLECTIONVIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datePollsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCellID", for: indexPath) as! DateCell
        cell.polls = datePollsArr[indexPath.item].1
        cell.socket = socket
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: mainCollectionView.frame.width, height: 505)
    }
    
    func updateDatePollsArr() {
        GetSortedPolls(id: "\(sessionId)").make()
            .done { datePollsArr in
                self.datePollsArr = datePollsArr
                DispatchQueue.main.async { self.mainCollectionView.reloadData() }
            }.catch { error in
                print(error)
        }
    }
    
    // MARK - SOCKET DELEGATE
    
    func sessionConnected() { }
    
    func sessionDisconnected() { }
    
    func questionStarted(_ question: Question) { }
    
    func questionEnded(_ question: Question) { }
    
    func receivedResults(_ currentState: CurrentState) {
        livePoll.id = currentState.pollId
        livePoll.results = currentState.results
        DispatchQueue.main.async { self.mainCollectionView.reloadData() }
    }
    
    func saveSession(_ session: Session) { }
    
    func updatedTally(_ currentState: CurrentState) {
        livePoll.id = currentState.pollId
        livePoll.results = currentState.results
        print(datePollsArr[0].1[0])
        print(print(datePollsArr[0].1[0].results))
        DispatchQueue.main.async { self.mainCollectionView.reloadData() }
    }
    
    // MARK: - START POLL DELEGATE
    func startPoll(text: String, type: String, options: [String]) {
        // EMIT START QUESTION
        let socketQuestion: [String:Any] = [
            "text": text,
            "type": type,
            "options": options
        ]
        socket.delegate = self
        socket.socket.emit("server/poll/start", with: [socketQuestion])
        var results: [String:Any] = [:]
        for (index, option) in options.enumerated() {
            let mcOption = intToMCOption(index)
            results[mcOption] = ["text": option, "count": 0]
        }
        livePoll = Poll(id: -1, text: text, results: results, isLive: true)
        if (datePollsArr.count == 0) {
            self.datePollsArr.append((getTodaysDate(), [livePoll]))
            removeEmptyStudentPoll()
            setupAdminGroup()
        } else {
            self.datePollsArr[datePollsArr.count - 1].1.append(livePoll)
        }
        DispatchQueue.main.async { self.mainCollectionView.reloadData() }
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        // REMOVE BOTTOM SHADOW
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let codeLabel = UILabel()
        if let c = code {
            codeLabel.text = "Code: \(c)"
        }
        codeLabel.textColor = .white
        codeLabel.font = UIFont._16SemiboldFont
        codeLabel.textAlignment = .center
        self.navigationItem.titleView = codeLabel
        
        let backImage = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        let settingsImage = UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .done, target: self, action: #selector(goBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: settingsImage, style: .plain, target: self, action: nil)
    }
    
    @objc func goBack() {
        socket.socket.disconnect()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // HIDE NAV BAR, SHOW TABBAR
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        tabController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
