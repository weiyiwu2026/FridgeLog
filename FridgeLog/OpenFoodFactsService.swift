import Foundation

// A minimal product result from Open Food Facts.
struct OFFProduct {
    let name: String
}

// Looks up a barcode on the Open Food Facts public API.
// Returns nil if the product is not found, data is incomplete, or the request fails.
enum OpenFoodFactsService {

    static func lookup(barcode: String) async -> OFFProduct? {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json?fields=product_name"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response  = try JSONDecoder().decode(OFFResponse.self, from: data)

            guard response.status == 1,
                  let raw = response.product?.productName,
                  !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { return nil }

            return OFFProduct(name: raw.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            return nil
        }
    }
}

// MARK: - Private decodables

private struct OFFResponse: Decodable {
    let status: Int
    let product: OFFProductRaw?
}

private struct OFFProductRaw: Decodable {
    let productName: String?
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
    }
}
