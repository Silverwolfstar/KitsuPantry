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
    static let navBarButtons = Color.white
    static let titleText = Color.white
    static let sectionTitle = Color.black
    static let basicText = Color.black
    
    // Add item page
    static let notesBg = Color.white
    static let notesBorder = bg
    static let separator = notesBorder

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
    
    // ContentView
    static let tabBackground = Color.white
    static let tabSelected   = Color.black.opacity(0.1)
    static let tabUnselected = tabBackground
    static let tabTextSelected = Color.black
    static let tabTextUnselected = Color.black.opacity(0.7)
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

private struct AppFormInsetsKey: EnvironmentKey {
    static let defaultValue: (content: CGFloat, line: CGFloat?) = (16, nil)
}
extension EnvironmentValues {
    var appFormInsets: (content: CGFloat, line: CGFloat?) {
        get { self[AppFormInsetsKey.self] }
        set { self[AppFormInsetsKey.self] = newValue }
    }
}
extension View {
    /// Set default content inset and separator line inset for all `FormRow`s in this subtree.
    func appFormInsets(content: CGFloat = 16, line: CGFloat? = nil) -> some View {
        environment(\.appFormInsets, (content, line))
    }
}

struct FormRow<Content: View>: View {
    @Environment(\.appFormInsets) private var envInsets
    
    var showSeparator: Bool = true
    var contentInset: CGFloat? = nil
    var lineInset: CGFloat? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        let ci = contentInset ?? envInsets.content
        let li = lineInset ?? envInsets.line ?? ci
        content()
            .padding(.vertical, 10)
            .listRowInsets(EdgeInsets(top: 0, leading: ci, bottom: 0, trailing: ci))
            .overlay(alignment: .bottom) {
                if(showSeparator) {
                    Rectangle()
                        .fill(AppColor.separator)
                        .frame(height: 1)
                        .padding(.leading, li)
                }
            }
    }
}
