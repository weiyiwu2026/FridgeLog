//
//  ContentView.swift
//  FridgeLog
//
//  Created by WW on 2026-04-09.
//

import SwiftUI

struct ContentView: View {

    // Read the stored appearance preference so the whole app reacts to it.
    @AppStorage("appearancePreference") private var appearance = "system"

    private var preferredColorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil   // nil = follow the system setting
        }
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .preferredColorScheme(preferredColorScheme)
    }
}

#Preview {
    ContentView()
        .environment(FoodNameStore())
        .environment(ToBuyStore())
        .environment(FoodItemStore())
}
