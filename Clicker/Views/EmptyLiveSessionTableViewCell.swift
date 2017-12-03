//
//  EmptyLiveSessionTableViewCell.swift
//  Clicker
//
//  Created by Keivan Shahida on 11/29/17.
//  Copyright © 2017 CornellAppDev. All rights reserved.
//

import UIKit
import SnapKit

class EmptyLiveSessionTableViewCell: UITableViewCell {

    var cellLabel: UILabel!
    
    // MARK: - INITIALIZATION
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LAYOUT
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        cellLabel = UILabel(frame: .zero)
        cellLabel.clipsToBounds = false
        cellLabel.textColor = .black
        cellLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cellLabel.text = "No live sessions 😭"
        cellLabel.textAlignment = .center
        contentView.addSubview(cellLabel)
        
        setConstraints()
    }
    
    func setConstraints() {
        cellLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
