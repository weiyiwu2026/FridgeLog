import SwiftUI
import Speech
import AVFoundation

// MARK: - Voice Entry Screen

struct VoiceEntryView: View {

    let onItemSaved: (FoodItem) -> Void

    @Environment(FoodNameStore.self) private var foodNameStore

    @State private var speech           = SpeechManager()
    @State private var permStatus       = PermStatus.unknown
    @State private var navigateToManual = false
    @State private var prefillItem:     FoodItem? = nil
    @State private var pulseScale:      CGFloat   = 1.0

    private enum PermStatus { case unknown, granted, denied, unavailable }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            switch permStatus {
            case .unknown:
                ProgressView("Checking permissions…")

            case .denied:
                permissionDeniedView

            case .unavailable:
                unavailableView

            case .granted:
                mainContent
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Voice Entry")
        .navigationBarTitleDisplayMode(.inline)
        // ── Hidden NavigationLink to ManualEntryView ──────────
        .background(
            NavigationLink(
                destination: ManualEntryView(onSave: onItemSaved, prefill: prefillItem),
                isActive: $navigateToManual
            ) { EmptyView() }
        )
        .onAppear { requestPermissions() }
        .onDisappear { speech.stop() }
        // Reset state when returning from ManualEntryView
        .onChange(of: navigateToManual) {
            if !navigateToManual {
                speech.transcript = ""
                speech.stop()
            }
        }
    }

    // MARK: - Main content (permissions granted)

