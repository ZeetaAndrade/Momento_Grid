//
//  Extensions.swift
//  GridSystemTouchMac
//
//  Created by Zeeta Andrade on 25/03/22.
//

import Foundation
import Cocoa

extension NSColor {
    static var random: NSColor {
        return NSColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}


extension CGPoint {
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
}
