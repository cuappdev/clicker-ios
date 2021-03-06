//
//  PollsViewController.swift
//  Pollo
//
//  Created by eoin on 4/14/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import AppDevAnnouncements
import FutureNova
import IGListKit
import Presentr
import StoreKit
import UIKit

class PollsViewController: UIViewController {
    
    // MARK: - View vars
    var adapter: ListAdapter!
    var bottomPaddingView: UIView!
    var codeTextField: UITextField!
    var createSessionButton: UIButton!
    var createSessionContainerView: UIView!
    var createSessionTextField: UITextField!
    var dimmingView: UIView!
    var headerGradientView: UIView!
    var joinSessionButton: UIButton!
    var joinSessionContainerView: UIView!
    var newGroupActivityIndicatorView: UIActivityIndicatorView!
    var pollsCollectionView: UICollectionView!
    var pollsOptionsView: OptionsView!
    var settingsButton: UIButton!
    var tapGestureRecognizer: UITapGestureRecognizer!
    var titleLabel: UILabel!
    
    // MARK: - Data vars
    private let networking: Networking = URLSession.shared.request
    var gradientNeedsSetup: Bool = true
    var isKeyboardShown: Bool = false
    var isListeningToKeyboard: Bool = true
    var isOpeningGroup: Bool = false
    var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    var pollTypeModels: [PollTypeModel]!
    var session: Session?
    
    // MARK: - Constants
    let buttonPadding: CGFloat = 15
    let codeTextFieldEdgePadding: CGFloat = 18
    let codeTextFieldHeight: CGFloat = 40
    let codeTextFieldHorizontalPadding: CGFloat = 12
    let codeTextFieldPlaceHolder = "Enter a group code..."
    let createSessionTextFieldPlaceHolder = "Enter a new group name..."
    let createSessionButtonTitle = "Create"
    let createSessionButtonWidth: CGFloat = 83.5
    let createdPollsOptionsText = "Created"
    let editModalHeight: CGFloat = 205
    let errorText = "Error"
    let failedToCreateGroupText = "Failed to create new group. Try again!"
    let headerGradientHeight: CGFloat = 186
    let joinSessionButtonAnimationDuration: TimeInterval = 0.2
    let joinSessionButtonTitle = "Join"
    let joinSessionContainerViewHeight: CGFloat = 64
    let joinSessionFailureMessage = "We couldn't find a group with that code. Please try again."
    let joinedPollsOptionsText = "Joined"
    let popupViewHeight: CGFloat = 140
    let submitFeedbackMessage = "You can help us make our app even better! Tap below to submit feedback."
    let submitFeedbackTitle = "Submit Feedback"
    let titleLabelText = "Pollo"
    
    init(joinedSessions: [Session], createdSessions: [Session]) {
        super.init(nibName: nil, bundle: nil)
        let joinedPollTypeModel = PollTypeModel(pollType: .joined, sessions: joinedSessions)
        let createdPollTypeModel = PollTypeModel(pollType: .created, sessions: createdSessions)
        pollTypeModels = [joinedPollTypeModel, createdPollTypeModel]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clickerGrey8

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        promptUserReview()
        setupViews()
        setupConstraints()
        presentAnnouncement { success in
            if success {
                Analytics.shared.log(with: AnnouncementPresentedPayload())
            }
        }
    }
    
