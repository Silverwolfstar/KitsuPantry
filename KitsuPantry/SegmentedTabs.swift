//
//  SegmentedTabs.swift
//  KitsuPantry
//
//  Created by Silver on 8/29/25.
//

import SwiftUI

struct SegmentedTabs<ID: Hashable>: View {
    let items: [ID]
    let title: (ID) -> String
    @Binding var selection: ID
    
    private let barHeight: CGFloat = 36
    private let outerBarPadding: CGFloat = 1      // the rounded container's inner padding
    private let pillSpacing: CGFloat = 1
    private let pillHInset: CGFloat = 12

    var body: some View {
        HStack(spacing: pillSpacing) {
            ForEach(items, id: \.self) { id in
                let isSelected = (id == selection)
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? AppColor.tabSelected : AppColor.tabUnselected)
                        .frame(height: barHeight - (outerBarPadding * 2))
                    Text(title(id))
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .foregroundColor(isSelected ? AppColor.tabTextSelected : AppColor.tabTextUnselected)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { selection = id }
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .frame(height: barHeight) // bar height locked
        .padding(outerBarPadding) // defines the inner edge the pill touches
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColor.tabBackground)
        )
        .animation(.easeInOut(duration: 0.18), value: selection)
    }
}
