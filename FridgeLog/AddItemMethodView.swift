import SwiftUI

struct AddItemMethodView: View {
    @Environment(\.dismiss) private var dismiss

    // Passed in from ContentView — called when a new item is saved
    let onItemSaved: (FoodItem) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                AddMethodButton(
                    icon: "barcode.viewfinder",
                    label: "Barcode",
                    description: "Scan a packaged food barcode",
                    destination: BarcodeScannerView(onItemSaved: onItemSaved)
                )
                AddMethodButton(
                    icon: "camera",
                    label: "Photo",
                    description: "Take a photo of your food",
                    destination: PhotoScanView(onItemSaved: onItemSaved)
                )
                AddMethodButton(
                    icon: "mic",
                    label: "Voice",
                    description: "Say what you bought out loud",
                    destination: VoiceEntryView(onItemSaved: onItemSaved)
                )
                AddMethodButton(
                    icon: "doc.text.viewfinder",
                    label: "Receipt Photo",
                    description: "Scan a grocery receipt",
                    destination: PlaceholderView(title: "Receipt Photo")
                )
                AddMethodButton(
                    icon: "square.and.pencil",
                    label: "Manual Entry",
                    description: "Type the item details by hand",
                    destination: ManualEntryView(onSave: { item in
                        onItemSaved(item)
                    })
                )
                Spacer()
            }
            .padding()
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Reusable method button
struct AddMethodButton<Destination: View>: View {
    let icon: String
    let label: String
    let description: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 36)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

#Preview {
    AddItemMethodView(onItemSaved: { _ in })
}
