import SwiftUI

// MARK: - Meal Time

enum MealTime: String {
    case breakfast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
    case snack     = "Snack"

    var icon: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch:     return "sun.max"
        case .dinner:    return "moon.stars"
        case .snack:     return "leaf"
        }
    }

    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch:     return .yellow
        case .dinner:    return .indigo
        case .snack:     return .green
        }
    }
}

// MARK: - Idea Template (internal matching data)

private struct IdeaTemplate {
    let title:            String
    let description:      String
    let mealTime:         MealTime
    let requiredTypes:    [String]
    let requiredKeywords: [String]
    let minMatchCount:    Int
    let labels:           [String]   // used for filtering (e.g. "Healthy", "Chinese", "Salad")
}

// MARK: - Generated Idea (shown to user)

struct FoodIdea: Identifiable {
    let id            = UUID()
    let title:         String
    let description:   String
    let mealTime:      MealTime
    let labels:        [String]
    let matchedItems:  [FoodItem]
    let hasExpiringSoon: Bool
}

// MARK: - Template Library

private let ideaTemplates: [IdeaTemplate] = [

    // ── Breakfast ─────────────────────────────────────────────
    IdeaTemplate(
        title: "Egg Dish",
        description: "Scrambled eggs, an omelet, or fried eggs — quick and filling.",
        mealTime: .breakfast,
        requiredTypes: ["Dairy & Eggs"],
        requiredKeywords: ["egg"],
        minMatchCount: 1,
        labels: ["Breakfast", "Healthy"]
    ),
    IdeaTemplate(
        title: "Yogurt Bowl",
        description: "Yogurt topped with fruit or granola for a light, easy start.",
        mealTime: .breakfast,
        requiredTypes: [],
        requiredKeywords: ["yogurt"],
        minMatchCount: 1,
        labels: ["Breakfast", "Snack", "Healthy"]
    ),
    IdeaTemplate(
        title: "Oatmeal",
        description: "Warm oats with whatever toppings you have on hand.",
        mealTime: .breakfast,
        requiredTypes: [],
        requiredKeywords: ["oat", "oatmeal"],
        minMatchCount: 1,
        labels: ["Breakfast", "Healthy"]
    ),

    // ── Lunch ─────────────────────────────────────────────────
    IdeaTemplate(
        title: "Fresh Salad",
        description: "Toss together fresh greens and vegetables — no cooking needed.",
        mealTime: .lunch,
        requiredTypes: ["Produce"],
        requiredKeywords: ["lettuce", "spinach", "kale", "arugula", "salad"],
        minMatchCount: 1,
        labels: ["Lunch", "Healthy", "Salad"]
    ),
    IdeaTemplate(
        title: "Sandwich or Wrap",
        description: "A quick and easy handheld lunch.",
        mealTime: .lunch,
        requiredTypes: ["Bakery", "Deli & Prepared"],
        requiredKeywords: ["bread", "wrap", "tortilla", "baguette", "roll"],
        minMatchCount: 1,
        labels: ["Lunch"]
    ),

    // ── Dinner ────────────────────────────────────────────────
    IdeaTemplate(
        title: "Stir-Fry",
        description: "Cook meat and vegetables together in one hot pan.",
        mealTime: .dinner,
        requiredTypes: ["Meat & Seafood", "Produce"],
        requiredKeywords: ["chicken", "beef", "pork", "shrimp", "broccoli",
                           "pepper", "carrot", "onion", "tofu"],
        minMatchCount: 2,
        labels: ["Dinner", "Healthy", "Chinese"]
    ),
    IdeaTemplate(
        title: "Fried Rice",
        description: "A classic one-pan Chinese dish — great for using up leftover rice and vegetables.",
        mealTime: .dinner,
        requiredTypes: [],
        requiredKeywords: ["rice", "egg", "onion", "carrot", "pea", "soy"],
        minMatchCount: 2,
        labels: ["Dinner", "Chinese"]
    ),
    IdeaTemplate(
        title: "Grain Bowl",
        description: "Start with rice, quinoa, or pasta and layer on what you have.",
        mealTime: .dinner,
        requiredTypes: ["Pantry"],
        requiredKeywords: ["rice", "quinoa", "pasta", "noodle", "lentil"],
        minMatchCount: 1,
        labels: ["Dinner", "Healthy"]
    ),
    IdeaTemplate(
        title: "Meat Dish",
        description: "Season and cook your meat simply for a satisfying dinner.",
        mealTime: .dinner,
        requiredTypes: ["Meat & Seafood"],
        requiredKeywords: ["chicken", "beef", "pork", "salmon", "fish",
                           "turkey", "lamb", "steak"],
        minMatchCount: 1,
        labels: ["Dinner"]
    ),
    IdeaTemplate(
        title: "Soup or Stew",
        description: "A warming one-pot meal — great for using up vegetables.",
        mealTime: .dinner,
        requiredTypes: [],
        requiredKeywords: ["carrot", "potato", "onion", "celery", "tomato",
                           "broth", "soup", "squash", "zucchini"],
        minMatchCount: 2,
        labels: ["Dinner", "Healthy"]
    ),
    IdeaTemplate(
        title: "Frozen Meal",
        description: "A quick, no-prep option straight from the freezer.",
        mealTime: .dinner,
        requiredTypes: ["Frozen"],
        requiredKeywords: ["frozen", "pizza", "burrito", "lasagna", "meal"],
        minMatchCount: 1,
        labels: ["Dinner"]
    ),

    // ── Snack ─────────────────────────────────────────────────
    IdeaTemplate(
        title: "Fruit Snack",
        description: "A simple and healthy snack — no prep needed.",
        mealTime: .snack,
        requiredTypes: [],
        requiredKeywords: ["apple", "banana", "orange", "berry", "berries",
                           "grape", "melon", "peach", "pear", "mango", "fruit"],
        minMatchCount: 1,
        labels: ["Snack", "Healthy"]
    ),
    IdeaTemplate(
        title: "Smoothie",
        description: "Blend fruit with milk or yogurt for a quick nutrition boost.",
        mealTime: .snack,
        requiredTypes: [],
        requiredKeywords: ["banana", "berry", "berries", "milk", "yogurt",
                           "spinach", "mango", "peach"],
        minMatchCount: 2,
        labels: ["Breakfast", "Snack", "Healthy"]
    ),
    IdeaTemplate(
        title: "Cheese & Snack",
        description: "Cheese with crackers or bread — effortless and satisfying.",
        mealTime: .snack,
        requiredTypes: ["Dairy & Eggs", "Snacks"],
        requiredKeywords: ["cheese", "cracker", "chip"],
        minMatchCount: 1,
        labels: ["Snack"]
    ),
]

