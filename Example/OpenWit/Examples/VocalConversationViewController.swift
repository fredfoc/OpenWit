//
//  VocalConversationViewController.swift
//  OpenWit
//
//  Created by fauquette fred on 7/01/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation


import UIKit
import ObjectMapper
import Speech
import OpenWit
import AVFoundation




class VocalConversationViewController: UIViewController {
    
    @IBOutlet var textView : UITextView!
    @IBOutlet var userResultLabel : UILabel!
    @IBOutlet var recordButton : UIButton!
    
    private let conversationManager = OpenWitConversationManager()
    
    private var conversationWasStarted = false
    
    // MARK:- some stuff for speechrecognition
    
    // MARK: Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    private let synth = AVSpeechSynthesizer()
    
    private var WitResponse: String?
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    func talk(_ message: String) {
        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: message)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            let lang = "fr-FR"
            utterance.voice = AVSpeechSynthesisVoice(language: lang)
            utterance.volume = 1
            self.synth.speak(utterance)
        }
    }
    
    
    @IBAction func startConversation() {
        textView.text = ""
        conversationManager.startConversation()
        conversationWasStarted = true
        userResultLabel.text = "Now hit startRecording..."
    }
    
    
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
        } else {
            try! startRecording()
            recordButton.setTitle("Stop recording", for: [])
        }
    }
    
    
    // MARK: private methods
    
    
    var file: AVAudioFile?
    
    private func startRecording() throws {
        userResultLabel.text = ""
        if !conversationWasStarted {
            startConversation()
        }
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [unowned self] (result, error) in
            var isFinal = false
            
            if let result = result {
                self.userResultLabel.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
                
                if let result = result {
                    self.userResultLabel.text = result.bestTranscription.formattedString
                    self.printResult("You : \(result.bestTranscription.formattedString)")
                    self.conversationManager.converse(result.bestTranscription.formattedString) {[unowned self] (response) in
                        self.printResult("WIT : \(response)")
                        self.talk(response)
                    }
                }
                
            }
        }
        
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        printResult("(Go ahead, I'm listening)")
    }
    
    private func URLFor(filename: String) -> URL {
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        let dir = dirs[0]
        let path = dir + "/" + filename
        return  URL(fileURLWithPath: path)
    }
    
    private func printResult(_ str: String) {
        textView.text = textView.text + "\n" + str
    }
}

extension VocalConversationViewController: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
}
