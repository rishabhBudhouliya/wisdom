//
//  EmotionAuthorRetreival.swift
//  wisdom
//
//  Created by Rishabh Budhouliya on 2/8/25.
//

class EmotionAuthorRetrieval {
    static let shared = EmotionAuthorRetrieval(authorName: [], emotions: "")
    
    private let authorName: [String]
    private let emotions: String
    
    static let data: [EmotionAuthorRetrieval] = [
        EmotionAuthorRetrieval(authorName: ["Oscar Wilde", "Rumi", "Maya Angelou"], emotions: "joy"),
        EmotionAuthorRetrieval(authorName: ["Dostoevsky", "Kafka", "Yukio Mishima"], emotions: "sadness"),
        EmotionAuthorRetrieval(authorName: ["Yukio Mishima", "Toni Morisson", "Maya Angelou"], emotions: "anger"),
        EmotionAuthorRetrieval(authorName: ["Frank Herbert", "Mary Shelley", "Freud"], emotions: "fear"),
        EmotionAuthorRetrieval(authorName: ["Freud", "Nathaniel Hawthorne", "Kafka"], emotions: "guilt"),
        EmotionAuthorRetrieval(authorName: ["Frank Herbert", "Yukio Mishima", "Nietzsche"], emotions: "existential angst")
    ]
    
    private init(authorName: [String], emotions: String) {
        self.authorName = authorName
        self.emotions = emotions
    }
    
    func getAuthor(emotion: String) -> [String] {
        // Find the matching emotion entry and return its authors
        if let matchingEmotion = EmotionAuthorRetrieval.data.first(where: { $0.emotions.lowercased() == emotion.lowercased() }) {
            return matchingEmotion.authorName
        }
        return []
    }
}
