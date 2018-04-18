//
//  GroupPreviewCell.swift
//  Clicker
//
//  Created by eoin on 4/16/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit

enum GroupType {
    case created
    case joined
}

class GroupsCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    var groupsTableView: UITableView!
    var sessions: [Session] = [] // JOINED: [[Session]], CREATED: [Session]
    
    var groupType: GroupType!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        getSessions()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - TABLEVIEW
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupPreviewCellID", for: indexPath) as! GroupPreviewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82.2
    }
    
    
    // MARK: - LAYOUT
    func setupViews() {
        groupsTableView = UITableView()
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        groupsTableView.register(GroupPreviewCell.self, forCellReuseIdentifier: "groupPreviewCellID")
        groupsTableView.separatorStyle = .none
        addSubview(groupsTableView)
    }
    
    func setupConstraints() {
        groupsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // GET SESSIONS
    func getSessions() {
        let role: UserRole
        if (groupType == .created) {
            role = .admin
        } else {
            role = .member
        }
        GetGroupSessions(role: String(describing: role)).make()
            .done { sessions in
                self.sessions = sessions
                DispatchQueue.main.async { self.groupsTableView.reloadData() }
            } .catch { error in
                print(error)
            }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

