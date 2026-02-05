//
//  Shark.swift
//  Cafe
//
//  Created by Антон Абалуев on 21.12.2025.
//

import UIKit

// swiftlint:disable all
// swiftformat:disable all
private let bundle: Bundle = {
    class Custom {}
    return Bundle(for: Custom.self)
}()

public enum Shark {
    public enum I: CaseIterable {
        public static var appIcon: UIImage { return UIImage(named:"appIcon", in: bundle, compatibleWith: nil)! }
        public static var logoImage: UIImage { return UIImage(named:"logoImage", in: bundle, compatibleWith: nil)! }
        public static var activeCustomImage: UIImage { return UIImage(named:"activeCustomImage", in: bundle, compatibleWith: nil)! }
        public static var inactiveCustomImage: UIImage { return UIImage(named:"inactiveCustomImage", in: bundle, compatibleWith: nil)! }
        public static var category: UIImage { return UIImage(named:"category", in: bundle, compatibleWith: nil)! }
    }

    public enum C: CaseIterable {
        public static var accentColor: UIColor { return UIColor(named: "AccentColor", in: bundle, compatibleWith: nil)! }
        public static var blueGreyDarken1: UIColor { return UIColor(named: "blueGreyDarken1", in: bundle, compatibleWith: nil)! }
        public static var blueGreyDarken3: UIColor { return UIColor(named: "blueGreyDarken3", in: bundle, compatibleWith: nil)! }
    }

    public enum S {
        public static var LaunchScreen: UIStoryboard { return UIStoryboard(name: "LaunchScreen", bundle: bundle) }
    }

    public enum D: CaseIterable {
    }
}
