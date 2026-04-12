# Fridge Management App Requirements Document


## 1. App Overview

This app helps people keep track of the food they have at home. It is for busy people who forget what they bought, want to waste less food, and want simple reminders before food goes bad. Users can add food by scanning a barcode, taking a photo, using their voice, or typing by hand.

The app has 3 main tabs:
1. Home, which acts as a dashboard with 4 modules: Current Food List, Expiring Soon, To Buy List, and What to Eat Today / Food Ideas. The Home tab also keeps an Add Item button as a quick shortcut.
2. Insights, where users can see simple analytics based on their saved food data.
3. Settings, where users can manage app preferences.

---

## 2. Main Goals

1. Help users quickly add food to the app.
2. Help users see what food they have in the fridge, freezer, or pantry.
3. Help users see what food is expiring soon.
4. Help users keep a simple to buy list.
5. Help users get food ideas based on what they already have.
6. Help users understand simple patterns and insights from their food data.
7. Make the app easy and fast to use every day.

---


## 3. User Stories

- **US-001** As a user, I want to see all my saved food grouped by fridge, freezer, and pantry so that I know what I already have at home.
- **US-002** As a user, I want to add food by scanning a barcode so that I do not need to type everything.
- **US-003** As a user, I want to add food by taking a photo so that I can log fruits, vegetables, and other loose items.
- **US-004** As a user, I want to add food by voice so that I can log items quickly when my hands are full.
- **US-005** As a user, I want to type food details by hand so that I can still use the app if scanning does not work.
- **US-006** As a user, I want to set how many of an item I bought so that the app knows my true inventory.
- **US-007** As a user, I want to split bulk food into portions so that I can track meals more accurately.
- **US-008** As a user, I want to reduce the amount left after I cook or eat so that my inventory stays correct.
- **US-009** As a user, I want to see what food may expire soon and have reminders so that I can use it in time.
- **US-010** As a user, I want to keep a to buy list so that I remember what to restock.
- **US-011** As a user, I want food ideas or recipe based on what I already have so that I know what to eat today.
- **US-012** As a user, I want to see simple analytics and insights so that I can understand my food habits better.
- **US-013** As a user, I want to change app settings so that notifications and preferences work the way I want.
- **US-014** As a user, I want the app to save my data on my phone so that I do not lose my food list.
- **US-015** As a user, I want the app to be simple and fast so that I will keep using it.

---
## 4. Features

- **F-001 Main Tab Navigation**
  - What it does: Lets the user switch between Home, Insights, and Settings.
  - When it appears: At the bottom of the app.
  - If something goes wrong: Default to the Home tab.

- **F-002 Home Dashboard Modules**
  - What it does: Shows a 2 by 2 grid of tappable modules for Current Food List, Expiring Soon, To Buy List, and What to Eat Today / Food Ideas. It also includes an Add Item button as a quick shortcut.
  - When it appears: On the Home tab.
  - If something goes wrong: Show simple module cards with placeholder text and keep the Add Item button available.

- **F-003 Current Food List**
  - What it does: Shows all saved food items and lets the user manage inventory.
  - When it appears: After the user taps the Current Food List module.
  - If something goes wrong: Show an empty state that says no items have been added yet.

- **F-004 Expiring Soon**
  - What it does: Shows items that may expire or go bad soon.
  - When it appears: After the user taps the Expiring Soon module.
  - If something goes wrong: Show an empty state or friendly message.

- **F-005 To Buy List**
  - What it does: Shows items the user wants to buy or restock.
  - When it appears: After the user taps the To Buy List module.
  - If something goes wrong: Show an empty state that says the to buy list is empty.

- **F-006 What to Eat Today / Food Ideas**
  - What it does: Gives simple meal or snack ideas based on saved food.
  - When it appears: After the user taps the What to Eat Today / Food Ideas module.
  - If something goes wrong: Show a friendly message and allow the user to try again later.

- **F-007 Add Food by Barcode**
  - What it does: Lets the user scan a barcode to add a packaged food item.
  - When it appears: From the add item flow.
  - If something goes wrong: Show a message that says the item could not be found and offer manual entry.

- **F-008 Add Food by Photo**
  - What it does: Lets the user take a photo of food like apples, tomatoes, or potatoes and tries to guess the item.
  - When it appears: From the add item flow.
  - If something goes wrong: Show the guessed item if possible, or ask the user to type the name.

- **F-009 Add Food by Voice**
  - What it does: Lets the user speak something like “I bought five potatoes” and turns it into saved food details.
  - When it appears: From the add item flow.
  - If something goes wrong: Show the spoken text and let the user edit it before saving.

- **F-010 Add Food by Hand**
  - What it does: Lets the user type the item name, amount, storage place, and date bought.
  - When it appears: From the add item flow and as a backup when other methods fail.
  - If something goes wrong: Highlight missing fields and ask the user to complete them.

