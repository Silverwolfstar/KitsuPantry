//
//  UIResponder+Extension.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import UIKit

extension UIWindow {
    var firstResponder: UIResponder? {
        return self.rootViewController?.view.findFirstResponder()
    }
}

extension UIView {
    func findFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