    // MARK: - Configure
    func configure(joinedSessions: [Session], createdSessions: [Session]) {
        let joinedPollTypeModel = PollTypeModel(pollType: .joined, sessions: joinedSessions)
        let createdPollTypeModel = PollTypeModel(pollType: .created, sessions: createdSessions)
        pollTypeModels = [joinedPollTypeModel, createdPollTypeModel]
        DispatchQueue.main.async {
            self.adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    // MARK: - LAYOUT
    func setupViews() {
        headerGradientView = UIView()
        view.addSubview(headerGradientView)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)

        titleLabel = UILabel()
        titleLabel.text = titleLabelText
        titleLabel.font = ._30BoldFont
        titleLabel.textColor = .darkestGrey
        view.addSubview(titleLabel)
        
        pollsOptionsView = OptionsView(frame: .zero, options: [joinedPollsOptionsText, createdPollsOptionsText], sliderBarDelegate: self)
        view.addSubview(pollsOptionsView)
        
        let layout = UICollectionViewFlowLayout()
        pollsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        pollsCollectionView.bounces = false
        pollsCollectionView.showsVerticalScrollIndicator = false
        pollsCollectionView.showsHorizontalScrollIndicator = false
        pollsCollectionView.backgroundColor = .clickerGrey4
        pollsCollectionView.isPagingEnabled = true
        view.addSubview(pollsCollectionView)
        
        let updater: ListAdapterUpdater = ListAdapterUpdater()
        adapter = ListAdapter(updater: updater, viewController: self)
        adapter.collectionView = pollsCollectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        settingsButton = UIButton()
        settingsButton.setImage(#imageLiteral(resourceName: "black_settings"), for: .normal)
        settingsButton.imageEdgeInsets = LayoutConstants.buttonImageInsets
        settingsButton.addTarget(self, action: #selector(settingsAction), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        newGroupActivityIndicatorView = UIActivityIndicatorView(style: .gray)
        newGroupActivityIndicatorView.isHidden = true
        newGroupActivityIndicatorView.isUserInteractionEnabled = false
        view.addSubview(newGroupActivityIndicatorView)
        
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0
        view.addSubview(dimmingView)

        createSessionContainerView = UIView()
        createSessionContainerView.backgroundColor = .lightGrey
        view.addSubview(createSessionContainerView)

        createSessionButton = UIButton()
        createSessionButton.setTitle(createSessionButtonTitle, for: .normal)
        createSessionButton.setTitleColor(.lightGrey, for: .normal)
        createSessionButton.titleLabel?.font = ._16SemiboldFont
        createSessionButton.titleLabel?.textAlignment = .center
        createSessionButton.backgroundColor = .mediumGrey
        createSessionButton.layer.cornerRadius = codeTextFieldHeight / 2
        createSessionButton.alpha = 0.5
        createSessionButton.addTarget(self, action: #selector(createSession), for: .touchUpInside)
        view.addSubview(createSessionButton)

        createSessionTextField = UITextField()
        createSessionTextField.layer.cornerRadius = codeTextFieldHeight / 2
        createSessionTextField.borderStyle = .none
        createSessionTextField.font = ._16SemiboldFont
        createSessionTextField.backgroundColor = .mediumGrey2
        createSessionTextField.addTarget(self, action: #selector(didStartTypingGroupName), for: .editingChanged)
        createSessionTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: codeTextFieldEdgePadding, height: codeTextFieldHeight))
        createSessionTextField.leftViewMode = .always
        createSessionTextField.rightView = createSessionButton
        createSessionTextField.rightViewMode = .always
        createSessionTextField.attributedPlaceholder = NSAttributedString(string: createSessionTextFieldPlaceHolder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.mediumGrey, NSAttributedString.Key.font: UIFont._16SemiboldFont])
        createSessionTextField.textColor = .black
        createSessionContainerView.addSubview(createSessionTextField)
        
        joinSessionContainerView = UIView()
        joinSessionContainerView.backgroundColor = .darkestGrey
        view.addSubview(joinSessionContainerView)
        
        joinSessionButton = UIButton()
        joinSessionButton.setTitle(joinSessionButtonTitle, for: .normal)
        joinSessionButton.setTitleColor(.white, for: .normal)
        joinSessionButton.titleLabel?.font = ._16SemiboldFont
        joinSessionButton.titleLabel?.textAlignment = .center
        joinSessionButton.backgroundColor = .blueGrey
        joinSessionButton.layer.cornerRadius = codeTextFieldHeight / 2
        joinSessionButton.alpha = 0.5
        joinSessionButton.addTarget(self, action: #selector(joinSession), for: .touchUpInside)
        view.addSubview(joinSessionButton)
        
        codeTextField = UITextField()
        codeTextField.delegate = self
        codeTextField.layer.cornerRadius = codeTextFieldHeight / 2
        codeTextField.borderStyle = .none
        codeTextField.font = ._16SemiboldFont
        codeTextField.backgroundColor = .clickerGrey12
        codeTextField.addTarget(self, action: #selector(didStartTypingCode), for: .editingChanged)
        codeTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: codeTextFieldEdgePadding, height: codeTextFieldHeight))
        codeTextField.leftViewMode = .always
        codeTextField.rightView = joinSessionButton
        codeTextField.rightViewMode = .always
        codeTextField.attributedPlaceholder = NSAttributedString(string: codeTextFieldPlaceHolder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.clickerGrey13, NSAttributedString.Key.font: UIFont._16SemiboldFont])
        codeTextField.textColor = .white
        codeTextField.autocapitalizationType = .allCharacters
        joinSessionContainerView.addSubview(codeTextField)
        bottomPaddingView = UIView()
        bottomPaddingView.backgroundColor = .darkestGrey
        view.addSubview(bottomPaddingView)
    }
    
    func setupConstraints() {
        headerGradientView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-1 * UIApplication.shared.statusBarFrame.size.height)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width)
            make.centerX.equalToSuperview()
            make.height.equalTo(headerGradientHeight + UIApplication.shared.statusBarFrame.size.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(headerGradientView.snp.centerY).multipliedBy(1.2)
            make.centerX.equalToSuperview()
            make.height.equalTo(35.5)
        }
        
