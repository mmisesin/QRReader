//
//  Colors.swift
//  QRReader
//
//  Created by Artem Misesin on 5/5/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: Double) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(alpha))
    }
}

struct Colors {
    
    static var settingsText = UIColor(hexString: "#74767B", alpha: 1)
    static var settingsAltText = UIColor(hexString: "#555555", alpha: 1)
    static var mainTextColor = UIColor(hexString: "#E4E5E6", alpha: 1)
    static var mainBackground = UIColor(hexString: "#0D0D0D", alpha: 1)
    static var labelsBackground = UIColor(hexString: "#FFE187", alpha: 0.1)
    static var deleteColor = UIColor(hexString: "#FFC61A", alpha: 1)
    static var cellTextColor = UIColor(hexString: "#6E737A", alpha: 1)
    static var settingsMainTint = UIColor(hexString: "#171717", alpha: 1)
    static var barColor = UIColor(hexString: "#030303", alpha: 0.5)
    static var bottomBar = UIColor(hexString: "#151515", alpha: 0.5)
    static var navShadow = UIColor(hexString: "#25272B", alpha: 1)
    static var accessoryViewColor = UIColor(hexString: "#313337", alpha: 1)
    static var settingsShadows = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    static let selectionColor = UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1)

}
