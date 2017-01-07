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




class VocalConversationViewController: UIViewController {
    
    @IBOutlet var textView : UITextView!
    
    @IBOutlet var recordButton : UIButton!
    
    // MARK:- some stuff for speechrecognition
    
    // MARK: Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
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
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
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
                    OpenWit
                        .sharedInstance
                        .message(result.bestTranscription.formattedString,
                                 messageId: nil,
                                 threadId: nil) {[unowned self] result in
                                    switch result {
                                    case .success(let message):
                                        self.printResult(message.intents?.description ?? "no intent", clearResult: true)
                                        /// shopItems are custom entities
                                        self.printResult(message.shopItems?.description ?? "no shopItem")
                                        /// shopLists are custom entities
                                        self.printResult(message.shopLists?.description ?? "no shopList")
                                    case .failure(let error):
                                        print(error)
                                    }
                    }
                }
                
                if let data = try? Data(contentsOf: self.URLFor(filename: "my_file.caf")){
                    OpenWit.sharedInstance.speech(audioFile: data,
                                                  audioFormat: kAudioFormatLinearPCM) { result in
                                                    switch result {
                                                    case .success(let message):
                                                        /// Your logic should start here... :-)
                                                        /// intents are generic entities so they are built in
                                                        print(message.intents ?? "no intent")
                                                        /// shopItems are custom entities
                                                        print(message.shopItems ?? "no shopItem")
                                                    case .failure(let error):
                                                        print(error)
                                                    }
                    }
                }
                
                
            }
        }
        
        
        file = try! AVAudioFile(forWriting: URLFor(filename: "my_file.caf"), settings: inputNode.inputFormat(forBus: 0).settings)
        print(inputNode.inputFormat(forBus: 0).settings)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            try! self.file?.write(from: buffer)
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textView.text = "(Go ahead, I'm listening)"
    }
    
    private func URLFor(filename: String) -> URL {
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        let dir = dirs[0]
        let path = dir + "/" + filename
        return  URL(fileURLWithPath: path)
    }
    
    private func printResult(_ str: String, clearResult: Bool = false) {
        textView.text = clearResult ? str : textView.text + "\n" + str
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
