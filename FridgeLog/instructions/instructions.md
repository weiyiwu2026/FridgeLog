# Fridge Management App Requirements Document

## 1. App Overview

This app helps people keep track of the food they have at home. It is for busy people who forget what they bought, want to waste less food, and want simple reminders before food goes bad. Users can add food by scanning a barcode, taking a photo, using their voice, or typing by hand.

---

## 2. Main Goals

1. Help users quickly add food to the app.
2. Help users see what food they have in the fridge, freezer, or pantry.
3. Help users track how much of each item is left.
4. Help users get reminders before food goes bad.
5. Help users use food before it is wasted.
6. Make the app easy and fast to use every day.

---

## 3. User Stories

- **US-001** As a user, I want to add food by scanning a barcode so that I do not need to type everything.
- **US-002** As a user, I want to add food by taking a photo so that I can log fruits, vegetables, and other loose items.
- **US-003** As a user, I want to add food by voice so that I can log items quickly when my hands are full.
- **US-004** As a user, I want to type food details by hand so that I can still use the app if scanning does not work.
- **US-005** As a user, I want to set how many of an item I bought so that the app knows my true inventory.
- **US-006** As a user, I want to split bulk food into portions so that I can track meals more accurately.
- **US-007** As a user, I want to choose where food is stored so that I can separate fridge, freezer, and pantry items.
- **US-008** As a user, I want to see all my saved food in one place so that I know what I already have.
- **US-009** As a user, I want to reduce the amount left after I cook or eat so that my inventory stays correct.
- **US-010** As a user, I want reminders when food may expire soon so that I can use it in time.
- **US-011** As a user, I want the app to suggest food to use first so that I waste less.
- **US-012** As a user, I want simple recipe ideas based on what I already have so that I know what to cook.
- **US-013** As a user, I want the app to save my data on my phone so that I do not lose my food list.
- **US-014** As a user, I want the app to be simple and fast so that I will keep using it.

---

## 4. Features

- **F-001 Add Food by Barcode**
  - What it does: Lets the user scan a barcode to add a packaged food item.
  - When it appears: From the main home screen when the user taps “Add Item.”
  - If something goes wrong: Show a message that says the item could not be found and offer manual entry.

- **F-002 Add Food by Photo**
  - What it does: Lets the user take a photo of food like apples, tomatoes, or potatoes and tries to guess the item.
  - When it appears: From the “Add Item” menu.
  - If something goes wrong: Show the guessed item if possible, or ask the user to type the name.

- **F-003 Add Food by Voice**
  - What it does: Lets the user speak something like “I bought five potatoes” and turns it into saved food details.
  - When it appears: From the “Add Item” menu.
  - If something goes wrong: Show the spoken text and let the user edit it before saving.

- **F-004 Add Food by Hand**
  - What it does: Lets the user type the item name, amount, storage place, and date bought.
  - When it appears: From the “Add Item” menu and as a backup when other methods fail.
  - If something goes wrong: Highlight missing fields and ask the user to complete them.

- **F-005 Set Quantity**
  - What it does: Lets the user set how many items they bought, such as 5 potatoes or 2 yogurts.
  - When it appears: After the app recognizes or creates an item.
  - If something goes wrong: Use a default amount of 1 and let the user change it later.

- **F-006 Split Into Portions**
  - What it does: Lets the user split a bulk item into smaller parts, such as one pack of ground beef into 5 meals.
  - When it appears: During item setup or when editing an item later.
  - If something goes wrong: Keep the item as one full package and let the user edit it later.

- **F-007 Choose Storage Place**
  - What it does: Lets the user save each item in fridge, freezer, or pantry.
  - When it appears: When adding or editing an item.
  - If something goes wrong: Use fridge as the default and let the user change it.

- **F-008 Inventory List**
  - What it does: Shows all saved food items in a clear list.
  - When it appears: On the main home screen.
  - If something goes wrong: Show an empty state that says no items have been added yet.

- **F-009 Update Quantity After Use**
  - What it does: Lets the user lower the amount left after eating or cooking.
  - When it appears: From each saved item in the inventory list.
  - If something goes wrong: Do not let the amount go below zero.

- **F-010 Expiration or Spoilage Alerts**
  - What it does: Warns the user when food may expire or go bad soon.
  - When it appears: In a special alerts area and through phone notifications if allowed.
  - If something goes wrong: Still show alerts inside the app even if phone notifications are off.

