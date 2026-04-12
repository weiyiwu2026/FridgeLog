import SwiftUI

struct FoodListView: View {

    @Binding var items: [FoodItem]
    let onItemSaved: (FoodItem) -> Void

    @State private var showAddItem    = false
    @State private var fridgeExpanded  = true
    @State private var freezerExpanded = true
    @State private var pantryExpanded  = true

    var fridgeItems:  [FoodItem] { items.filter { $0.storagePlace == "Fridge"  } }
    var freezerItems: [FoodItem] { items.filter { $0.storagePlace == "Freezer" } }
    var pantryItems:  [FoodItem] { items.filter { $0.storagePlace == "Pantry"  } }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "refrigerator")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No food added yet.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Tap + to add your first item.")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    if !fridgeItems.isEmpty {
                        StorageSection(title: "Fridge", icon: "refrigerator",
                                       isExpanded: $fridgeExpanded, items: fridgeItems)
                    }
                    if !freezerItems.isEmpty {
                        StorageSection(title: "Freezer", icon: "snowflake",
                                       isExpanded: $freezerExpanded, items: freezerItems)
                    }
                    if !pantryItems.isEmpty {
                        StorageSection(title: "Pantry", icon: "archivebox",
                                       isExpanded: $pantryExpanded, items: pantryItems)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Current Food List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddItem = true }) {
                    Image(systemName: "plus")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddItemMethodView(onItemSaved: { newItem in
                onItemSaved(newItem)
                showAddItem = false
            })
        }
    }
}

// MARK: - Collapsible Storage Section

struct StorageSection: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let items: [FoodItem]

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Label(title, systemImage: icon)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding()
            }

            if isExpanded {
                Divider()
                ForEach(items) { item in
                    ItemRow(item: item)
                        .padding(.horizontal)
                    if item.id != items.last?.id {
                        Divider().padding(.leading)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Item Row

struct ItemRow: View {
    let item: FoodItem

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private var expirationText: String {
        "Exp: \(Self.dateFormatter.string(from: item.expirationDate))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            HStack(spacing: 8) {
                Text(item.amountType == .portions ? "Prt: \(item.amountValue)" : "Qty: \(item.amountValue)")
                Text("·")
                Text(item.itemType)
                Text("·")
                Text(expirationText)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        FoodListView(items: .constant(sampleItems), onItemSaved: { _ in })
    }
    .environment(FoodNameStore())
}
