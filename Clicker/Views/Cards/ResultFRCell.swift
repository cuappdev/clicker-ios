//
//  ResultFRCell.swift
//  Clicker
//
//  Created by Kevin Chan on 3/17/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit
import SnapKit

class ResultFRCell: UITableViewCell {
    
    var response: String!
    var count: Int!
    var freeResponseLabel: UILabel!
    var rightView: UIView!
    var countLabel: UILabel!
    var triangleImageView: UIImageView!
    
    //MARK: - INITIALIZATION
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        clipsToBounds = true
        
        setupViews()
        setupConstraints()
    }
    
    //MARK: - LAYOUT
    func setupViews() {
        freeResponseLabel = UILabel()
        freeResponseLabel.font = UIFont._14MediumFont
        freeResponseLabel.backgroundColor = .white
        freeResponseLabel.lineBreakMode = .byWordWrapping
        freeResponseLabel.numberOfLines = 0
        addSubview(freeResponseLabel)
        
        rightView = UIView()
        rightView.backgroundColor = .white
        addSubview(rightView)
        
        countLabel = UILabel()
        countLabel.font = ._12SemiboldFont
        countLabel.textColor = .clickerBlue
        countLabel.textAlignment = .center
        rightView.addSubview(countLabel)
        
        triangleImageView = UIImageView(image: #imageLiteral(resourceName: "blueTriangle"))
        triangleImageView.contentMode = .scaleAspectFit
        rightView.addSubview(triangleImageView)
    }
    
    func setupConstraints() {
        freeResponseLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview()
        }
        
        rightView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(13)
            make.height.equalTo(30)
        }
        
        countLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
        
        triangleImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(countLabel.snp.top)
        }
    }
    
    func configure() {
        freeResponseLabel.text = response
        countLabel.text = "\(count)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}