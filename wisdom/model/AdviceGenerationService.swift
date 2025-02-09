//
//  AdviceGenerationService.swift
//  wisdom
//
//  Created by Rishabh Budhouliya on 2/9/25.
//
import Foundation

class AdviceGenerationService {
    private let apiKey = "xxx"
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    
    func generateAdvice(emotion: String, author: [String], completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion("Invalid API URL")
            return
        }
        
        print("Using the emotion for advice: \(emotion)")
        
        let systemPrompt = """
        "You are a mother combining wisdom from classic authors to help users navigate emotions. Always structure concise and simple responses that contains
        advice using the given author's themes, phrased in a conversational manner without mentioning the author's name"  
        """
        
        let randomInt = Int.random(in: 0..<3)
        
        let prompt = """
        "The user feels this \(emotion) and you respond with an intention to have a conversation like \(author[randomInt]). Respond with an intention to create trust and comfort, a sense of safe space but not do not deviate from truth and absolute faith towards the author's mind)"
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [["role": "system", "content": systemPrompt],
                         ["role": "user", "content": prompt]],
            "temperature": 0.5 // Low temperature for more deterministic responses
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion("Request failed: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    completion("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        print("here's ai response: \(content.trimmingCharacters(in: .whitespacesAndNewlines))")
                        completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        completion("Invalid API response")
                    }
                } catch {
                    completion("JSON parsing error: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        } catch {
            completion("Failed to create request body: \(error.localizedDescription)")
        }
    }
    
//    // New method that takes the transcription text, classifies the emotion, and prints the result.
//    func printDetectedEmotion(from transcriptionText: String) {
//        classifyEmotion(transcriptionText: transcriptionText) { detectedEmotion in
//            if let emotion = detectedEmotion {
//                UserDefaults.standard.set(emotion, forKey: "emotionKey")
//                print("Detected emotion: \(emotion)")
//            } else {
//                print("Could not detect emotion or an error occurred.")
//            }
//        }
//    }
}
