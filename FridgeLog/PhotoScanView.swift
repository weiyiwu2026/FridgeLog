import SwiftUI
import Vision
import PhotosUI

// MARK: - Photo Scan Screen

struct PhotoScanView: View {

    let onItemSaved: (FoodItem) -> Void

    @Environment(FoodNameStore.self) private var foodNameStore

    // ── Photo selection state ─────────────────────────────────
    @State private var selectedPhoto:  PhotosPickerItem? = nil
    @State private var capturedImage:  UIImage?          = nil
    @State private var showCamera                        = false
    @State private var cameraAvailable                   = false

    // ── Scan pipeline state ───────────────────────────────────
    private enum ScanPhase: Equatable {
        case idle
        case analyzing
        case done(label: String)
    }
    @State private var scanPhase: ScanPhase = .idle

    // ── Navigation ────────────────────────────────────────────
    @State private var navigateToManual = false
    @State private var prefillItem:     FoodItem? = nil

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {

            // ── Image preview ─────────────────────────────────
            imagePreview

            // ── Status / result ───────────────────────────────
            switch scanPhase {
            case .idle:
                EmptyView()

            case .analyzing:
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Analyzing image…")
                        .foregroundColor(.secondary)
                }
                .padding()

            case .done(let label):
                resultView(label: label)
            }

            Spacer()

            // ── Buttons ───────────────────────────────────────
            actionButtons
        }
        .padding()
        .navigationTitle("Photo Scan")
        .navigationBarTitleDisplayMode(.inline)
        // ── Hidden NavigationLink to ManualEntryView ──────────
        .background(
            NavigationLink(
                destination: ManualEntryView(onSave: onItemSaved, prefill: prefillItem),
                isActive: $navigateToManual
            ) { EmptyView() }
        )
        // ── Camera sheet ──────────────────────────────────────
        .sheet(isPresented: $showCamera) {
            CameraPickerView(image: $capturedImage, isPresented: $showCamera)
                .ignoresSafeArea()
        }
        // ── React to new image ────────────────────────────────
        .onChange(of: capturedImage) {
            if capturedImage != nil {
                Task { await analyzeCurrentImage() }
            }
        }
        .onChange(of: selectedPhoto) {
            Task {
                if let photo = selectedPhoto,
                   let data  = try? await photo.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    capturedImage = image
                }
            }
        }
        .onAppear {
            cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
        .onChange(of: navigateToManual) {
            if !navigateToManual { resetScan() }
        }
    }

    // MARK: - Image Preview

    private var imagePreview: some View {
        Group {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("Take or choose a photo of your food item")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }.padding()
                    )
            }
        }
    }

    // MARK: - Result View

    private func resultView(label: String) -> some View {
        VStack(spacing: 12) {
            // Best guess chip
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.accentColor)
                if label.isEmpty {
                    Text("Could not identify item — please enter manually.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Looks like: \(label)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(10)

            // Use This
            Button(action: { useLabel(label) }) {
                Label("Use This", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }

            // Try another photo
            Button(action: resetScan) {
                Label("Try Another Photo", systemImage: "arrow.counterclockwise")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Camera — hidden on simulator / devices without camera
            if cameraAvailable {
                Button(action: { showCamera = true }) {
                    Label("Take a Photo", systemImage: "camera")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }

            // Photo library (no permission prompt needed with PhotosPicker in iOS 16+)
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Choose from Library", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.accentColor)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
            }

            // Manual fallback — always available
            Button(action: openManualEntry) {
                Label("Enter Manually Instead", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
            }
        }
    }

    // MARK: - Actions

    private func analyzeCurrentImage() async {
        guard let image = capturedImage else { return }
        scanPhase = .analyzing
        let label = await classifyImage(image)
        scanPhase = .done(label: label)
    }

    private func useLabel(_ label: String) {
        let type  = foodNameStore.defaultItemType(for: label)      ?? "Other"
        let place = foodNameStore.defaultStoragePlace(for: label)  ?? "Fridge"
        let days  = foodNameStore.defaultShelfLifeDays(for: label) ?? 7
        prefillItem = FoodItem(
            name:                   label,
            amountType:             .quantity,
            amountValue:            1,
            storagePlace:           place,
            itemType:               type,
            purchaseDate:           Date(),
            estimatedShelfLifeDays: days,
            expirationDate:         Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        )
        navigateToManual = true
    }

    private func openManualEntry() {
        prefillItem      = nil
        navigateToManual = true
    }

    private func resetScan() {
        capturedImage = nil
        selectedPhoto = nil
        scanPhase     = .idle
    }
}

// MARK: - Vision Image Classification
//
// Uses Apple's built-in VNClassifyImageRequest — no external model needed.
//
// Steps:
// 1. Run VNClassifyImageRequest on the image (on a background thread).
// 2. Sort results by confidence (highest first).
// 3. Skip generic/non-food terms (colors, textures, category names).
// 4. Take the best remaining result and clean up the label text.
// 5. Return empty string if nothing useful found.

private func classifyImage(_ image: UIImage) async -> String {
    await withCheckedContinuation { continuation in
        guard let cgImage = image.cgImage else {
            continuation.resume(returning: "")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNClassifyImageRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
                let label = bestFoodLabel(from: request.results ?? [])
                continuation.resume(returning: label)
            } catch {
                continuation.resume(returning: "")
            }
        }
    }
}

/// Returns the best food-like label from Vision classification observations.
private func bestFoodLabel(from observations: [VNClassificationObservation]) -> String {
    // Minimum confidence threshold
    let candidates = observations
        .filter { $0.confidence > 0.05 }
        .sorted { $0.confidence > $1.confidence }

    // Skip overly generic or non-food labels
    let skipList: Set<String> = [
        "food", "produce", "plant", "vegetable", "fruit", "ingredient",
        "meal", "dish", "cuisine", "snack", "natural food", "whole food",
        "superfood", "staple food", "leaf vegetable", "root vegetable",
        "black", "white", "red", "green", "blue", "yellow", "brown",
        "orange", "purple", "grey", "gray",
        "pattern", "texture", "still life", "macro photography",
        "photography", "image", "stock photography",
    ]

    let best = candidates.first { obs in
        let clean = obs.identifier
            .lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .components(separatedBy: ",")
            .first?
            .trimmingCharacters(in: .whitespaces) ?? obs.identifier.lowercased()
        return !skipList.contains(clean)
    }

    guard let winner = best ?? candidates.first else { return "" }
    return cleanLabel(winner.identifier)
}

/// Cleans up a Vision identifier into a readable item name.
/// Examples: "Granny_Smith" → "Granny Smith",  "broccoli, raw" → "Broccoli"
private func cleanLabel(_ identifier: String) -> String {
    let cleaned = identifier
        .replacingOccurrences(of: "_", with: " ")
        .components(separatedBy: ",")
        .first?
        .trimmingCharacters(in: .whitespaces) ?? identifier

    guard !cleaned.isEmpty else { return identifier }
    return cleaned.prefix(1).uppercased() + cleaned.dropFirst()
}

// MARK: - Camera Picker (UIKit wrapper)

private struct CameraPickerView: UIViewControllerRepresentable {

    @Binding var image:       UIImage?
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker          = UIImagePickerController()
        picker.sourceType   = .camera
        picker.delegate     = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {
        let parent: CameraPickerView
        init(_ parent: CameraPickerView) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    NavigationView {
        PhotoScanView(onItemSaved: { _ in })
    }
    .environment(FoodNameStore())
}
