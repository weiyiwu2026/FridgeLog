import SwiftUI

struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text("This feature is coming soon.")
                .foregroundColor(.secondary)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        PlaceholderView(title: "Barcode Scanner")
    }
}