        pollsOptionsView.snp.makeConstraints { make in
            make.bottom.equalTo(headerGradientView.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        createSessionContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(joinSessionContainerViewHeight)
        }

        createSessionButton.snp.makeConstraints { make in
            make.width.equalTo(createSessionButtonWidth)
            make.height.equalTo(codeTextFieldHeight)
            make.centerY.trailing.equalToSuperview()
        }

        createSessionTextField.snp.makeConstraints { make in
            make.height.equalTo(codeTextFieldHeight)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(codeTextFieldHorizontalPadding)
            make.trailing.equalToSuperview().inset(codeTextFieldHorizontalPadding)
        }
        
        joinSessionContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(joinSessionContainerViewHeight)
        }

        joinSessionButton.snp.makeConstraints { make in
            make.width.equalTo(createSessionButtonWidth)
            make.height.equalTo(codeTextFieldHeight)
            make.centerY.trailing.equalToSuperview()
        }
        
        codeTextField.snp.makeConstraints { make in
            make.height.equalTo(codeTextFieldHeight)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(codeTextFieldHorizontalPadding)
            make.trailing.equalToSuperview().inset(codeTextFieldHorizontalPadding)
        }
        
        bottomPaddingView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(joinSessionContainerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        pollsCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(joinSessionContainerViewHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(pollsOptionsView.snp.bottom)
        }
        
        newGroupActivityIndicatorView.snp.makeConstraints { make in
            make.top.equalTo(createSessionContainerView.snp.top)
            make.width.equalTo(createSessionContainerView.snp.width)
            make.height.equalTo(createSessionContainerView.snp.height)
            make.trailing.equalTo(createSessionContainerView.snp.trailing)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(buttonPadding - LayoutConstants.buttonImageInsets.top)
            make.left.equalToSuperview().offset(buttonPadding - LayoutConstants.buttonImageInsets.left)
            make.size.equalTo(LayoutConstants.buttonSize)
        }
    }
    
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = headerGradientView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clickerGrey7.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        headerGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func generateCode() -> Future<Response<Code>> {
        return networking(Endpoint.generateCode()).decode()
    }
    
    func startSession(code: String, name: String, isGroup: Bool) -> Future<Response<Session>> {
        return networking(Endpoint.startSession(code: code, name: name, isGroup: isGroup)).decode()
    }
    
    func promptUserReview() {
        Ratings.shared.updateNumAppLaunches()
        Ratings.shared.promptReview()
    }

    func displayNewGroupActivityIndicatorView() {
        newGroupActivityIndicatorView.isHidden = false
        newGroupActivityIndicatorView.isUserInteractionEnabled = true
        newGroupActivityIndicatorView.startAnimating()
    }
    
    func hideNewGroupActivityIndicatorView() {
        newGroupActivityIndicatorView.stopAnimating()
        newGroupActivityIndicatorView.isHidden = true
        newGroupActivityIndicatorView.isUserInteractionEnabled = false
    }
    
    func joinSessionWithCode(with code: String) -> Future<Data> {
        return networking(Endpoint.joinSessionWithCode(with: code))
    }
    
    func getSortedPolls(with id: String) -> Future<Data> {
        return networking(Endpoint.getSortedPolls(with: id))
    }

