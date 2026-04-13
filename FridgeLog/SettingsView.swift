import SwiftUI

// MARK: - Settings Tab

struct SettingsView: View {

    @Environment(FoodItemStore.self) private var foodItemStore
    @Environment(ToBuyStore.self)    private var toBuyStore

    // ── Stored preferences (persisted in UserDefaults via AppStorage) ──
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("appearancePreference") private var appearance = "system"

    // ── Confirmation dialog state ─────────────────────────────
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationView {
            List {

                // ── Preferences ───────────────────────────────
                Section("Preferences") {

                    Toggle(isOn: $notificationsEnabled) {
                        Label("Notifications", systemImage: "bell")
                    }

                    // Appearance: changes the whole app's color scheme live.
                    // Stored in UserDefaults so it persists between launches.
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Appearance", systemImage: "circle.lefthalf.filled")
                            .foregroundColor(.primary)
                        Picker("Appearance", selection: $appearance) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }

                // ── App Data ──────────────────────────────────
                Section {
                    LabeledContent("Food Items", value: "\(foodItemStore.items.count)")
                    LabeledContent("To Buy Items", value: "\(toBuyStore.items.count)")

                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                } header: {
                    Text("App Data")
                } footer: {
                    Text("\"Clear All Data\" permanently deletes your entire food list and shopping list.")
                }

                // ── Account ──────────────────────────────────
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Not signed in")
                                .font(.headline)
                            Text("Sign in and sync features coming later.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Account")
                }

                // ── About ─────────────────────────────────────
                Section("About") {
                    LabeledContent("App", value: "FridgeLog")
                    LabeledContent("Version", value: "1.0")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            // ── Confirmation dialog ───────────────────────────
            .confirmationDialog(
                "Clear All Data?",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Data", role: .destructive) {
                    foodItemStore.clearAll()
                    toBuyStore.clearAll()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all food items and your entire shopping list. This cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(FoodItemStore())
        .environment(ToBuyStore())
}
