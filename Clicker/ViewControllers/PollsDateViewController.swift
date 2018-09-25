//
//  PollsDateViewController.swift
//  Clicker
//
//  Created by Kevin Chan on 9/23/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import IGListKit
import Presentr
import UIKit

class PollsDateViewController: UIViewController {
    
    // MARK: - View vars
    var navigationTitleView: NavigationTitleView!
    var peopleButton: UIButton!
    var createPollButton: UIButton!
    var collectionViewLayout: UICollectionViewFlowLayout!
    var collectionView: UICollectionView!
    var adapter: ListAdapter!
    
    // MARK: - Data vars
    var userRole: UserRole!
    var socket: Socket!
    var session: Session!
    var pollsDateArray: [PollsDateModel]!
    var numberOfPeople: Int = 0
    
    // MARK: - Constants
    let countLabelWidth: CGFloat = 42.0
    let gradientViewHeight: CGFloat = 50.0
    let horizontalCollectionViewTopPadding: CGFloat = 15
    let verticalCollectionViewBottomInset: CGFloat = 50
    let verticalCollectionViewTopPadding: CGFloat = 20
    let adminNothingToSeeText = "Nothing to see here."
    let userNothingToSeeText = "Nothing to see yet."
    let adminWaitingText = "You haven't asked any polls yet!\nTry it out below."
    let userWaitingText = "Waiting for the host to post a poll."
    
    init(pollsDateArray: [PollsDateModel], session: Session, userRole: UserRole) {
        super.init(nibName: nil, bundle: nil)
        self.session = session
        self.userRole = userRole
        self.pollsDateArray = pollsDateArray
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clickerBlack1
        setupViews()
        setupNavBar()
        self.socket = Socket(id: "\(session.id)", userRole: userRole, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if createPollButton != nil {
            let livePollExists = pollsDateArray.last?.polls.last?.state == .live
            createPollButton.isUserInteractionEnabled = !livePollExists
            createPollButton.isHidden = livePollExists
        }
    }
    
    // MARK: - Layout
    func setupViews() {
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollIndicatorInsets = .zero
        collectionView.bounces = true
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        view.sendSubview(toBack: collectionView)
        
        let updater = ListAdapterUpdater()
        adapter = ListAdapter(updater: updater, viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(verticalCollectionViewTopPadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        // REMOVE BOTTOM SHADOW
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationTitleView = NavigationTitleView()
        navigationTitleView.updateNameAndCode(name: session.name, code: session.code)
        navigationTitleView.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
        self.navigationItem.titleView = navigationTitleView
        
        let backImage = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .done, target: self, action: #selector(goBack))
        
        peopleButton = UIButton()
        peopleButton.setImage(#imageLiteral(resourceName: "person"), for: .normal)
        peopleButton.setTitle("0", for: .normal)
        peopleButton.titleLabel?.font = UIFont._16RegularFont
        peopleButton.sizeToFit()
        let peopleBarButton = UIBarButtonItem(customView: peopleButton)
        
        if userRole == .admin {
            createPollButton = UIButton()
            createPollButton.setImage(#imageLiteral(resourceName: "whiteCreatePoll"), for: .normal)
            createPollButton.addTarget(self, action: #selector(createPollBtnPressed), for: .touchUpInside)
            let createPollBarButton = UIBarButtonItem(customView: createPollButton)
            self.navigationItem.rightBarButtonItems = [createPollBarButton, peopleBarButton]
        } else {
            self.navigationItem.rightBarButtonItems = [peopleBarButton]
        }
    }
        
    // MARK: ACTIONS
    @objc func createPollBtnPressed() {
        let pollBuilderVC = PollBuilderViewController(delegate: self)
        let width = Float(view.safeAreaLayoutGuide.layoutFrame.size.width)
        let height = Float(view.safeAreaLayoutGuide.layoutFrame.size.height)
        let center = CGPoint(x: view.safeAreaLayoutGuide.layoutFrame.midX, y: UIApplication.shared.statusBarFrame.height + view.safeAreaLayoutGuide.layoutFrame.midY)
        let presenter = Presentr(presentationType: .custom(width: .custom(size: width), height: .custom(size: height), center: .custom(centerPoint: center)))
        presenter.backgroundOpacity = 0.6
        presenter.roundCorners = true
        presenter.cornerRadius = 15
        presenter.dismissOnSwipe = true
        presenter.dismissOnSwipeDirection = .bottom
        
        let pollBuilderNavigationController = UINavigationController(rootViewController: pollBuilderVC)
        pollBuilderNavigationController.isNavigationBarHidden = true
        present(pollBuilderNavigationController, animated: true, completion: nil)
    }
    
    @objc func goBack() {
        socket.socket.disconnect()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if pollsDateArray.isEmpty && session.name == session.code {
            DeleteSession(id: session.id).make()
                .done {
                    self.navigationController?.popViewController(animated: true)
                    return
                }.catch { (error) in
                    print(error)
                    self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
