//
//  EmotionDetectionService.swift
//  wisdom
//
//  Created by Rishabh Budhouliya on 2/8/25.
//

import Foundation

class EmotionDetectionService {
    private let apiKey = "xxx"
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    
    func classifyEmotion(transcriptionText: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion("Invalid API URL")
            return
        }
        
        let prompt = """
        Classify the emotion in the user's message into one of [anger, sadness, fear, joy, love, guilt, shame, existential angst]. 
        Respond ONLY with the emotion label.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [["role": "system", "content": prompt],
                         ["role": "user", "content": transcriptionText]],
            "temperature": 0.5 // Low temperature for more deterministic responses
        ]
        
        do {
            print("here's the transcibed text: \(transcriptionText)")
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
    
    // New method that takes the transcription text, classifies the emotion, and prints the result.
    func printDetectedEmotion(from transcriptionText: String) {
        classifyEmotion(transcriptionText: transcriptionText) { detectedEmotion in
            if let emotion = detectedEmotion {
                UserDefaults.standard.set(emotion, forKey: "emotionKey")
                print("Detected emotion: \(emotion)")
            } else {
                print("Could not detect emotion or an error occurred.")
            }
        }
    }
}
