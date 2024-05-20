//
//  NativeAPIContractSTSViewModel.swift
//  JioTranslate
//
//  Created by Ramakrishna1 M on 07/02/24.
//

import Foundation
import AVFoundation

class NativeContractApiSTSViewModel {
    var language: SupportedLanguage = .english

    init() { }

    public func recognizeFromMic(audioFileURL: URL, language: SupportedLanguage, selectedEngine: TranslateEngineType, completion:  @escaping (Result<String, CustomError>) -> Void) {
        self.language = language
        self.recognizeFromFile(audioFileURL: audioFileURL, selectedEngine: selectedEngine, completion: completion)
    }
    
    func recognizeFromFile(audioFileURL: URL, selectedEngine: TranslateEngineType, completion:  @escaping (Result<String, CustomError>) -> Void) {
        transcribeAudio(audioURL: audioFileURL, selectedEngine: selectedEngine, completion: completion)
    }
    
    func transcribeAudio(audioURL: URL, selectedEngine: TranslateEngineType, completion: @escaping (Result<String, CustomError>) -> Void) {
        guard let audioData = try? Data(contentsOf: audioURL) else {
            completion(.failure(.otherError("")))
            return
        }

        let audioAsset = AVURLAsset.init(url: audioURL, options: nil)
        let duration = audioAsset.duration
        let durationInSeconds = Int(CMTimeGetSeconds(duration))

        let base64EncodedAudio = audioData.base64EncodedString()

        let requestPayload: [String: Any] = [
            "config": [
                "encoding": "LINEAR16",
                "sampleRateHertz": 16000,
                "language": self.language.rawValue
            ] as [String : Any],
            "audio": [
                "content": base64EncodedAudio
            ],
            "platform" : selectedEngine.rawValue,
            "duration" : durationInSeconds
        ]
        logPayload(requestPayload: requestPayload)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestPayload) else {
            completion(.failure(.otherError("")))
            return
        }
        var urlRequest = URLRequest(url: URL(string: ContractAPIPath.stt.rawValue)!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(JioTranslateManager.shared.currentJWT, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("iOS", forHTTPHeaderField: "User-Agent")
        urlRequest.addValue(JioTranslateManager.shared.currentUserGuestID, forHTTPHeaderField: "x-user-id")
        urlRequest.addValue("converse", forHTTPHeaderField: "x-user-action")
        urlRequest.addValue(JioTranslateManager.shared.phoneNumber, forHTTPHeaderField: "x-user-identity")

        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    // Handle non-HTTP response
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    completion(.failure(.statusCode(401)))
                    return
                }
                
                if let error = error {
//                    print("Error: \(error.localizedDescription)")
                    self?.logError(response: response, error: error.localizedDescription)
                    completion(.failure(.otherError("")))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.otherError("")))
                    return
                }
                
                let result = self?.parseSpeechRecognitionResponse(data: data)
                completion(.success(result ?? ""))
            }
        }
        task.resume()
    }
    
    private func parseSpeechRecognitionResponse(data: Data) -> String? {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let status = jsonResponse?["status"] as? String, status == "success", let transcribedText = jsonResponse?["recognized_text"] as? String  {
                return transcribedText
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }

        return nil
    }
    
    func logPayload(requestPayload: [String: Any]) {
        var logPayload = requestPayload
        if var audio = logPayload["audio"] as? [String: Any] {
            audio["content"] = "base64EncodedAudio"
            logPayload["audio"] = audio
        } else {
            print("Invalid audio data in requestPayload")
        }
    }
    
    func logError(response: URLResponse?, error: String) {
        // Check if response is an HTTPURLResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid HTTP response")
            return
        }
    }
}
