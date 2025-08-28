//
//  Theme.swift
//  KitsuPantry
//
//  Created by Silver on 8/27/25.
//

import SwiftUI

// SwiftUI-facing colors
enum AppColor {
    // Core palette
    static let bg = Color(red: 0.72, green: 0.78, blue: 0.89) // silver-blue background
    static let navDark = Color(white: 0.27) // matches nav bar
    static let titleText = Color.white
    static let sectionTitle = Color.black
    static let notesBg = Color.white
    static let notesBorder = secondaryText.opacity(0.3)

    // Buttons
    static let addBtnEnabled = Color(red: 0.40, green: 0.45, blue: 0.62)
    static let addBtnDisabled = Color.gray.opacity(0.4)

    // Text accents
    static let invalidNote = Color.red
    static let secondaryText = Color.gray   // for subtle captions, “coming soon”, etc.
    
    // Cards
    static let cardFill = Color.white
    static let cardShadow = Color.black.opacity(0.3)
    
    // Small icons (confirm/cancel)
    static let confirmGreen = Color.green
    static let cancelRed = Color.red
}

// UIKit-facing colors (for UINavigationBarAppearance, etc.)
enum AppUIColor {
    static let navDark = UIColor(white: 0.27, alpha: 1.0)
}

extension View {
    func appBackground() -> some View {
        self.background(AppColor.bg.ignoresSafeArea())
    }
}
