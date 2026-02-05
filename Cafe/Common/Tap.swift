//
//  Tap.swift
//  Cafe-iOS-Anton
//
//  Created by Антон Абалуев on 29.11.2025.
//

import UIKit

protocol Tap: AnyObject {
}

extension Tap {
    @discardableResult func tap(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension UIView: Tap {}