- **F-011 Set Quantity**
  - What it does: Lets the user set how many items they bought.
  - When it appears: During item setup and review.
  - If something goes wrong: Use a default amount of 1 and let the user change it later.

- **F-012 Split Into Portions**
  - What it does: Lets the user split a bulk item into smaller parts.
  - When it appears: During item setup or when editing an item later.
  - If something goes wrong: Keep the item as one full package and let the user edit it later.

- **F-013 Choose Storage Place**
  - What it does: Lets the user save each item in fridge, freezer, or pantry.
  - When it appears: When adding or editing an item.
  - If something goes wrong: Use fridge as the default and let the user change it.

- **F-014 Update Quantity After Use**
  - What it does: Lets the user lower the amount left after eating or cooking.
  - When it appears: From each saved item in the Current Food List.
  - If something goes wrong: Do not let the amount go below zero.

- **F-015 Edit and Delete Items**
  - What it does: Lets the user change item details or remove an item.
  - When it appears: When the user taps an item in the list.
  - If something goes wrong: Ask for confirmation before deleting.

- **F-016 Insights Dashboard**
  - What it does: Shows simple analytics like total items, items by storage place, and items expiring soon.
  - When it appears: On the Insights tab.
  - If something goes wrong: Show zero values and a friendly message.

- **F-017 Settings**
  - What it does: Lets the user manage preferences like notifications and dark mode support.
  - When it appears: On the Settings tab.
  - If something goes wrong: Use simple default settings.

---

## 5. Screens

- **S-001 Main Tab Screen**
  - What is on the screen: 3 tabs called Home, Insights, and Settings.
  - How you get there: This is the first screen when the app opens.

- **S-002 Home Tab**
  - What is on the screen:
    - A 2 by 2 grid of tappable modules:
      - Current Food List
      - Expiring Soon
      - To Buy List
      - What to Eat Today / Food Ideas
    - Add Item button as a quick shortcut
  - How you get there: Tap the Home tab on S-001.

- **S-003 Current Food List Screen**
  - What is on the screen:
    - The current saved food list
    - Add Item button
    - Existing add-item flow entry
  - How you get there: Tap the Current Food List module on S-002.

- **S-004 Add Item Method Screen**
  - What is on the screen: Buttons for Barcode, Photo, Voice, and Manual Entry.
  - How you get there: Tap Add Item on S-003, or tap the Add Item shortcut on S-002.

- **S-005 Barcode Scan Screen**
  - What is on the screen: Camera view for scanning a barcode and a cancel button.
  - How you get there: Tap Barcode on S-004.

- **S-006 Photo Scan Screen**
  - What is on the screen: Camera view for taking a food photo and a confirm button.
  - How you get there: Tap Photo on S-004.

- **S-007 Voice Entry Screen**
  - What is on the screen: Big microphone button, spoken text preview, and save button.
  - How you get there: Tap Voice on S-004.

- **S-008 Manual Entry Screen**
  - What is on the screen: Fields for item name, amount, storage place, date bought, and shelf life.
  - How you get there: Tap Manual Entry on S-004 or come here when another method fails.

- **S-009 Item Review Screen**
  - What is on the screen: Detected item name, amount, portions, storage place, date bought, and save button.
  - How you get there: After barcode scan, photo scan, voice entry, or manual entry.

- **S-010 Item Detail Screen**
  - What is on the screen: Full item details, quantity left, edit button, reduce button, and delete button.
  - How you get there: Tap any item from S-003.

- **S-011 Expiring Soon Screen**
  - What is on the screen: Items that may expire soon or should be used first.
  - How you get there: Tap the Expiring Soon module on S-002.

- **S-012 To Buy List Screen**
  - What is on the screen: Shopping items the user wants to buy or restock.
  - How you get there: Tap the To Buy List module on S-002.

- **S-013 What to Eat Today / Food Ideas Screen**
  - What is on the screen: Simple meal or snack ideas based on saved food.
  - How you get there: Tap the What to Eat Today / Food Ideas module on S-002.

- **S-014 Insights Tab**
  - What is on the screen: Simple summary cards or sections for total items, items by storage place, and expiring soon count.
  - How you get there: Tap the Insights tab on S-001.

- **S-015 Settings Tab**
  - What is on the screen: Notification on or off, dark mode support, and simple app settings.
  - How you get there: Tap the Settings tab on S-001.

---

## 6. Data

- **D-001 Saved Food Items**
  - List of food items with name, amount, and storage place.

- **D-002 Purchase Date**
  - The date when the user bought or added the item.

- **D-003 Estimated Shelf Life**
  - A simple number of days that the item may last.

- **D-004 Expiration Date**
  - If known, the exact date an item expires.

