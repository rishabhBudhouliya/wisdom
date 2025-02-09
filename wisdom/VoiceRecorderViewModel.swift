import Foundation
import SwiftUI
import AVFoundation
import Speech

class VoiceRecorderViewModel: ObservableObject {
    // Published properties for updating the UI
    @Published var transcriptionText: String = ""
    @Published var isRecording: Bool = false

    // Speech recognition properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let emotionDetectionService = EmotionDetectionService()
    private var latestTranscription: String = ""
    
    @Published var showVoice: Bool = false
    
    // Request authorization when the view model is initialized
    init() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                default:
                    self.transcriptionText = "Speech recognition not authorized"
                }
            }
        }
    }
    
    // Toggle recording: start if not recording, stop if currently recording
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    // Configure and start the audio engine and speech recognizer
    func startRecording() {
        // Cancel the previous task if it's still running
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                self.transcriptionText = "Audio session error: \(error.localizedDescription)"
            }
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            DispatchQueue.main.async {
                self.transcriptionText = "Unable to create a recognition request"
            }
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        // Start recognition with the request and handle results in the resultHandler
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.transcriptionText = result.bestTranscription.formattedString
                        self.latestTranscription = result.bestTranscription.formattedString
                    }

                }
                
                if error != nil || (result?.isFinal ?? false) {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    DispatchQueue.main.async {
                        self.isRecording = false
                    }
                }
            })
        
        // Configure the audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
                self.transcriptionText = "Listening..."
            }
        } catch {
            DispatchQueue.main.async {
                self.transcriptionText = "Audio Engine couldn't start: \(error.localizedDescription)"
            }
        }
    }
    
    // Stop the recording and end the audio session
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        if !latestTranscription.isEmpty {
            emotionDetectionService.printDetectedEmotion(from: latestTranscription)
        }
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.showVoice = true
        }
    }
} 
