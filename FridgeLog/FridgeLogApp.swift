//
//  FridgeLogApp.swift
//  FridgeLog
//
//  Created by WW on 2026-04-09.
//

import SwiftUI

@main
struct FridgeLogApp: App {
    @State private var foodNameStore = FoodNameStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(foodNameStore)
        }
    }
}
