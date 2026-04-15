import SwiftUI
import UserNotifications

// MARK: - Settings Tab

struct SettingsView: View {

    @Environment(FoodItemStore.self) private var foodItemStore
    @Environment(ToBuyStore.self)    private var toBuyStore

    // ── Stored preferences ────────────────────────────────────
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("appearancePreference") private var appearance = "system"

    // ── Real system notification permission status ────────────
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    // ── Confirmation dialog state ─────────────────────────────
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationView {
            List {

                // ── Preferences ───────────────────────────────
                Section("Preferences") {
                    notificationsRow
                    appearancePicker
                }

                // ── App Data ──────────────────────────────────
                Section {
                    LabeledContent("Food Items",    value: "\(foodItemStore.items.count)")
                    LabeledContent("To Buy Items",  value: "\(toBuyStore.items.count)")

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

                // ── Account ───────────────────────────────────
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
                    LabeledContent("App",     value: "FridgeLog")
                    LabeledContent("Version", value: "1.0")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .onAppear  { refreshNotificationStatus() }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification)
            ) { _ in
                // Re-check when the user comes back from the Settings app
                refreshNotificationStatus()
            }
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

    // MARK: - Notifications Row
    //
    // Three states based on the real system permission:
    //
    // • .notDetermined  — toggle shown; tapping ON requests system permission
    // • .authorized     — toggle works normally (stores app preference)
    // • .denied         — toggle disabled; prompt to open system Settings shown

    @ViewBuilder
    private var notificationsRow: some View {
        switch notificationStatus {

        case .authorized, .provisional, .ephemeral:
            // System permission granted — toggle controls the app preference
            Toggle(isOn: $notificationsEnabled) {
                Label("Notifications", systemImage: "bell")
            }

        case .denied:
            // System permission denied — explain and offer Settings link
            VStack(alignment: .leading, spacing: 6) {
                Label("Notifications", systemImage: "bell.slash")
                    .foregroundColor(.primary)
                Text("Notifications are blocked. Go to Settings → FridgeLog to allow them.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
            }
            .padding(.vertical, 4)

        case .notDetermined:
            // Not yet asked — toggle shown; turning ON triggers system prompt
            Toggle(isOn: Binding(
                get: { notificationsEnabled },
                set: { newValue in
                    if newValue {
                        requestNotificationPermission()
                    } else {
                        notificationsEnabled = false
                    }
                }
            )) {
                Label("Notifications", systemImage: "bell")
            }

        @unknown default:
            Toggle(isOn: $notificationsEnabled) {
                Label("Notifications", systemImage: "bell")
            }
        }
    }

    // MARK: - Appearance Picker

    private var appearancePicker: some View {
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

    // MARK: - Notification Permission Helpers

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = settings.authorizationStatus
                // Keep the app toggle in sync with reality
                if settings.authorizationStatus == .denied {
                    notificationsEnabled = false
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            DispatchQueue.main.async {
                notificationStatus    = granted ? .authorized : .denied
                notificationsEnabled  = granted
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(FoodItemStore())
        .environment(ToBuyStore())
}
