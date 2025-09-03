//
//  ItemListView.swift
//  KitsuPantry
//
//  Created by Silver on 7/29/25.
//

import SwiftUI
import CoreData

enum ItemFilter {
    case all
    case location(LocationEntity)
}

struct ItemsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isManagingTabs = false
    
    @AppStorage("expiringSoonDays") private var expiringSoonDays = 3
    @AppStorage("highlightExpired") private var highlightExpired = true
    @AppStorage("highlightExpiringSoon") private var highlightExpiringSoon = true
    @AppStorage("showStatusBanner") private var showStatusBanner = true
    @State private var showingStatusSheet = false
    @State private var statusSheetMode: StatusMode? = nil
    enum StatusMode { case expired, soon }
    
    @Binding var locations: [LocationEntity]
    @AppStorage("showObtainedDate") private var showObtainedDate = true

    @FetchRequest private var items: FetchedResults<FoodItemEntity>

    enum ActiveSheet: Identifiable {
        case add(defaultLocation: String?)
        case edit(FoodItemEntity)

        var id: AnyHashable {
            switch self {
            case .add(let defaultLocation):
                return defaultLocation ?? "new"
            case .edit(let item):
                return item.objectID
            }
        }
    }

    @State private var activeSheet: ActiveSheet?
    private let title: String
    private let defaultLocationForAdd: String?

    init(filter: ItemFilter, title: String, locations: Binding<[LocationEntity]>) {
        self.title = title
        self._locations = locations

        switch filter {
        case .all:
            _items = FetchRequest(
                entity: FoodItemEntity.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \FoodItemEntity.expirationDate, ascending: true)],
                animation: .default
            )
            self.defaultLocationForAdd = nil
        case .location(let location):
            _items = FetchRequest(
                entity: FoodItemEntity.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \FoodItemEntity.expirationDate, ascending: true)],
                predicate: NSPredicate(format: "location == %@", location),
                animation: .default
            )
            self.defaultLocationForAdd = location.name
        }
    }
    
    private func daysUntil(_ date: Date?) -> Int? {
        guard let date else { return nil }
        let start = Calendar.current.startOfDay(for: Date())
        let end   = Calendar.current.startOfDay(for: date)
        return Calendar.current.dateComponents([.day], from: start, to: end).day
    }

    private enum ItemStatus { case expired, expiringSoon, normal }

    private func status(for item: FoodItemEntity) -> ItemStatus {
        guard let d = item.expirationDate, let days = daysUntil(d) else { return .normal }
        if days < 0 { return .expired }
        if days >= 0 && days <= expiringSoonDays { return .expiringSoon }
        return .normal
    }

    private var expiredCount: Int {
        items.filter { status(for: $0) == .expired }.count
    }

    private var expiringSoonCount: Int {
        items.filter { status(for: $0) == .expiringSoon }.count
    }

    private var expiredItems: [FoodItemEntity] {
        items.filter { status(for: $0) == .expired }
    }

    private var expiringSoonItems: [FoodItemEntity] {
        items.filter { status(for: $0) == .expiringSoon }
    }


    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                if(showStatusBanner){
                    VStack(spacing: 8) {
                        if expiredCount > 0 {
                            Button {
                                statusSheetMode = .expired
                                showingStatusSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("You have \(expiredCount) expired item\(expiredCount == 1 ? "" : "s")")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                }
                                .foregroundColor(AppColor.bannerText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(AppColor.bannerBgExpired)
                                )
                            }
                            .buttonStyle(.plain)
                        } else if expiringSoonCount > 0 {
                            Button {
                                statusSheetMode = .soon
                                showingStatusSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "clock.badge.exclamationmark")
                                    Text("Expiring soon: \(expiringSoonCount)")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                }
                                .foregroundColor(AppColor.bannerText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(AppColor.bannerBgSoon)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                List {
                    ForEach(items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name ?? "Unnamed")
                                    .font(.headline)

                                let locationName = item.location?.name ?? "Unknown"
                                let formattedQty = String(format: "%.2f", item.quantity)
                                    .replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)

                                Text("\(locationName) — Qty: \(formattedQty)")

                                if let date = item.expirationDate {
                                    Text("Expires: \(formatted(date: date))")
                                        .font(.caption)
                                        .foregroundColor(AppColor.sectionTitle)
                                }

                                if showObtainedDate, let obtained = item.obtainedDate {
                                    Text("Obtained: \(formatted(date: obtained))")
                                        .font(.caption)
                                        .foregroundColor(AppColor.secondaryText)
                                }

                                if let notes = item.notes?.trimmingCharacters(in: .whitespacesAndNewlines),
                                   !notes.isEmpty {
                                    Text("Notes:\n\(notes)")
                                        .font(.subheadline)
                                        .foregroundColor(AppColor.secondaryText)
                                        .padding(.top, 2)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColor.cardFill)
                                    .shadow(color: AppColor.cardShadow, radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(
                                        {
                                            switch status(for: item) {
                                            case .expired where highlightExpired:
                                                return AppColor.expiredBorder
                                            case .expiringSoon where highlightExpiringSoon:
                                                return AppColor.expiringBorder
                                            default:
                                                return Color.clear
                                            }
                                        }(),
                                        lineWidth: 2
                                    )
                            )
                            .padding(.vertical, 6)

                        }
                        .contentShape(Rectangle()) // Makes entire row tappable
                        .onTapGesture {
                            activeSheet = .edit(item)
                        }
                        .listRowInsets(EdgeInsets()) // remove all default padding
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }

                .scrollContentBackground(.hidden)
                .listSectionSpacing(0)
                .listStyle(.plain)
            }
            .appBackground() 
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.navDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isManagingTabs = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .foregroundColor(AppColor.navBarButtons)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activeSheet = .add(defaultLocation: defaultLocationForAdd)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppColor.titleText)
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add(let defaultLoc):
                    ItemFormView(mode: .add(defaultLocation: defaultLoc), locations: $locations)
                case .edit(let item):
                    ItemFormView(mode: .edit(item), locations: $locations)
                }
            }
            .navigationDestination(isPresented: $isManagingTabs) {
                SettingsView()
            }
            .sheet(isPresented: $showingStatusSheet) {
                StatusListSheet(
                    mode: statusSheetMode ?? .expired,
                    items: statusSheetMode == .expired ? expiredItems : expiringSoonItems,
                    showObtainedDate: showObtainedDate
                )
            }

        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(items[index])
        }
        try? viewContext.save()
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

private struct StatusListSheet: View {
    let mode: ItemsListView.StatusMode
    let items: [FoodItemEntity]
    let showObtainedDate: Bool
    @Environment(\.dismiss) private var dismiss

    var title: String {
        switch mode {
        case .expired: return "Expired Items"
        case .soon:    return "Expiring Soon"
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name ?? "Unnamed")
                            .font(.headline)
                        if let date = item.expirationDate {
                            Text("Expires: \(format(date))")
                                .font(.caption)
                        }
                        if showObtainedDate, let got = item.obtainedDate {
                            Text("Obtained: \(format(got))")
                                .font(.caption)
                                .foregroundColor(AppColor.secondaryText)
                        }
                        if let notes = item.notes?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !notes.isEmpty {
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(AppColor.secondaryText)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .scrollContentBackground(.hidden)
            .appBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func format(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

