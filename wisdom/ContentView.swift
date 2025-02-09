import SwiftUI

struct ContentView: View {
    @StateObject private var recorderViewModel = VoiceRecorderViewModel()
    @State private var gradientColors: [Color] = [.blue, .purple]
    @State private var rippleOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: gradientColors)
                .onAppear {
                    animateGradient()
                }
            
            // Ripple effect overlay
            Circle()
                .stroke(Color.white.opacity(rippleOpacity), lineWidth: 5)
                .scaleEffect(rippleOpacity > 0 ? 3 : 1)
                .opacity(rippleOpacity)
                .animation(.easeOut(duration: 1.2), value: rippleOpacity)
            
            VStack(spacing: 20) {
                Text("Ask!")
                    .font(.custom("New York", size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(recorderViewModel.transcriptionText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .font(.custom("Helvetica Neue", size: 14))
                
                // Concentric circular record button with background ripple effect
                ZStack {
                    Circle()
                        .stroke(lineWidth: 4)
                        .foregroundColor(recorderViewModel.isRecording ? .red : .gray)
                        .frame(width: 80, height: 80)
                        .scaleEffect(recorderViewModel.isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5))
                    
                    Circle()
                        .foregroundColor(recorderViewModel.isRecording ? .red : .gray)
                        .frame(width: 60, height: 60)
                    
                    Button(action: {
                        recorderViewModel.toggleRecording()
                        triggerRipple()
                    }) {
                        Circle()
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .fullScreenCover(isPresented: $recorderViewModel.showVoice) {
                let emotion = UserDefaults.standard.string(forKey: "emotionKey")!
                
                Voice(emotion: emotion, author: EmotionAuthorRetrieval.shared.getAuthor(emotion: emotion))
            }
            .padding()
        }
    }
    
    private func animateGradient() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            gradientColors = [Color.purple, Color.blue, Color.teal, Color.indigo].shuffled()
        }
    }
    
    private func triggerRipple() {
        rippleOpacity = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            rippleOpacity = 0.0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