// MARK: - Idea Generator

func generateIdeas(from items: [FoodItem]) -> [FoodIdea] {
    let cutoff = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    var ideas: [FoodIdea] = []

    for template in ideaTemplates {
        let matched = items.filter { item in
            let typeMatch    = template.requiredTypes.contains(item.itemType)
            let keywordMatch = template.requiredKeywords.contains {
                item.name.lowercased().contains($0.lowercased())
            }
            return typeMatch || keywordMatch
        }

        guard matched.count >= template.minMatchCount else { continue }

        let hasExpiring = matched.contains { $0.expirationDate <= cutoff }

        ideas.append(FoodIdea(
            title:          template.title,
            description:    template.description,
            mealTime:       template.mealTime,
            labels:         template.labels,
            matchedItems:   Array(matched.prefix(4)),
            hasExpiringSoon: hasExpiring
        ))
    }

    return ideas
        .sorted { a, b in
            if a.hasExpiringSoon != b.hasExpiringSoon { return a.hasExpiringSoon }
            return a.matchedItems.count > b.matchedItems.count
        }
        .prefix(6)
        .map { $0 }
}

// MARK: - Food Ideas Screen

struct FoodIdeasView: View {

    let items: [FoodItem]

    // All generated ideas (before label filter)
    private var allIdeas: [FoodIdea] { generateIdeas(from: items) }

    // Full label catalogue — always available in the filter menu
    private let availableLabels: [String] = [
        "American", "Italian", "Chinese", "Japanese", "Sushi", "Ramen",
        "Mexican", "Indian", "Thai", "Korean", "Vietnamese", "Mediterranean",
        "Greek", "Middle Eastern", "Turkish", "Spanish", "French", "Caribbean",
        "African", "Ethiopian", "Nigerian", "Latin American", "Peruvian",
        "Brazilian", "Burgers", "Pizza", "Sandwiches", "Subs", "Fast Food",
        "Chicken", "Wings", "Hot Dogs", "Wraps", "BBQ", "Barbecue", "Salads",
        "Healthy", "Vegetarian", "Vegan", "Gluten-Free", "Organic", "Noodles",
        "Poke", "Rice Bowls", "Bento", "Dessert", "Ice Cream", "Frozen Yogurt",
        "Bakery", "Donuts", "Coffee", "Tea", "Juice", "Smoothies", "Tacos",
        "Street Food", "Food Trucks", "Tapas", "Small Plates", "Breakfast",
        "Brunch", "Lunch", "Dinner", "Late Night", "Halal", "Kosher",
        "Filipino", "Malaysian", "Indonesian", "Nepali", "Afghan", "Hawaiian",
        "Cajun", "Creole", "Southern", "Soul Food", "Snack",
    ]

    // Ideas shown after applying the selected label filter
    private var filteredIdeas: [FoodIdea] {
        guard let label = selectedLabel else { return allIdeas }
        return allIdeas.filter { $0.labels.contains(label) }
    }

    // Items expiring within 7 days (used for fallback card)
    private var expiringSoon: [FoodItem] {
        let cutoff = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return items
            .filter { $0.expirationDate <= cutoff }
            .sorted { $0.expirationDate < $1.expirationDate }
    }

    @State private var selectedLabel: String?    = nil
    @State private var showAddRecipe:  Bool      = false
    @State private var showSearch:     Bool      = false

