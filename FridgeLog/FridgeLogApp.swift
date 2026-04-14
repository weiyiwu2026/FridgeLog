//
//  FridgeLogApp.swift
//  FridgeLog
//
//  Created by WW on 2026-04-09.
//

import SwiftUI

@main
struct FridgeLogApp: App {
    @State private var foodNameStore  = FoodNameStore()
    @State private var toBuyStore     = ToBuyStore()
    @State private var foodItemStore  = FoodItemStore()
    @State private var barcodeStore   = BarcodeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(foodNameStore)
                .environment(toBuyStore)
                .environment(foodItemStore)
                .environment(barcodeStore)
        }
    }
}