- **F-011 Use First Suggestions**
  - What it does: Shows which items should be eaten soon.
  - When it appears: On the home screen near the top.
  - If something goes wrong: Hide this section if there are no urgent items.

- **F-012 Recipe Suggestions**
  - What it does: Gives simple meal ideas based on saved food.
  - When it appears: On a recipe screen or button from the home screen.
  - If something goes wrong: Show a friendly message and allow the user to try again later.

- **F-013 Search and Filter**
  - What it does: Lets the user search for food and filter by fridge, freezer, pantry, or expiring soon.
  - When it appears: On the inventory screen.
  - If something goes wrong: Show the full list of items.

- **F-014 Edit and Delete Items**
  - What it does: Lets the user change item details or remove an item.
  - When it appears: When the user taps an item in the list.
  - If something goes wrong: Ask for confirmation before deleting.

---

## 5. Screens

- **S-001 Home Screen**
  - What is on the screen: List of saved items, “Add Item” button, “Use First” section, and alerts section.
  - How you get there: This is the first screen when the app opens.

- **S-002 Add Item Method Screen**
  - What is on the screen: Buttons for Barcode, Photo, Voice, and Manual Entry.
  - How you get there: Tap “Add Item” on S-001.

- **S-003 Barcode Scan Screen**
  - What is on the screen: Camera view for scanning a barcode and a cancel button.
  - How you get there: Tap Barcode on S-002.

- **S-004 Photo Scan Screen**
  - What is on the screen: Camera view for taking a food photo and a confirm button.
  - How you get there: Tap Photo on S-002.

- **S-005 Voice Entry Screen**
  - What is on the screen: Big microphone button, spoken text preview, and save button.
  - How you get there: Tap Voice on S-002.

- **S-006 Manual Entry Screen**
  - What is on the screen: Fields for item name, amount, storage place, date bought, and shelf life.
  - How you get there: Tap Manual Entry on S-002 or come here when another method fails.

- **S-007 Item Review Screen**
  - What is on the screen: Detected item name, amount, portions, storage place, date bought, and save button.
  - How you get there: After barcode scan, photo scan, voice entry, or manual entry.

- **S-008 Item Detail Screen**
  - What is on the screen: Full item details, quantity left, edit button, reduce button, and delete button.
  - How you get there: Tap any item from S-001.

- **S-009 Alerts Screen**
  - What is on the screen: List of items that may expire soon or should be used first.
  - How you get there: Tap alerts section on S-001.

- **S-010 Recipe Suggestions Screen**
  - What is on the screen: Simple recipe ideas based on current food items.
  - How you get there: Tap recipe button from S-001.

- **S-011 Settings Screen**
  - What is on the screen: Notification on or off, dark mode support, and simple app settings.
  - How you get there: Tap settings icon from S-001.

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
  - Support **F-005 Set Quantity**, **F-006 Split Into Portions**, and **F-007 Choose Storage Place**.

- **B-005**
  - Build **S-008 Item Detail Screen** so users can view, edit, reduce, and delete items.
  - Add **F-009 Update Quantity After Use** and **F-014 Edit and Delete Items**.

- **B-006**
  - Build **F-013 Search and Filter** on **S-001** so users can find food quickly.

- **B-007**
  - Build **S-003 Barcode Scan Screen** and connect it to **S-007 Item Review Screen**.
  - Add fallback to **S-006 Manual Entry Screen** if scanning fails.

- **B-008**
  - Build **S-005 Voice Entry Screen** and connect it to **S-007 Item Review Screen**.
  - Add fallback editing if spoken words are wrong.

- **B-009**
  - Build **S-004 Photo Scan Screen** and connect it to **S-007 Item Review Screen**.
  - Add fallback to manual entry if food guessing is unclear.

- **B-010**
  - Build the alert system for **F-010 Expiration or Spoilage Alerts** using **D-002, D-003, and D-004**.
  - Show alerts on **S-001** and **S-009 Alerts Screen**.

- **B-011**
  - Build **F-011 Use First Suggestions** on **S-001** using saved dates and shelf life.

- **B-012**
  - Build **S-010 Recipe Suggestions Screen** and use **D-010 Recipe Suggestion Data**.
  - Keep recipe suggestions simple in the first version.

- **B-013**
  - Build **S-011 Settings Screen** for notification choice and app preferences.
  - Save to **D-008 User Notification Choice**.

- **B-014**
  - Add dark mode support and test all main screens.
  - Check that the app still works when camera, microphone, or notifications are turned off.

- **B-015**
  - Test the full user flow from adding food to getting alerts.
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