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

    // Buttons
    static let addBtnEnabled  = Color(red: 0.40, green: 0.45, blue: 0.62)
    static let addBtnDisabled = Color.gray.opacity(0.4)

    // Text accents
    static let invalidNote = Color.red
    static let sectionTitle = Color.black
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
