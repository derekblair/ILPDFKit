//
//  ILPDFKit.swift
//  ILPDFKit
//
//  Created by Derek Blair on 2016-03-19.
//  Copyright © 2016 Derek Blair. All rights reserved.
//

import Foundation
import UIKit


public extension UIView {
    func activePDFTextField() -> ILPDFFormTextField? {
        if let t = self as? ILPDFFormTextField , t.textFieldOrTextView.isFirstResponder {
            return t
        }
        for subview in subviews {
            let activeField = subview.activePDFTextField()
            if activeField != nil {
                return activeField
            }
        }
        return nil
    }

    public func pinToSuperview(_ insets : UIEdgeInsets) {
        if let sv = superview {
            translatesAutoresizingMaskIntoConstraints = false
            let guide = UILayoutGuide()
            sv.addLayoutGuide(guide)
            NSLayoutConstraint.activate([
                guide.topAnchor.constraint(equalTo: sv.topAnchor),
                guide.bottomAnchor.constraint(equalTo: sv.bottomAnchor),
                guide.leadingAnchor.constraint(equalTo: sv.leadingAnchor),
                guide.trailingAnchor.constraint(equalTo: sv.trailingAnchor)
                ])
            pinToSuperview(insets,guide:guide)
        }
    }

    public func pinToSuperview(_ insets : UIEdgeInsets, guide:UILayoutGuide) {
        if superview != nil {
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: guide.topAnchor,constant:insets.top),
                bottomAnchor.constraint(equalTo: guide.bottomAnchor,constant:-insets.bottom),
                leadingAnchor.constraint(equalTo: guide.leadingAnchor,constant:insets.left),
                trailingAnchor.constraint(equalTo: guide.trailingAnchor,constant:-insets.right)
                ])
        }
    }

}
