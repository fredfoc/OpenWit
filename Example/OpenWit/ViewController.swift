//
//  ViewController.swift
//  OpenWit
//
//  Created by fauquette fred on 12/29/2016.
//  Copyright © 2016 Fred Fauquette. All rights reserved.
//

import UIKit
import ObjectMapper
import Speech
import OpenWit

/// a custom entity defined in Wit
struct ShopItemEntity: Mappable, OpenWitGenericEntityModelProtocol {
    static var entityId = "shopItem"
    
    var suggested: Bool = false
    var confidence: Float?
    var type: String?
    var value: String?
    
    public init?(map: Map) {}
}

/// a custom entity defined in Wit
struct ShopListEntity: Mappable, OpenWitGenericEntityModelProtocol {
    static var entityId = "shopList"
    
    var suggested: Bool = false
    var confidence: Float?
    var type: String?
    var value: String?
    
    public init?(map: Map) {}
}

/// a custom enity defined as an answer
struct AddShopItemAnswerModel: Mappable {
    
    var missingShopItem: String?
    var missingShopList: String?
    var missingAll: Bool?
    var allOk: String?
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        missingShopItem          <- map["missingShopItem"]
        missingShopList                <- map["missingShopList"]
        missingAll               <- map["missingAll"]
        allOk           <- map["allOk"]
    }
    
    init(allOk: String?, missingShopItem: String?, missingShopList: String?, missingAll: Bool?) {
        self.allOk = allOk
        self.missingShopItem = missingShopItem
        self.missingShopList = missingShopList
        self.missingAll = missingAll
    }
}

struct CreateListAnswerModel: Mappable {
    
    var listName: String?
    var missingListName: String?
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        missingListName          <- map["missingListName"]
        listName                <- map["listName"]
    }
    
    init(listName: String?, missingListName: String?) {
        self.listName = listName
        self.missingListName = missingListName
    }
}

struct OpenWitContext: Mappable {
    
    var timeZone: String?
    var referenceTime: String?
    
    static let localTimeZoneName = {
        return (NSTimeZone.local as NSTimeZone).name
    }()
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        referenceTime           <- map["reference_time"]
        timeZone                <- map["timezone"]
    }
    
    init(referenceTime: String?) {
        self.timeZone = OpenWitContext.localTimeZoneName
        self.referenceTime = referenceTime
    }
}

/// get it in message Model
extension OpenWitMessageModel {
    var shopItems: [ShopItemEntity]? {
        return try? getEntitities(for: ShopItemEntity.entityId)
    }
    
    var shopLists: [ShopListEntity]? {
        return try? getEntitities(for: ShopListEntity.entityId)
    }
}

/// get it in converse Model
extension OpenWitConverseModel {
    var shopItem: ShopItemEntity? {
        return try? getEntitities(for: ShopItemEntity.entityId)[0]
    }
    
    var shopList: ShopListEntity? {
        return try? getEntitities(for: ShopListEntity.entityId)[0]
    }
}


class ViewController: UIViewController {
    
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
    
    @IBOutlet var textFieldMessage : UITextField!
    