- **D-005 Portions**
  - If a bulk item is split, save how many parts it was divided into.

- **D-006 Quantity Left**
  - How much of the item is still left.

- **D-007 Item Type**
  - Whether the item is packaged food, produce, meat, frozen food, or pantry food.

- **D-008 User Notification Choice**
  - Whether the user wants reminder alerts.

- **D-009 Scan History**
  - A short record of recent added items so repeat items are faster to add.

- **D-010 Recipe Suggestion Data**
  - A list of current items used to suggest meals.

- **D-011 To Buy List**
  - List of items the user wants to buy or restock.

- **D-012 Expiring Soon Data**
  - Calculated list of items that may expire soon based on purchase date, shelf life, and expiration date.

- **D-013 Insights Data**
  - Simple summary numbers like total items, items by storage place, and expiring soon count.

- **D-014 Food Ideas Data**
  - Simple data used to suggest what the user could eat based on saved food.

---

## 7. Extra Details

1. The app should work mostly on the phone.
2. The app should save data on the device so the user can open it later.
3. The app will need camera permission for barcode scan and photo scan.
4. The app will need microphone permission for voice entry.
5. The app should ask for notification permission for food alerts.
6. The app can work without internet for basic saving and viewing.
7. Some smart features, like better food guessing or recipe ideas, may use the internet.
8. The app should support dark mode.
9. The app should use large buttons and simple text so it is easy to use.
10. The app should handle mistakes kindly and always give a backup option.
11. The app should be built for iPhone first.
12. The app should open fast and make adding food take as few steps as possible.

---
## 8. Build Steps

- **B-001**
  - Build **S-001 Home Screen** with a simple empty list and “Add Item” button.
  - Connect it to **D-001 Saved Food Items**.

- **B-002**
  - Build **S-002 Add Item Method Screen** so users can choose how to add food.
  - Link it from **S-001**.

- **B-003**
  - Build **S-006 Manual Entry Screen** first because it is the easiest backup method.
  - Save data to **D-001, D-002, D-003, D-004, D-006, and D-007**.

- **B-004**
  - Build **S-007 Item Review Screen** so users can check and fix item details before saving.
  - Support **F-011 Set Quantity**, **F-012 Split Into Portions**, and **F-013 Choose Storage Place**.

- **B-005**
  - Refactor the app into **S-001 Main Tab Screen** with 3 tabs: Home, Insights, and Settings.
  - Move the current main experience into **S-002 Home Tab**.
  - Keep existing add-item flows working.

- **B-006**
  - Change **S-002 Home Tab** into a 2 by 2 dashboard of tappable modules:
    - Current Food List
    - Expiring Soon
    - To Buy List
    - What to Eat Today / Food Ideas
  - Keep an **Add Item** button on the Home tab as a quick shortcut to the existing add-item flow.

- **B-007**
  - Reuse or clean up the existing inventory experience as **S-003 Current Food List Screen**.
  - Make sure tapping the Current Food List module opens this screen.

- **B-008**
  - Build **S-011 Expiring Soon Screen**.

- **B-009**
  - Build **S-012 To Buy List Screen**.

- **B-010**
  - Build **S-013 What to Eat Today / Food Ideas Screen**.

- **B-011**
  - Build **S-014 Insights Tab** and **F-016 Insights Dashboard** using simple summary counts.

- **B-012**
  - Build **S-015 Settings Tab** and **F-017 Settings**.

- **B-013**
  - Build search and filter on the Current Food List if still needed.

- **B-014**
  - Build **S-005 Barcode Scan Screen** and connect it to **S-009 Item Review Screen**.
  - Add fallback to **S-008 Manual Entry Screen** if scanning fails.

- **B-015**
  - Build **S-007 Voice Entry Screen** and connect it to **S-009 Item Review Screen**.
  - Add fallback editing if spoken words are wrong.

- **B-016**
  - Build **S-006 Photo Scan Screen** and connect it to **S-009 Item Review Screen**.
  - Add fallback to manual entry if food guessing is unclear.

- **B-017**
  - Add dark mode support and test all main screens.
  - Check that the app still works when camera, microphone, or notifications are turned off.

- **B-018**
  - Test the full user flow from adding food to getting suggestions and insights.
  - Make sure every smart feature has a simple backup option.

---

## 9. Notes for First Version

1. Do not try to make food recognition perfect.
2. Always let the user fix the app’s guess before saving.
3. Start with simple shelf-life estimates instead of trying to know exact expiration dates for every item.
4. Focus on speed and ease of use.
5. Make sure manual entry always works well because it is the safety net.

---

## 10. Nice-to-Have Later

1. Shared household accounts.
2. Shopping list based on low items.
3. Better recipe planning.
4. Better produce recognition.
5. Fridge photo comparison over time.
6. Apple Watch reminders.
7. Widgets for expiring soon items.