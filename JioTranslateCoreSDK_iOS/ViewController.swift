//
//  ViewController.swift
//  JioTranslateCoreSDKDemo
//
//  Created by Ramakrishna1 M on 17/05/24.
//

import UIKit
import JioTranslateCoreSDKiOS
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var speakerMicButton: UIButton!
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var translationTextView: PlaceHolderTextView!
    @IBOutlet weak var synthesisToSpeaker: UIButton!
    @IBOutlet weak var translateTextButton: UIButton!
    
    @IBOutlet weak var speakerLanguageLabel: UILabel!
    @IBOutlet weak var listenerLanguageLabel: UILabel!
    
    @IBOutlet weak var speakerLanguageBackView: UIView!
    @IBOutlet weak var listenerLanguageBackView: UIView!

    @IBOutlet weak var listenerLanguageDropdown: UIImageView!
    @IBOutlet weak var speakerLanguageDropdown: UIImageView!

    let audioRecorder = AudioRecorder()
    
    private var player: AVAudioPlayer?
    private(set) var isSpeechStopped: Bool = false
    private var sourceLanguage: SupportedLanguage = SupportedLanguage(languageName: "English")
    private var translateLanguage: SupportedLanguage = SupportedLanguage(languageName: "Hindi")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let jwt = "Add your JWT here"
        let userId = "Add your userId"
        
        JioTranslateManager.shared.configure(server: .sit, jwt: jwt, userId: userId)
        
        translationTextView.layer.borderColor = UIColor.systemBlue.cgColor
        translationTextView.layer.cornerRadius = 16
        translationTextView.layer.borderWidth = 1
        translationTextView.placeholder = "Translation Text"

        textView.layer.borderColor = UIColor.blue.cgColor
        textView.layer.cornerRadius = 16
        textView.layer.borderWidth = 1
        textView.placeholder = "Input Text"
        
        speakerMicButton.setTitle("Start Speech To Text", for: .normal)
        speakerMicButton.setTitle("Stop Speech To Text", for: .selected)
        
        translateTextButton.setTitle("Start Text Translation", for: .normal)

        synthesisToSpeaker.setTitle("Start Text To Speech", for: .normal)
        synthesisToSpeaker.setTitle("Stop Text To Speech", for: .selected)
        
        let languageTapAction = UITapGestureRecognizer(target: self, action: #selector(didTapLanguageActionFrom(_:)))
        let languageTapAction2 = UITapGestureRecognizer(target: self, action: #selector(didTapLanguageActionTo(_:)))

        speakerLanguageBackView.addGestureRecognizer(languageTapAction)
        listenerLanguageBackView.addGestureRecognizer(languageTapAction2)
        
        setUpAudioSession()
    }
    
    @IBAction func didPressSpeakerButtonAction(_ sender: UIButton) {
        checkRecordingPermissions(completion: { granted in
            guard granted else {
                return
            }
            DispatchQueue.main.async {
                self.speakerMicButton.isSelected = !sender.isSelected
                if self.speakerMicButton.isSelected {
                    self.startRecording()
                    print("recording started")
                }  else {
                    self.audioRecorder.stopRecording()
                    print("recording stopped")
                }
            }
        })
    }
    
    @IBAction func didPressSynthesisToSpeakerButtonAction(_ sender: UIButton) {
        self.synthesisToSpeaker.isSelected = !sender.isSelected
        
        let finalText = textView.text.replacingOccurrences(of: "\n", with: "")
        let isTextEmpty = finalText.replacingOccurrences(of: " ", with: "").isEmpty
        
        if isTextEmpty {
            self.showErrorAlert(withMessage: "Pleae enter Input Text for Text to Speech.")
            return
        }
        if self.synthesisToSpeaker.isSelected {
            textToSpeech()
        } else {
            print("Synthesis To Speaker Stopped")
            stopSpeech()
        }
    }
    
    @IBAction func didPressTranslateTextAction(_ sender: UIButton) {
        let finalText = textView.text.replacingOccurrences(of: "\n", with: "")
        let isTextEmpty = finalText.replacingOccurrences(of: " ", with: "").isEmpty
        
        if !isTextEmpty {
            JioTranslateManager.shared.startTextTranslation(inputText: textView.text ?? "", inputLanguage: sourceLanguage, translationLanguage: translateLanguage, translateEngine: .engine1) { [weak self] result in
                switch result {
                case .success(let translatedText):
                    guard let self = self else { return }
                    self.translationTextView.text = translatedText
                case .failure(let error):
                    self?.showErrorAlert(for: error)
                }
            }
        } else {
            showErrorAlert(withMessage: "Input Text is empty, please enter input text")
        }
    }
    
    @objc func didTapLanguageActionFrom(_ sender: UITapGestureRecognizer) {
        let languageVC = LanguageVC()
        let navVC = UINavigationController(rootViewController: languageVC)
        languageVC.didSelectLanguage = { language in
            if language.languageName == self.translateLanguage.languageName {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.showErrorAlert(withMessage: "The Input language and the Translate language should not be the same.")
                }
                return
            }
            self.sourceLanguage = language
            self.speakerLanguageLabel.text = language.languageName
            // Handle the selected language
            print("Selected Source Language: \(language.languageName)")
        }
        navVC.modalPresentationStyle = .overCurrentContext
        
        if !languageVC.languages.isEmpty {
            present(navVC, animated: true, completion: nil)
        } else {
            showErrorAlert(withMessage: "Language list is not available at the moment. Please try again.")
        }
    }
    
    @objc func didTapLanguageActionTo(_ sender: UITapGestureRecognizer) {
        let languageVC = LanguageVC()
        let navVC = UINavigationController(rootViewController: languageVC)
        languageVC.didSelectLanguage = { language in
            if language.languageName == self.sourceLanguage.languageName {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.showErrorAlert(withMessage: "The Input language and the Translate language should not be the same.")
                }
                return
            }
            self.translateLanguage = language
            self.listenerLanguageLabel.text = language.languageName

            // Handle the selected language
            print("Selected Translate Language: \(language.languageName)")
        }
        navVC.modalPresentationStyle = .overCurrentContext
        
        if !languageVC.languages.isEmpty {
            present(navVC, animated: true, completion: nil)
        } else {
            showErrorAlert(withMessage: "Language list is not available at the moment. Please try again.")
        }
    }
}

