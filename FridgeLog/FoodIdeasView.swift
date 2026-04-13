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
    let requiredTypes:    [String]   // match against item.itemType
    let requiredKeywords: [String]   // match against item.name (case-insensitive)
    let minMatchCount:    Int        // how many qualifying items are needed
}

// MARK: - Generated Idea (result shown to user)

struct FoodIdea: Identifiable {
    let id            = UUID()
    let title:         String
    let description:   String
    let mealTime:      MealTime
    let matchedItems:  [FoodItem]   // up to 4 items from the inventory
    let hasExpiringSoon: Bool       // true if any matched item expires within 7 days
}

// MARK: - Template Library
// Rules: match by itemType OR by a keyword found anywhere in the item name.
// minMatchCount = how many qualifying items must exist before this idea is shown.

private let ideaTemplates: [IdeaTemplate] = [

    // ── Breakfast ─────────────────────────────────────────────
    IdeaTemplate(
        title: "Egg Dish",
        description: "Scrambled eggs, an omelet, or fried eggs — quick and filling.",
        mealTime: .breakfast,
        requiredTypes: ["Dairy & Eggs"],
        requiredKeywords: ["egg"],
        minMatchCount: 1
    ),
    IdeaTemplate(
        title: "Yogurt Bowl",
        description: "Yogurt topped with fruit or granola for a light, easy start.",
        mealTime: .breakfast,
        requiredTypes: [],
        requiredKeywords: ["yogurt"],
        minMatchCount: 1
    ),
    IdeaTemplate(
        title: "Oatmeal",
        description: "Warm oats with whatever toppings you have on hand.",
        mealTime: .breakfast,
        requiredTypes: [],
        requiredKeywords: ["oat", "oatmeal"],
        minMatchCount: 1
    ),

    // ── Lunch ─────────────────────────────────────────────────
    IdeaTemplate(
        title: "Fresh Salad",
        description: "Toss together fresh greens and vegetables — no cooking needed.",
        mealTime: .lunch,
        requiredTypes: ["Produce"],
        requiredKeywords: ["lettuce", "spinach", "kale", "arugula", "salad"],
        minMatchCount: 1
    ),
    IdeaTemplate(
        title: "Sandwich or Wrap",
        description: "A quick and easy handheld lunch.",
        mealTime: .lunch,
        requiredTypes: ["Bakery", "Deli & Prepared"],
        requiredKeywords: ["bread", "wrap", "tortilla", "baguette", "roll"],
        minMatchCount: 1
    ),

    // ── Dinner ────────────────────────────────────────────────
    IdeaTemplate(
        title: "Stir-Fry",
        description: "Cook meat and vegetables together in one hot pan.",
        mealTime: .dinner,
        requiredTypes: ["Meat & Seafood", "Produce"],
        requiredKeywords: ["chicken", "beef", "pork", "shrimp", "broccoli",
                           "pepper", "carrot", "onion", "tofu"],
        minMatchCount: 2
    ),
    IdeaTemplate(
        title: "Grain Bowl",
        description: "Start with rice, quinoa, or pasta and layer on what you have.",
        mealTime: .dinner,
        requiredTypes: ["Pantry"],
        requiredKeywords: ["rice", "quinoa", "pasta", "noodle", "lentil"],
        minMatchCount: 1
    ),
    IdeaTemplate(
        title: "Meat Dish",
        description: "Season and cook your meat simply for a satisfying dinner.",
        mealTime: .dinner,
        requiredTypes: ["Meat & Seafood"],
        requiredKeywords: ["chicken", "beef", "pork", "salmon", "fish",
                           "turkey", "lamb", "steak"],
        minMatchCount: 1
    ),
    IdeaTemplate(
        title: "Soup or Stew",
        description: "A warming one-pot meal — great for using up vegetables.",
        mealTime: .dinner,
        requiredTypes: [],
        requiredKeywords: ["carrot", "potato", "onion", "celery", "tomato",
                           "broth", "soup", "squash", "zucchini"],
        minMatchCount: 2
    ),
    IdeaTemplate(
        title: "Frozen Meal",
        description: "A quick, no-prep option straight from the freezer.",
        mealTime: .dinner,
        requiredTypes: ["Frozen"],
        requiredKeywords: ["frozen", "pizza", "burrito", "lasagna", "meal"],
        minMatchCount: 1
    ),

    // ── Snack ─────────────────────────────────────────────────
    IdeaTemplate(
        title: "Fruit Snack",
        description: "A simple and healthy snack — no prep needed.",
        mealTime: .snack,
        requiredTypes: [],
        requiredKeywords: ["apple", "banana", "orange", "berry", "berries",
                           "grape", "melon", "peach", "pear", "mango", "fruit"],
        minMatchCount: 1
    ),
    IdeaTemplate(
        title: "Smoothie",
        description: "Blend fruit with milk or yogurt for a quick nutrition boost.",
        mealTime: .snack,
        requiredTypes: [],
        requiredKeywords: ["banana", "berry", "berries", "milk", "yogurt",
                           "spinach", "mango", "peach"],
        minMatchCount: 2
    ),
    IdeaTemplate(
        title: "Cheese & Snack",
        description: "Cheese with crackers or bread — effortless and satisfying.",
        mealTime: .snack,
        requiredTypes: ["Dairy & Eggs", "Snacks"],
        requiredKeywords: ["cheese", "cracker", "chip"],
        minMatchCount: 1
    ),
]

// MARK: - Idea Generator

// Rules:
//   1. An item qualifies for a template if its itemType is in requiredTypes
//      OR its name contains any of the requiredKeywords (case-insensitive).
//   2. A template becomes an idea only if at least minMatchCount items qualify.
//   3. Ideas are sorted so those using expiring-soon items come first,
//      then by number of matched items (more is better).
//   4. At most 6 ideas are returned.

private func generateIdeas(from items: [FoodItem]) -> [FoodIdea] {
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

    private var ideas: [FoodIdea] { generateIdeas(from: items) }

    // Items expiring within 7 days, sorted soonest first
    private var expiringSoon: [FoodItem] {
        let cutoff = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return items
            .filter { $0.expirationDate <= cutoff }
            .sorted { $0.expirationDate < $1.expirationDate }
    }

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

                } else if ideas.isEmpty {
                    // ── Items exist but nothing matched ───────
                    FallbackIdeaCard(expiringSoon: expiringSoon, items: items)

                } else {
                    // ── Idea cards ────────────────────────────
                    ForEach(ideas) { idea in
                        FoodIdeaCard(idea: idea)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("What to Eat Today")
        .navigationBarTitleDisplayMode(.inline)
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

            Divider()

            // ── Matched ingredients from the user's inventory ─
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

// MARK: - Fallback Card (shown when no templates matched)

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
