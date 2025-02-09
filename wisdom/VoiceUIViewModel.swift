
import Foundation
import AVFoundation
import Speech

class VoiceUIViewModel: ObservableObject {
    @Published var shouldSpeak: Bool = false
    var textToSpeak: String = ""
    private var player: AVPlayer?
    private let apiKey = "xx"
    private let ttsEndpoint = "https://api.openai.com/v1/audio/speech"
    
    func speakText() {
        Task {
            do {
                // Prepare the request
                var request = URLRequest(url: URL(string: ttsEndpoint)!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Prepare the request body
                let requestBody: [String: Any] = [
                    "model": "tts-1",
                    "input": textToSpeak,
                    "voice": "alloy",  // Options: alloy, echo, fable, onyx, nova, shimmer
                    "speed": 1.0
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
                // Make the API call
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                
                // Create a temporary URL to store the audio data
                let temporaryDirectory = FileManager.default.temporaryDirectory
                let temporaryFileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp3")
                
                // Write the audio data to the temporary file
                try data.write(to: temporaryFileURL)
                
                // Play the audio on the main thread
                await MainActor.run {
                    let playerItem = AVPlayerItem(url: temporaryFileURL)
                    self.player = AVPlayer(playerItem: playerItem)
                    self.player?.play()
                    
                    // Clean up the temporary file after playback
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                         object: playerItem,
                                                         queue: .main) { [weak self] _ in
                        try? FileManager.default.removeItem(at: temporaryFileURL)
                        self?.player = nil
                    }
                }
            } catch {
                print("Error generating speech: \(error)")
            }
        }
    }
}
