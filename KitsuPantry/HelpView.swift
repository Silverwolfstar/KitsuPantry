//
//  HelpView.swift
//  KitsuPantry
//
//  Created by Silver WolfStar on 8/30/25.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Deleting Items").foregroundColor(AppColor.sectionTitle)) {
                    FormRow {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("In any list, swipe **left** on an item and tap **Delete** to remove it.")
                        }
                        .foregroundStyle(AppColor.basicText)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tip: Swipe all the way left to confirm in one motion.")
                        }
                        .font(.footnote)
                        .foregroundColor(AppColor.secondaryText)
                    }
                }
            }
            .appFormInsets(content: 16, line: 0)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(0)
            .listRowSpacing(0)
            .appBackground()
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        // No presentationDetents — matches Add Item’s default sheet style
    }
}