    private var mainContent: some View {
        VStack(spacing: 28) {

            // ── Transcript box ────────────────────────────────
            VStack(alignment: .leading, spacing: 8) {
                if speech.transcript.isEmpty {
                    Text(speech.isListening
                         ? "Listening…"
                         : "Tap the mic and say what you bought.\n\nExample: \"five apples\" or \"I bought two yogurts\"")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(speech.transcript)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            // ── Mic button ────────────────────────────────────
            ZStack {
                // Pulsing ring — visible only when listening
                if speech.isListening {
                    Circle()
                        .stroke(Color.red.opacity(0.35), lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseScale)
                        .opacity(2.0 - pulseScale)   // fades as it expands
                }

                Button(action: toggleListening) {
                    ZStack {
                        Circle()
                            .fill(speech.isListening ? Color.red : Color.accentColor)
                            .frame(width: 80, height: 80)
                        Image(systemName: speech.isListening ? "stop.fill" : "mic.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
            }
            .onChange(of: speech.isListening) {
                if speech.isListening {
                    // Start repeating pulse animation
                    withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                        pulseScale = 1.6
                    }
                } else {
                    withAnimation(.default) { pulseScale = 1.0 }
                }
            }

            Text(speech.isListening ? "Tap to stop" : "Tap to speak")
                .font(.caption)
                .foregroundColor(.secondary)

            // ── "Use This" — appears once transcript is ready ─
            if !speech.transcript.isEmpty && !speech.isListening {
                Button(action: useTranscript) {
                    Label("Use This", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .transition(.opacity)
            }

            // ── Manual entry fallback ─────────────────────────
            Button(action: openManualEntry) {
                Label("Enter Manually Instead", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
            }

            // ── Error message ─────────────────────────────────
            if let err = speech.errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Fallback views

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "mic.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Microphone Access Required")
                .font(.title3).fontWeight(.semibold)
            Text("Please allow microphone and speech recognition access in Settings → Privacy.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(Color.accentColor).foregroundColor(.white).cornerRadius(12)
            Spacer()
        }
    }

    private var unavailableView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "mic.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Voice Not Available")
                .font(.title3).fontWeight(.semibold)
            Text("Voice entry requires a real iPhone.\nUse the button below to enter details manually.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Button(action: openManualEntry) {
                Label("Enter Manually Instead", systemImage: "square.and.pencil")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
            }
            .padding(.top, 8)
            Spacer()
        }
    }

    // MARK: - Actions

    private func toggleListening() {
        if speech.isListening {
            speech.stop()
        } else {
            speech.transcript = ""
            do {
                try speech.start()
            } catch {
                speech.errorMessage = "Could not start recording: \(error.localizedDescription)"
            }
        }
    }

    private func useTranscript() {
        let (name, qty) = parseVoiceInput(speech.transcript)
        let type  = foodNameStore.defaultItemType(for: name)      ?? "Other"
        let place = foodNameStore.defaultStoragePlace(for: name)  ?? "Fridge"
        let days  = foodNameStore.defaultShelfLifeDays(for: name) ?? 7
        prefillItem = FoodItem(
            name:                   name,
            amountType:             .quantity,
            amountValue:            qty,
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

    // MARK: - Permissions

    private func requestPermissions() {
        #if targetEnvironment(simulator)
        permStatus = .unavailable
        return
        #endif

        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized else {
                    permStatus = .denied
                    return
                }
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        permStatus = granted ? .granted : .denied
                    }
                }
            }
        }
    }
}

// MARK: - Voice Input Parser
//
// Rules applied in order:
//
// 1. Strip leading filler phrases:
//    "I bought", "I got", "I have", "I need", "add", "we bought", etc.
//    Checked longest-first so "I just bought" beats "I bought".
//
// 2. Detect number word at the start:
//    one → 1, two → 2, … twelve → 12
//    Also: "a" / "an" → 1, "a couple" → 2, "a dozen" → 12
//    Multi-word phrases ("a couple of", "half a dozen") are checked first.
//
// 3. Detect leading digit(s):
//    "3 apples" → quantity 3, name "apples"
//
// 4. Default quantity = 1 if nothing found.
//
// 5. Capitalize the first letter of the item name.
//
// Limitation: only the first item is parsed.
// "three apples and one milk" → quantity 3, name "apples and one milk"
// The user can fix this in the Manual Entry screen.

private func parseVoiceInput(_ text: String) -> (name: String, quantity: Int) {
    var input = text.lowercased().trimmingCharacters(in: .whitespaces)

    // Step 1 — strip fillers (longest first)
    let fillers = [
        "i just picked up", "i just bought", "i just got",
        "i picked up", "i bought", "i got", "i have", "i need",
        "we just bought", "we bought", "we got", "we have", "we need",
        "please add", "add", "bought", "got",
    ]
    for filler in fillers {
        if input.hasPrefix(filler + " ") || input == filler {
            input = String(input.dropFirst(filler.count))
                .trimmingCharacters(in: .whitespaces)
            break
        }
    }

    // Step 2 — number words (multi-word phrases first)
    let numberWords: [(String, Int)] = [
        ("half a dozen", 6), ("a dozen", 12),
        ("a couple of", 2),  ("a couple", 2),
        ("one", 1),   ("two", 2),   ("three", 3), ("four", 4),  ("five", 5),
        ("six", 6),   ("seven", 7), ("eight", 8), ("nine", 9),  ("ten", 10),
        ("eleven", 11), ("twelve", 12),
        ("a", 1), ("an", 1),
    ]

    var quantity     = 1
    var numberFound  = false

    for (phrase, value) in numberWords {
        if input.hasPrefix(phrase + " ") {
            quantity    = value
            numberFound = true
            input = String(input.dropFirst(phrase.count))
                .trimmingCharacters(in: .whitespaces)
            break
        }
    }

    // Step 3 — leading digit (e.g. "3 apples", "12 eggs")
    if !numberFound {
        let parts = input.components(separatedBy: " ")
        if let first = parts.first, let num = Int(first), num > 0 {
            quantity = num
            input    = parts.dropFirst().joined(separator: " ")
        }
    }

    // Step 4 — capitalize item name
    let trimmed = input.trimmingCharacters(in: .whitespaces)
    let name = trimmed.isEmpty
        ? ""
        : trimmed.prefix(1).uppercased() + trimmed.dropFirst()

    return (name: name, quantity: max(1, quantity))
}

// MARK: - Speech Manager

@Observable
final class SpeechManager {

    var transcript   = ""
    var isListening  = false
    var errorMessage: String? = nil

    private let recognizer   = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine  = AVAudioEngine()
    private var request:     SFSpeechAudioBufferRecognitionRequest?
    private var task:        SFSpeechRecognitionTask?
    private var tapInstalled = false

    // MARK: Start

    func start() throws {
        task?.cancel(); task = nil
        cleanupAudio()
        errorMessage = nil

        guard let recognizer, recognizer.isAvailable else {
            throw VoiceEntryError.recognizerUnavailable
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        request = req

        let inputNode = audioEngine.inputNode
        let format    = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buf, _ in
            self?.request?.append(buf)
        }
        tapInstalled = true

        audioEngine.prepare()
        try audioEngine.start()
        isListening = true
        transcript  = ""

        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self else { return }
            if let result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            if error != nil || result?.isFinal == true {
                DispatchQueue.main.async { self.stop() }
            }
        }
    }

    // MARK: Stop

    func stop() {
        guard isListening else { return }
        request?.endAudio()
        request = nil
        task?.finish()
        task = nil
        cleanupAudio()
        isListening = false
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation
        )
    }

    // MARK: Private cleanup

    private func cleanupAudio() {
        if tapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        if audioEngine.isRunning { audioEngine.stop() }
    }
}

private enum VoiceEntryError: LocalizedError {
    case recognizerUnavailable
    var errorDescription: String? {
        "Speech recognition is not available on this device."
    }
}
