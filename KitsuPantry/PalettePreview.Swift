//
//  PalettePreview.swift
//  KitsuPantry
//
//  Created by Silver on 8/28/25.
//

#if DEBUG
import SwiftUI

struct PalettePreview: View {
    func swatch(_ name: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                )
            Text(name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(width: 92)
        }
        .padding(4)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("AppColor Palette")
                    .font(.title3).bold()
                    .padding(.bottom, 8)

                // Define grid with 3 columns
                let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

                Group {
                    Text("Core").font(.headline)
                    LazyVGrid(columns: columns, spacing: 16) {
                        swatch("bg", AppColor.bg)
                        swatch("navDark", AppColor.navDark)
                        swatch("titleText", AppColor.titleText)
                        swatch("sectionTitle", AppColor.sectionTitle)
                        swatch("notesBg", AppColor.notesBg)
                    }
                }

                Group {
                    Text("Buttons").font(.headline)
                    LazyVGrid(columns: columns, spacing: 16) {
                        swatch("addBtnEnabled", AppColor.addBtnEnabled)
                        swatch("addBtnDisabled", AppColor.addBtnDisabled)
                    }
                }

                Group {
                    Text("Text / Accents").font(.headline)
                    LazyVGrid(columns: columns, spacing: 16) {
                        swatch("invalidNote", AppColor.invalidNote)
                        swatch("secondaryText", AppColor.secondaryText)
                    }
                }

                Group {
                    Text("Cards").font(.headline)
                    LazyVGrid(columns: columns, spacing: 16) {
                        swatch("cardFill", AppColor.cardFill)
                        swatch("cardShadow", AppColor.cardShadow)
                    }
                }

                Group {
                    Text("Icons").font(.headline)
                    LazyVGrid(columns: columns, spacing: 16) {
                        swatch("confirmGreen", AppColor.confirmGreen)
                        swatch("cancelRed", AppColor.cancelRed)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    PalettePreview()
        .preferredColorScheme(.light)
}
#endif
