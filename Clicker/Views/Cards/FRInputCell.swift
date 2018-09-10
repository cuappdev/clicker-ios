//
//  FRInputCell.swift
//  Clicker
//
//  Created by Kevin Chan on 9/10/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit

protocol FRInputCellDelegate {
    
}

class FRInputCell: UICollectionViewCell {
    
    // MARK: - View vars
    var inputTextField: UITextField!
    
    // MARK: - Data vars
    var delegate: FROptionCellDelegate!
    
    // MARK: - Constants
    let textFieldCornerRadius: CGFloat = 25
    let textFieldBorderWidth: CGFloat = 1
    let textFieldTextInset: CGFloat = 18
    let textFieldHorizontalPadding: CGFloat = 16.5
    let textFieldVerticalPadding: CGFloat = 8.5
    let textFieldPlaceholder = "Type a response"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clickerWhite
        setupViews()
    }
    
    // MARK: - Layout
    func setupViews() {
        inputTextField = UITextField()
        inputTextField.layer.cornerRadius = textFieldCornerRadius
        inputTextField.layer.borderWidth = textFieldBorderWidth
        inputTextField.layer.borderColor = UIColor.clickerGrey5.cgColor
        inputTextField.font = ._16MediumFont
        inputTextField.layer.sublayerTransform = CATransform3DMakeTranslation(textFieldTextInset, 0, 0)
        inputTextField.placeholder = textFieldPlaceholder
        inputTextField.returnKeyType = .send
        inputTextField.delegate = self
        contentView.addSubview(inputTextField)
    }
    
    override func updateConstraints() {
        inputTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(textFieldVerticalPadding)
            make.leading.equalToSuperview().offset(textFieldHorizontalPadding)
            make.trailing.equalToSuperview().inset(textFieldHorizontalPadding)
            make.bottom.equalToSuperview().inset(textFieldVerticalPadding)
        }
        super.updateConstraints()
    }
    
    // MARK: - Configure
    func configure() {
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FRInputCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return false
    }
    
}