    private var isFiltering: Bool { selectedLabel != nil }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                if items.isEmpty {
                    // ── No items at all ───────────────────────
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No food in your inventory yet.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Add items to get meal ideas.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)

                } else if filteredIdeas.isEmpty && !isFiltering {
                    // ── Items exist but nothing matched any template ──
                    FallbackIdeaCard(expiringSoon: expiringSoon, items: items)

                } else if filteredIdeas.isEmpty && isFiltering {
                    // ── Filter active but no results ──────────
                    VStack(spacing: 16) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No ideas for \"\(selectedLabel ?? "")\".")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Try a different label or clear the filter.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)

                } else {
                    // ── Active filter chip ────────────────────
                    if isFiltering {
                        HStack(spacing: 8) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .foregroundColor(.accentColor)
                            Text("Label: \(selectedLabel ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                            Spacer()
                            Button("Clear") { selectedLabel = nil }
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 4)
                    }

                    // ── Idea cards ────────────────────────────
                    ForEach(filteredIdeas) { idea in
                        FoodIdeaCard(idea: idea)
                    }
                }
            }
            .padding()
            // Extra bottom padding so content is not hidden behind the action bar
            .padding(.bottom, 80)
        }
        .navigationTitle("What to Eat Today")
        .navigationBarTitleDisplayMode(.inline)
        // ── Filter menu ───────────────────────────────────────
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // "All" option
                    Button { selectedLabel = nil } label: {
                        selectedLabel == nil
                            ? Label("All", systemImage: "checkmark")
                            : Label("All", systemImage: "")
                    }

                    // One button per available label
                    ForEach(availableLabels, id: \.self) { label in
                        Button { selectedLabel = label } label: {
                            selectedLabel == label
                                ? Label(label, systemImage: "checkmark")
                                : Label(label, systemImage: "")
                        }
                    }
                } label: {
                    Image(systemName: isFiltering
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
        }
        // ── Bottom action bar ─────────────────────────────────
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                // Add My Recipe — placeholder for now
                Button(action: { showAddRecipe = true }) {
                    Label("Add My Recipe", systemImage: "plus.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                }

                // Search Online — placeholder for now
                Button(action: { showSearch = true }) {
                    Label("Search Online", systemImage: "magnifyingglass")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
        // ── Placeholder sheets ────────────────────────────────
        .sheet(isPresented: $showAddRecipe) {
            PlaceholderSheetView(
                icon: "plus.circle",
                title: "Add My Recipe",
                message: "You will be able to add your own recipes here.\nThis feature is coming soon."
            )
        }
        .sheet(isPresented: $showSearch) {
            PlaceholderSheetView(
                icon: "magnifyingglass",
                title: "Search Online",
                message: "Online recipe search will be available here.\nThis feature is coming soon."
            )
        }
    }
}

// MARK: - Placeholder Sheet

struct PlaceholderSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let icon:    String
    let title:   String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button("Close") { dismiss() }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

// MARK: - Idea Card

struct FoodIdeaCard: View {
    let idea: FoodIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Meal time badge + "Use Soon" flag ─────────────
            HStack {
                Label(idea.mealTime.rawValue, systemImage: idea.mealTime.icon)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(idea.mealTime.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(idea.mealTime.color.opacity(0.15))
                    .cornerRadius(8)

                Spacer()

                if idea.hasExpiringSoon {
                    Label("Use Soon", systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }

            // ── Title and description ─────────────────────────
            Text(idea.title)
                .font(.headline)

            Text(idea.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // ── Labels row ────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(idea.labels, id: \.self) { label in
                        Text(label)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(6)
                    }
                }
            }

            Divider()

            // ── Matched ingredients ───────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                Text("From your kitchen:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ForEach(idea.matchedItems) { item in
                    IngredientRow(item: item)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Ingredient Row

struct IngredientRow: View {
    let item: FoodItem

    private var daysLeft: Int {
        let today  = Calendar.current.startOfDay(for: Date())
        let expiry = Calendar.current.startOfDay(for: item.expirationDate)
        return max(0, Calendar.current.dateComponents([.day], from: today, to: expiry).day ?? 0)
    }

    private var isExpiringSoon: Bool { daysLeft <= 7 }

    private var expiryNote: String {
        switch daysLeft {
        case 0:  return "(expires today)"
        case 1:  return "(1 day left)"
        default: return "(\(daysLeft) days left)"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
                .foregroundColor(.secondary)
            Text(item.name)
                .font(.subheadline)
            if isExpiringSoon {
                Text(expiryNote)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - Fallback Card

struct FallbackIdeaCard: View {
    let expiringSoon: [FoodItem]
    let items: [FoodItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("General Idea", systemImage: "lightbulb")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12))
                    .cornerRadius(8)
                Spacer()
            }

            Text("Use What You Have")
                .font(.headline)

            if !expiringSoon.isEmpty {
                Text("These items are expiring soon — try building a meal around them:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(expiringSoon.prefix(4)) { item in
                        IngredientRow(item: item)
                    }
                }
            } else {
                Text("You have \(items.count) item\(items.count == 1 ? "" : "s") saved. Try combining what you have for a simple meal.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        FoodIdeasView(items: sampleItems)
    }
}
