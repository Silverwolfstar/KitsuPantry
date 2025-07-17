//
//  SelectAllTextField.swift
//  KitsuPantry
//
//  Created by Silver on 7/17/25.
//

import SwiftUI
import UIKit

struct SelectAllTextField: UIViewRepresentable {
    @Binding var value: Int
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = String(value)

        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
            DispatchQueue.main.async {
                uiView.selectAll(nil)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var value: Binding<Int>

        init(value: Binding<Int>) {
            self.value = value
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            if let text = textField.text, let newValue = Int(text) {
                value.wrappedValue = newValue
            }
        }
    }
}
