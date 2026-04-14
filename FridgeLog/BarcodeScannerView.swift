import SwiftUI
import AVFoundation

// MARK: - Barcode Scanner Screen

struct BarcodeScannerView: View {

    let onItemSaved: (FoodItem) -> Void

    @Environment(FoodNameStore.self) private var foodNameStore
    @Environment(BarcodeStore.self)  private var barcodeStore

    // Tracks whether a barcode has already been captured this session
    @State private var scannedCode:      String?  = nil
    // Controls the NavigationLink to ManualEntryView
    @State private var navigateToManual: Bool     = false
    // Pre-filled item to pass to ManualEntryView (nil = no prefill)
    @State private var prefillItem:      FoodItem? = nil
    // Forces CameraPreview to rebuild (e.g. after returning from Manual Entry)
    @State private var cameraSessionID   = UUID()

    @State private var cameraPermission: CameraPermission = .unknown

    private enum CameraPermission {
        case unknown, granted, denied, unavailable
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // ── Camera layer or fallback ──────────────────────
            switch cameraPermission {
            case .granted:
                CameraPreview(onBarcodeFound: handleBarcode)
                    .id(cameraSessionID)
                    .ignoresSafeArea()

            case .denied:
                permissionDeniedView

            case .unavailable:
                simulatorFallbackView

            case .unknown:
                Color.black.ignoresSafeArea()
            }

            // ── Overlay (scanning guide + bottom button) ──────
            VStack {
                Spacer()

                // Viewfinder guide
                if cameraPermission == .granted {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.85), lineWidth: 2)
                            .frame(width: 270, height: 160)
                        Text("Point at a barcode")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                            .offset(y: 100)
                    }
                }

                Spacer()

                // ── Enter manually fallback ───────────────────
                Button(action: openManualEntry) {
                    Label("Enter Manually Instead", systemImage: "square.and.pencil")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(14)
                }
                .padding()
            }
        }
        .navigationTitle("Barcode Scanner")
        .navigationBarTitleDisplayMode(.inline)
        // ── Hidden NavigationLink to ManualEntryView ──────────
        .background(
            NavigationLink(
                destination: ManualEntryView(onSave: saveAndRecord, prefill: prefillItem),
                isActive: $navigateToManual
            ) { EmptyView() }
        )
        .onAppear { checkCameraPermission() }
        // When user returns from ManualEntryView, reset so they can scan again
        .onChange(of: navigateToManual) {
            if !navigateToManual {
                scannedCode    = nil
                cameraSessionID = UUID()   // rebuilds CameraPreview → restarts session
            }
        }
    }

    // MARK: - Fallback views

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "camera.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Camera Access Required")
                .font(.title3).fontWeight(.semibold)
            Text("Please allow camera access in\nSettings → Privacy → Camera.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            Spacer()
        }
        .padding()
    }

    private var simulatorFallbackView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "camera.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Camera Not Available")
                .font(.title3).fontWeight(.semibold)
            Text("Barcode scanning requires a real iPhone.\nUse the button below to enter details manually.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Spacer()
        }
    }

    // MARK: - Camera Permission

    private func checkCameraPermission() {
        // Simulator has no camera hardware
        #if targetEnvironment(simulator)
        cameraPermission = .unavailable
        return
        #endif

        guard AVCaptureDevice.default(for: .video) != nil else {
            cameraPermission = .unavailable
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermission = .granted
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermission = granted ? .granted : .denied
                }
            }
        case .denied, .restricted:
            cameraPermission = .denied
        @unknown default:
            cameraPermission = .denied
        }
    }

    // MARK: - Barcode Handling

    private func handleBarcode(_ code: String) {
        //print("Scanned barcode: '\(code)'")   // ← add this line temporarily
        guard scannedCode == nil else { return }   // ignore duplicate detections
        scannedCode  = code
        prefillItem  = makeDraftItem(from: code)
        navigateToManual = true
    }

    private func openManualEntry() {
        prefillItem      = nil
        navigateToManual = true
    }

    // Creates the best draft FoodItem we can from a barcode value.
    // Lookup order: BarcodeStore (user-saved) → hardcoded dictionary → blank draft.
    private func makeDraftItem(from barcode: String) -> FoodItem {
        // 1. User's own saved mappings take priority
        if let saved = barcodeStore.record(for: barcode) {
            return FoodItem(
                name:                   saved.name,
                amountType:             .quantity,
                amountValue:            1,
                storagePlace:           saved.storagePlace,
                itemType:               saved.itemType,
                purchaseDate:           Date(),
                estimatedShelfLifeDays: saved.shelfLifeDays,
                expirationDate:         Calendar.current.date(byAdding: .day, value: saved.shelfLifeDays, to: Date()) ?? Date()
            )
        }

        // 2. Hardcoded dictionary
        let resolvedName = knownBarcodes[barcode] ?? ""
        let type  = foodNameStore.defaultItemType(for: resolvedName)     ?? "Other"
        let place = foodNameStore.defaultStoragePlace(for: resolvedName) ?? "Fridge"
        let days  = foodNameStore.defaultShelfLifeDays(for: resolvedName) ?? 7
        return FoodItem(
            name:                   resolvedName,
            amountType:             .quantity,
            amountValue:            1,
            storagePlace:           place,
            itemType:               type,
            purchaseDate:           Date(),
            estimatedShelfLifeDays: days,
            expirationDate:         Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        )
    }

    // Called when the user saves from ManualEntryView.
    // If we got here from a real barcode scan and the user gave the item a name,
    // save/update the barcode → item mapping for future scans.
    private func saveAndRecord(_ item: FoodItem) {
        if let code = scannedCode,
           !item.name.trimmingCharacters(in: .whitespaces).isEmpty {
            barcodeStore.save(BarcodeRecord(
                barcode:      code,
                name:         item.name,
                itemType:     item.itemType,
                storagePlace: item.storagePlace,
                shelfLifeDays: item.estimatedShelfLifeDays
            ))
        }
        onItemSaved(item)
    }
}

