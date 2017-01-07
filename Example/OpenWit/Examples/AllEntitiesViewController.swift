//
//  AllEntitiesViewController.swift
//  OpenWit
//
//  Created by fauquette fred on 7/01/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import OpenWit


/// An example to call all entities on Wit
/*
 func getEntities(completion: @escaping (_ result: OpenWitResult<OpenWitAllEntitiesModel, OpenWitError>) -> ())
 */
class AllEntitiesViewController: UIViewController {
    
    @IBOutlet var textView : UITextView!
    
    @IBAction func testEntitiesButton(_ sender: Any) {
        OpenWit
            .sharedInstance
            .getEntities {[weak self] result in
                switch result {
                case .success(let entities):
                    self?.textView.text =  entities.entityIds?.description ?? "none"
                case .failure(let error):
                    self?.textView.text = error.localizedDescription
                }
        }
    }
}
