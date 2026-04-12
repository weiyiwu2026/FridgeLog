import SwiftUI

// MARK: - Sort and Filter State Types

// Three explicit states make the two screen modes very clear in code:
//   .defaultMode  → 7-day window only, sorted ascending (the opening state)
//   .oldest       → ALL items, sorted ascending
//   .newest       → ALL items, sorted descending
enum ExpirySortOption {
    case defaultMode   // 7-day window, ascending — initial state
    case oldest        // all items, ascending
    case newest        // all items, descending
}

enum ExpiryFilterOption: Equatable {
    case none
    case storagePlace(String)
    case itemType(String)
}

// MARK: - Expiring Soon Screen

struct ExpiringSoonView: View {

    let items: [FoodItem]

    @State private var sortOption: ExpirySortOption     = .defaultMode
    @State private var filterOption: ExpiryFilterOption = .none

    // ── Step 1: base set depends on the sort mode ─────────────
    //   defaultMode → only items expiring within the next 7 days
    //   oldest / newest → all items in the inventory
    private var baseItems: [FoodItem] {
        switch sortOption {
        case .defaultMode:
            let cutoff = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            return items.filter { $0.expirationDate <= cutoff }
        case .oldest, .newest:
            return items
        }
    }

    // ── Step 2: apply the user's filter on top of the base set ─
    private var filteredItems: [FoodItem] {
        switch filterOption {
        case .none:
            return baseItems
        case .storagePlace(let place):
            return baseItems.filter { $0.storagePlace == place }
        case .itemType(let type):
            return baseItems.filter { $0.itemType == type }
        }
    }

    // ── Step 3: apply sort ─────────────────────────────────────
    private var displayItems: [FoodItem] {
        switch sortOption {
        case .defaultMode, .oldest:
            return filteredItems.sorted { $0.expirationDate < $1.expirationDate }
        case .newest:
            return filteredItems.sorted { $0.expirationDate > $1.expirationDate }
        }
    }

    // ── Filter values come from whatever the current base set is ─
    private var availableStoragePlaces: [String] {
        Array(Set(baseItems.map { $0.storagePlace })).sorted()
    }

    private var availableItemTypes: [String] {
        Array(Set(baseItems.map { $0.itemType })).sorted()
    }

    private var isFilterActive: Bool { filterOption != .none }
    private var isFullListMode: Bool { sortOption == .oldest || sortOption == .newest }

    private var activeFilterLabel: String {
        switch filterOption {
        case .none:                return ""
        case .storagePlace(let p): return p
        case .itemType(let t):     return t
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // ── Mode banner: shown when user has left the default 7-day mode ──
                if isFullListMode {
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.secondary)
                        Text("Showing all items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Back to 7 days") {
                            sortOption   = .defaultMode
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 4)
                }

                // ── Active filter chip ──────────────────────────────────────────
                if isFilterActive {
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("Filtered by: \(activeFilterLabel)")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                        Spacer()
                        Button("Clear") { filterOption = .none }
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 4)
                }

                // ── Items list or empty state ───────────────────────────────────
                if displayItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: isFilterActive
                              ? "line.3.horizontal.decrease.circle"
                              : "checkmark.seal")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text(isFilterActive
                             ? "No items match this filter."
                             : "Nothing expiring soon.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text(isFilterActive
                             ? "Try a different filter or tap Clear."
                             : "You are all good for the next 7 days.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    VStack(spacing: 0) {
                        ForEach(displayItems) { item in
                            ExpiringSoonRow(item: item)
                                .padding(.horizontal)
                            if item.id != displayItems.last?.id {
                                Divider().padding(.leading)
                            }
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Expiring Soon")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {

                // ── Sort Menu ───────────────────────────────────────────────────
                Menu {
                    Button { sortOption = .defaultMode } label: {
                        sortOption == .defaultMode
                            ? Label("Default (Next 7 Days)", systemImage: "checkmark")
                            : Label("Default (Next 7 Days)", systemImage: "")
                    }
                    Button { sortOption = .oldest } label: {
                        sortOption == .oldest
                            ? Label("Oldest First (All Items)", systemImage: "checkmark")
                            : Label("Oldest First (All Items)", systemImage: "")
                    }
                    Button { sortOption = .newest } label: {
                        sortOption == .newest
                            ? Label("Newest First (All Items)", systemImage: "checkmark")
                            : Label("Newest First (All Items)", systemImage: "")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }

                // ── Filter Menu ─────────────────────────────────────────────────
                Menu {
                    Button { filterOption = .none } label: {
                        filterOption == .none
                            ? Label("No Filter", systemImage: "checkmark")
                            : Label("No Filter", systemImage: "")
                    }

                    if !availableStoragePlaces.isEmpty {
                        Menu("Storage Place") {
                            ForEach(availableStoragePlaces, id: \.self) { place in
                                Button { filterOption = .storagePlace(place) } label: {
                                    filterOption == .storagePlace(place)
                                        ? Label(place, systemImage: "checkmark")
                                        : Label(place, systemImage: "")
                                }
                            }
                        }
                    }

                    if !availableItemTypes.isEmpty {
                        Menu("Item Type") {
                            ForEach(availableItemTypes, id: \.self) { type in
                                Button { filterOption = .itemType(type) } label: {
                                    filterOption == .itemType(type)
                                        ? Label(type, systemImage: "checkmark")
                                        : Label(type, systemImage: "")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: isFilterActive
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
}

// MARK: - Expiring Soon Row

struct ExpiringSoonRow: View {
    let item: FoodItem

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    // Days from start of today to start of expiration day
    private var daysLeft: Int {
        let today  = Calendar.current.startOfDay(for: Date())
        let expiry = Calendar.current.startOfDay(for: item.expirationDate)
        return max(0, Calendar.current.dateComponents([.day], from: today, to: expiry).day ?? 0)
    }

    private var daysLeftText: String {
        switch daysLeft {
        case 0:  return "Expires today"
        case 1:  return "1 day left"
        default: return "\(daysLeft) days left"
        }
    }

    // Red = 0–2 days, Orange = 3–5 days, Yellow = 6–7 days, secondary = 8+ days
    private var urgencyColor: Color {
        switch daysLeft {
        case 0...2: return .red
        case 3...5: return .orange
        case 6...7: return .yellow
        default:    return .secondary
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    Text(item.storagePlace)
                    Text("·")
                    Text(item.itemType)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(daysLeftText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(urgencyColor)
                Text(Self.dateFormatter.string(from: item.expirationDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationView {
        ExpiringSoonView(items: sampleItems)
    }
}
