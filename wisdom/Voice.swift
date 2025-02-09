import Foundation
import AVFoundation
import SwiftUI

struct Voice: View {
    @ObservedObject var viewModel: VoiceUIViewModel
    @State private var isLoading: Bool = true
    @State private var displayedLines: [String] = []  // Add this line
    
    init(emotion: String, author: [String]) {
        let viewModel = VoiceUIViewModel()
        self.viewModel = viewModel
        print("are we reaching at voice?")
        // Start loading the advice
        let adviceService = AdviceGenerationService()
        adviceService.generateAdvice(emotion: emotion, author: author) { advice in
            DispatchQueue.main.async {
                if let advice = advice {
                    viewModel.textToSpeak = advice
                    viewModel.shouldSpeak = true
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Generating advice...")
            } else {
                ScrollView {
                    // Add spacer to push content down
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(displayedLines, id: \.self) { line in
                            Text(line)
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom))
                                .animation(.easeInOut, value: displayedLines)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Add spacer at bottom for scrolling room
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 3)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.90, blue: 0.85))
        .onAppear {
            // Move speaking logic to onChange to wait for text
        }
        .onChange(of: viewModel.shouldSpeak) { newValue in
            if newValue && !viewModel.textToSpeak.isEmpty {
                isLoading = false
                let lines = viewModel.textToSpeak.components(separatedBy: ". ")
                displayedLines.removeAll()
                
                // Constants for timing calculations
                let wordsPerMinute = 150.0 // OpenAI's approximate speaking rate
                let wordsPerSecond = wordsPerMinute / 60.0
                
                viewModel.speakText()
                // Initial delay of 4 seconds before starting
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    var cumulativeDelay = 0.0
                    
                    for (index, line) in lines.enumerated() {
                        // Calculate delay based on word count
                        let wordCount = Double(line.split(separator: " ").count)
                        let lineDelay = wordCount / wordsPerSecond
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeDelay) {
                            withAnimation {
                                displayedLines.append(line.trimmingCharacters(in: .whitespaces) + ".")
                            }
                        }
                        
                        cumulativeDelay += lineDelay
                    }
                }
            }
        }
    }
}