// MARK: - Speech to Text
extension ViewController {
    func startRecording() {
        let audioFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sound.wav")
        
        audioRecorder.startRecording(url: audioFileURL, maxRecordingTime: 59.0, maxSilenceTime: 0.8, ignoreSilence: true, enableLiveTranslation: false) { [weak self] in
            
            JioTranslateManager.shared.startSpeechToText(audioFilePath: audioFileURL, inputLanguage: self?.sourceLanguage ?? SupportedLanguage(languageName: "English"), translateEngine: .engine1) { result in
                switch result {
                case .success(let text):
                    let finalText = text.replacingOccurrences(of: "\n", with: "")
                    let isTextEmpty = finalText.replacingOccurrences(of: " ", with: "").isEmpty
                    if isTextEmpty {
                        self?.showErrorAlert(withMessage: "Audio is not clear, please try again!")
                    } else {
                        self?.textView.text = text
                    }
                case .failure(let error):
                    self?.showErrorAlert(for: error)
                }
            }
        }
    }
}

// MARK: - Text to Speech
extension ViewController {
    func textToSpeech() {
        JioTranslateManager.shared.startTextToSpeech(inputText: self.textView.text, inputLanguage: sourceLanguage, translateEngine: .engine1, gender: .male) { [weak self] result in
            switch result {
            case .success(let text):
                let finalText = text.replacingOccurrences(of: "\n", with: "")
                let isTextEmpty = finalText.replacingOccurrences(of: " ", with: "").isEmpty
                DispatchQueue.main.async {
                    if !isTextEmpty {
                        self?.playTheAudio(audioContent: text)
                    } else {
                        self?.stopSpeech()
                        print("Failed to play the audio")
                    }
                }
            case .failure(let error):
                self?.stopSpeech()
                self?.showErrorAlert(for: error)
                print("Failed to play the audio")

            }
        }
    }
    
    func playTheAudio(audioContent: String) {
        // Decode the base64 string into a Data object
        guard let audioData = Data(base64Encoded: audioContent) else {
            return
        }
        self.player = try? AVAudioPlayer(data: audioData)
        self.player?.delegate = self
        self.player?.play()
    }
    
    func stopSpeech() {
        self.player?.delegate = nil
        self.player = nil
        self.synthesisToSpeaker.isSelected = false
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopSpeech()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("error -->audioPlayerDecodeErrorDidOccur")
    }
}

extension ViewController {
    func showErrorAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // Get the root view controller to present the alert
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showErrorAlert(for error: CustomError) {
        switch error {
        case .statusCode(let code):
            if code == 401 {
                showErrorAlert(withMessage: "Unauthorized access (401 error)")
            } else {
                showErrorAlert(withMessage: "Received status code: \(code)")
            }
        case .otherError(let message):
            showErrorAlert(withMessage: "Other error occurred: \(message)")
        @unknown default:
            showErrorAlert(withMessage: "Something went wrong, please try again!")
        }
    }
    
    func checkRecordingPermissions(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion(true)
            print("Permission granted")
        case .denied:
            completion(false)
            DispatchQueue.main.async {[weak self] in
                self?.showMicroPhoneError()
            }
            print("Permission denied")
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                completion(granted)
            }
            print("Request permission here")
        @unknown default:
            completion(false)
            print("Unknown case")
        }
        return
    }
    
    func showMicroPhoneError() {
        let kBundleName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "JioTranslate"
        let errorAlert = UIAlertController(title: nil, message: "\(kBundleName) doesn't have permission to use the microphone, please change privacy settings and restart the app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in}
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        errorAlert.addAction(okAction)
        errorAlert.addAction(settingsAction)
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    func setUpAudioSession() {
        let supportedCategory: AVAudioSession.CategoryOptions = [
            .defaultToSpeaker,
            .allowBluetooth,
            .allowBluetoothA2DP,
            .allowAirPlay,
            .duckOthers,
            .interruptSpokenAudioAndMixWithOthers
        ]
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: AVAudioSession.Mode.default, options: supportedCategory)
            try audioSession.setActive(true)
        } catch {}
    }
}