// MARK: - Small local barcode lookup (UPC / EAN)
// Add more entries here as needed. This is intentionally small for V1.

private let knownBarcodes: [String: String] = [
    "049000028911": "Coca-Cola",
    "036000291452": "Pepsi",
    "021130126026": "Tropicana Orange Juice",
    "070038632161": "Lay's Classic Chips",
    "038000845024": "Kellogg's Corn Flakes",
    "016000275287": "Cheerios",
    "041196899738": "Sargento Mozzarella",
    "041303004319": "Del Monte Diced Tomatoes",
    "070784006164": "Quaker Oats",
    "012000001987": "Gatorade",
    "044000032005": "Oreo Cookies",
    "028400089036": "Doritos Nacho Cheese",
    "049000001481": "Coca-Cola Zero Sugar",
    "06792800": "Diet Coke",
    "0099482411312": "Fine Sea Salt",
    "0062600959034":  "Aveeno Stress Relief Moisturizing Lotion",
    "8033993047129": "Truffle & Cheese Pasta Sauce"
]

// MARK: - Camera Preview (UIKit wrapper)

private struct CameraPreview: UIViewRepresentable {

    var onBarcodeFound: (String) -> Void

    // MARK: Coordinator

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onBarcodeFound: (String) -> Void
        var session:      AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?

        init(onBarcodeFound: @escaping (String) -> Void) {
            self.onBarcodeFound = onBarcodeFound
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard let obj   = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = obj.stringValue else { return }
            session?.stopRunning()
            DispatchQueue.main.async { self.onBarcodeFound(value) }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeFound: onBarcodeFound)
    }

    // MARK: UIViewRepresentable

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input  = try? AVCaptureDeviceInput(device: device)
        else { return view }

        let session = AVCaptureSession()
        guard session.canAddInput(input) else { return view }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return view }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        output.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .qr]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        context.coordinator.session      = session
        context.coordinator.previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.session?.stopRunning()
    }
}
