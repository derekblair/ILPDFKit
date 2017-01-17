//
//  ILPDFKit.swift
//  ILPDFKit
//
//  Created by Derek Blair on 2016-03-19.
//  Copyright © 2016 Derek Blair. All rights reserved.
//

import Foundation


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
}
