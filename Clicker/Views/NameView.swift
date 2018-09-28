//
//  BlurView.swift
//  Clicker
//
//  Created by eoin on 4/27/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import UIKit

protocol NameViewDelegate {
    func nameViewDidUpdateSessionName()
}

class NameView: UIView, UITextFieldDelegate {

    var titleField: UITextField!
    
    var session: Session!
    var delegate: NameViewDelegate!
    
    init (frame: CGRect, session: Session, delegate: NameViewDelegate) {
        super.init(frame: frame)
        self.session = session
        self.delegate = delegate
        backgroundColor = .clickerBlack2
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        titleField = UITextField()
        titleField.attributedPlaceholder = NSAttributedString(string: "Give your group a name...", attributes: [NSAttributedStringKey.foregroundColor: UIColor.clickerGrey2, NSAttributedStringKey.font: UIFont._24MediumFont])
        if (session.code != session.name) {
            titleField.text = session.name
        }
        titleField.font = ._24MediumFont
        titleField.textColor = .clickerWhite
        titleField.textAlignment = .center
        titleField.delegate = self
        titleField.becomeFirstResponder()
        titleField.keyboardType = .asciiCapable
        addSubview(titleField)
        
    }
    
    func setupConstraints() {
        titleField.snp.makeConstraints { make in
            make.height.equalTo(27)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var name: String
        if let text = textField.text {
            name = text
        } else {
            name = session.code
        }
        UpdateSession(id: session.id, name: name, code: session.code).make()
            .done { code in
                self.session.name = name
                self.delegate.nameViewDidUpdateSessionName()
                self.removeFromSuperview()
            }.catch { error in
                print("error: ", error)
            }
        
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