    @IBAction func testMessageButton(_ sender: Any) {
        guard let message = textFieldMessage.text else {
            return
        }
        OpenWit
            .sharedInstance
            .message(message,
                     messageId: nil,
                     threadId: nil) {[unowned self] result in
                        switch result {
                        case .success(let message):
                            /// Your logic should start here... :-)
                            /// intents are generic entities so they are built in
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
    
    @IBAction func testEntitiesButton(_ sender: Any) {
        OpenWit
            .sharedInstance
            .getEntities { result in
                switch result {
                case .success(let entities):
                    print(entities.entityIds ?? "none")
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    // MARK:- some stuff for conversation
    
    // MARK: Properties
    
    @IBOutlet var textField : UITextField!
    var converseSessionId = "1234"
    var nextConverseType = OpenWitConverseType.unknwon
    
    
    @IBAction func startConversation(_ sender: Any) {
        textView.text = ""
        converseSessionId = randomString(length: 10)
        let context = OpenWitContext(referenceTime: Date().referenceTime)
        converse(context: context)
    }
    
    @IBAction func answer(_ sender: Any) {
        converse()
    }
    
    private func converse(context: Mappable? = nil) {
        guard let message = textField.text else {
            return
        }
        textField.text = ""
        printResult("You: " + message)
        OpenWit
            .sharedInstance
            .conversationMessage(message,
                                 sessionId: converseSessionId,
                                 context: context)  {[unowned self] result in
                                    switch result {
                                    case .success(let converse):
                                        /// Your logic should start here... :-)
                                        var message: String?
                                        self.nextConverseType = converse.type
                                        switch converse.type {
                                        case .action:
                                            if let action = converse.action {
                                                switch action {
                                                case "addShopItem":
                                                    self.addShopItem(converse: converse, context: context)
                                                case "createList":
                                                    self.createList(converse: converse, context: context)
                                                default:
                                                    break
                                                }
                                            }
                                            
                                            
                                        case .msg:
                                            message = converse.msg!
                                        case .merge:
                                            message = "some merge"
                                        case .stop:
                                            message = "end of conversation"
                                        case .unknwon:
                                            message = "oups something stange happened"
                                        }
                                        if let message = message {
                                            self.printResult("WIT: \(message)")
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
        }
    }
    
    private func createList(converse: OpenWitConverseModel, context: Mappable? = nil){
        let createListAnswerModel: CreateListAnswerModel
        if let shopList = converse.shopList {
            createListAnswerModel = CreateListAnswerModel(listName: shopList.value, missingListName: nil)
        } else {
            createListAnswerModel = CreateListAnswerModel(listName: nil, missingListName: "something is missing here")
        }
        OpenWit.sharedInstance.conversationAction(createListAnswerModel,
                                                  sessionId: converseSessionId,
                                                  context: context) {[unowned self] result in
                                                    switch result {
                                                    case .success(let converse):
                                                        /// Your logic should start here... :-)
                                                        var message: String?
                                                        self.nextConverseType = converse.type
                                                        switch converse.type {
                                                        case .action:
                                                            print(converse)
                                                        case .msg:
                                                            message = converse.msg!
                                                        case .merge:
                                                            message = "some merge"
                                                        case .stop:
                                                            message = "end of conversation"
                                                        case .unknwon:
                                                            message = "oups something stange happened"
                                                        }
                                                        if let message = message {
                                                            self.printResult("WIT: \(message)")
                                                        }
                                                    case .failure(let error):
                                                        print(error)
                                                    }
        }
    }
    
    private func addShopItem(converse: OpenWitConverseModel, context: Mappable? = nil){
        let addShopItemAnswerModel: AddShopItemAnswerModel
        if let shopItem =  converse.shopItem, let shopList = converse.shopList {
            addShopItemAnswerModel = AddShopItemAnswerModel(allOk: (shopItem.value ?? "strange product") +  " ajouté à " + (shopList.value ?? "strange list"),
                                                            missingShopItem: nil,
                                                            missingShopList: nil,
                                                            missingAll: nil)
        } else if let shopItem =  converse.shopItem {
            addShopItemAnswerModel = AddShopItemAnswerModel(allOk: nil,
                                                            missingShopItem: nil,
                                                            missingShopList: shopItem.value,
                                                            missingAll: nil)
        } else if let shopList = converse.shopList {
            addShopItemAnswerModel = AddShopItemAnswerModel(allOk: nil,
                                                            missingShopItem: shopList.value,
                                                            missingShopList: nil,
                                                            missingAll: nil)
        } else {
            addShopItemAnswerModel = AddShopItemAnswerModel(allOk: nil,
                                                            missingShopItem: nil,
                                                            missingShopList: nil,
                                                            missingAll: true)
        }
        OpenWit.sharedInstance.conversationAction(addShopItemAnswerModel,
                                                  sessionId: converseSessionId,
                                                  context: context) {[unowned self] result in
                                                    switch result {
                                                    case .success(let converse):
                                                        /// Your logic should start here... :-)
                                                        var message: String?
                                                        self.nextConverseType = converse.type
                                                        switch converse.type {
                                                        case .action:
                                                            self.addShopItem(converse: converse, context: context)
                                                        case .msg:
                                                            message = converse.msg!
                                                        case .merge:
                                                            message = "some merge"
                                                        case .stop:
                                                            message = "end of conversation"
                                                        case .unknwon:
                                                            message = "oups something stange happened"
                                                        }
                                                        if let message = message {
                                                            self.printResult("WIT: \(message)")
                                                        }
                                                    case .failure(let error):
                                                        print(error)
                                                    }
        }
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    // MARK:- some stuff for speechrecognition
    
    // MARK: Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet var textView : UITextView!
    
    @IBOutlet var recordButton : UIButton!
    
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
    
    
    
    private func printResult(_ str: String, clearResult: Bool = false) {
        textView.text = clearResult ? str : textView.text + "\n" + str
    }
}

extension ViewController: SFSpeechRecognizerDelegate {
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

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension Date {
    var referenceTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: self)
    }
}