    // MARK: - Actions
    @objc func createSession() {
        guard let name = createSessionTextField.text?.trim(), name != "" else { return }
        createSessionTextField.isEnabled = false
        updateCreateSessionButton(canCreate: false)
        displayNewGroupActivityIndicatorView()
            generateCode().chained { codeResponse -> Future<Response<Session>> in
                let code = codeResponse.data.code
                return self.startSession(code: code, name: name, isGroup: false)
            }.observe { [weak self] result in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .value(let sessionResponse):
                    let session = sessionResponse.data
                    session.isLive = false
                    self.hideNewGroupActivityIndicatorView()
                    let pollsDateViewController = PollsDateViewController(delegate: self, pollsDateArray: [], session: session, userRole: .admin)
                    self.navigationController?.pushViewController(pollsDateViewController, animated: true)
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    // Immediately launch to Create a Poll
                    pollsDateViewController.createPollBtnPressed()
                    Analytics.shared.log(with: CreatedGroupPayload())
                    self.createSessionTextField.text = ""
                case .error(let error):
                    print(error)
                    self.hideNewGroupActivityIndicatorView()
                    let alertController = self.createAlert(title: self.errorText, message: self.failedToCreateGroupText)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        self.createSessionTextField.isEnabled = true
    }
    
    @objc func joinSession() {
        guard let code = codeTextField.text?.trim(), code != "" else { return }
        codeTextField.isEnabled = false
        joinSessionWithCode(with: code).chained { sessionData -> Future<Data> in
            if let sessionResponse = try? self.jsonDecoder.decode(Response<Session>.self, from: sessionData) {
                self.session = sessionResponse.data
                return self.getSortedPolls(with: sessionResponse.data.id)
            }
            // Fail out of get sorted polls call
            return self.getSortedPolls(with: "")
        }.observe { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .value(let data):
                guard let pollsResponse = try? self.jsonDecoder.decode(Response<[GetSortedPollsResponse]>.self, from: data), pollsResponse.success else {
                    DispatchQueue.main.async {
                        let alertController = self.createAlert(title: self.errorText, message: self.joinSessionFailureMessage, actionTitle: "Okay")
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    guard let session = self.session else { return }
                    var pollsDateArray = [PollsDateModel]()
                    pollsResponse.data.forEach { response in
                        var mutableResponse = response
                        if let index = pollsDateArray.firstIndex(where: { $0.dateValue.isSameDay(as: mutableResponse.dateValue)}) {
                            pollsDateArray[index].polls.append(contentsOf: response.polls)
                        } else {
                            response.polls.forEach { poll in
                                pollsDateArray.append(PollsDateModel(date: response.date, polls: [poll]))
                            }
                        }
                        self.codeTextField.text = ""
                    }
                    
                    self.updateJoinSessionButton(canJoin: false)
                    let pollsDateViewController = PollsDateViewController(delegate: self, pollsDateArray: pollsDateArray.reversed(), session: session, userRole: .member)
                    self.navigationController?.pushViewController(pollsDateViewController, animated: true)
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    Analytics.shared.log(with: JoinedGroupPayload())
                }
            case .error(let error):
                print(error)
                DispatchQueue.main.async {
                    let alertController = self.createAlert(title: "Invalid code", message: self.joinSessionFailureMessage, actionTitle: "Okay")
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        self.codeTextField.isEnabled = true
    }
    
    func updateJoinSessionButton(canJoin: Bool) {
        UIView.animate(withDuration: joinSessionButtonAnimationDuration) {
            self.joinSessionButton.backgroundColor = canJoin ? .polloGreen : .blueGrey
            self.joinSessionButton.alpha = canJoin ? 1.0 : 0.5
        }
    }

    func updateCreateSessionButton(canCreate: Bool) {
        UIView.animate(withDuration: joinSessionButtonAnimationDuration) {
            self.createSessionButton.backgroundColor = canCreate ? .polloGreen : .blueGrey
            self.createSessionButton.alpha = canCreate ? 1.0 : 0.5
        }
    }
    
    @objc func settingsAction() {
        let settingsNavigationController = UINavigationController(rootViewController: SettingsViewController())
        self.present(settingsNavigationController, animated: true, completion: nil)
    }
    
    @objc func didStartTypingCode(_ textField: UITextField) {
        if let text = textField.text {
            textField.text = text.uppercased()
            updateJoinSessionButton(canJoin: text.trim().count == IntegerConstants.validCodeLength)
        }
    }

    @objc func didStartTypingGroupName(_ textField: UITextField) {
        if let text = textField.text {
            updateCreateSessionButton(canCreate: text.trim() != "")
        }
    }
    
    @objc func hideKeyboard() {
        // Hide keyboard when user taps outside of text field on popup view
        codeTextField.resignFirstResponder()
        createSessionTextField.resignFirstResponder()
    }
    
    @objc func reduceOpacity(sender: UIButton) {
        UIView.animate(withDuration: 0.35) {
            sender.alpha = 0.7
        }
    }
    
    @objc func resetOpacity(sender: UIButton) {
        UIView.animate(withDuration: 0.35) {
            sender.alpha = 1
        }
    }
    
    func joinSessionWithIdAndCode(id: String, code: String) -> Future<Response<Session>> {
        return networking(Endpoint.joinSessionWithIdAndCode(id: id, code: code)).decode()
    }
    
    func getPollSessions(with role: UserRole) -> Future<Response<[Session]>> {
        return networking(Endpoint.getPollSessions(with: role)).decode()
    }
    
    // MARK: - Helpers
    func reloadSessions(for userRole: UserRole, completion: (([Session]) -> Void)?) {
        getPollSessions(with: userRole).observe { result in
            DispatchQueue.main.async {
                switch result {
                case .value(let response):
                    var sessions = [Session]()
                    var auxiliaryDict = [Double: Session]()
                    response.data.forEach { session in
                        if let updatedAt = session.updatedAt, let latestActivityTimestamp = Double(updatedAt) {
                            auxiliaryDict[latestActivityTimestamp] = Session(id: session.id, name: session.name, code: session.code, latestActivity: getLatestActivity(latestActivityTimestamp: latestActivityTimestamp, code: session.code, role: userRole), isLive: session.isLive)
                        }
                    }
                    auxiliaryDict.keys.sorted().forEach { timestamp in
                        guard let session = auxiliaryDict[timestamp] else { return }
                        sessions.append(session)
                    }
                    completion?(sessions)
                case .error(let error):
                    print(error)
                }
            }
        }
    }
    
    // MARK: - View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.parent is UINavigationController {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        isListeningToKeyboard = true
        isOpeningGroup = false
        BannerController.shared.dismiss()
    }
    
    override func viewDidLayoutSubviews() {
        if gradientNeedsSetup {
            setupGradient() // needs headerGradientView to have been layed out, so it has a nonzero frame
            gradientNeedsSetup = false
        }
    }
    
    // MARK: - KEYBOARD
    @objc func keyboardWillShow(notification: NSNotification) {
        let hasPresentedViewController = self.presentedViewController != nil && !(self.presentedViewController is UIAlertController)
        if !isListeningToKeyboard || hasPresentedViewController { return }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let iphoneXBottomPadding = view.safeAreaInsets.bottom
            UIView.animate(withDuration: 0.5) {
                self.dimmingView.alpha = 1
            }
            joinSessionContainerView.snp.remakeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(keyboardSize.height - iphoneXBottomPadding)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(joinSessionContainerViewHeight)
            }
            joinSessionContainerView.superview?.layoutIfNeeded()
            createSessionContainerView.snp.remakeConstraints { make in

                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(keyboardSize.height - iphoneXBottomPadding)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(joinSessionContainerViewHeight)
            }
            createSessionContainerView.superview?.layoutIfNeeded()
            isKeyboardShown = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let hasPresentedViewController = self.presentedViewController != nil && !(self.presentedViewController is UIAlertController)
        if !isListeningToKeyboard || hasPresentedViewController { return }
        if (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue != nil {
            UIView.animate(withDuration: 0.5) {
                self.dimmingView.alpha = 0
            }
            joinSessionContainerView.snp.remakeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(joinSessionContainerViewHeight)
            }
            joinSessionContainerView.superview?.layoutIfNeeded()

            createSessionContainerView.snp.remakeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(joinSessionContainerViewHeight)
            }
            createSessionContainerView.superview?.layoutIfNeeded()
            isKeyboardShown = false
        }
    }

    // MARK: - Shake to send feedback
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let alert = createAlert(title: submitFeedbackTitle, message: submitFeedbackMessage)
            alert.addAction(UIAlertAction(title: submitFeedbackTitle, style: .default, handler: { _ in
                self.isListeningToKeyboard = false
                let feedbackVC = FeedbackViewController(type: .pollsViewController)
                self.navigationController?.pushViewController(feedbackVC, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
