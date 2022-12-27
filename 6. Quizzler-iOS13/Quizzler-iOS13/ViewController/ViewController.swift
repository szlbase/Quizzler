//
//  ViewController.swift
//  Quizzler-iOS13
//
//  Created by Angela Yu on 12/07/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit

protocol ViewControllerProtocol: AnyObject {
    
    var vc: ViewController? {get}
    
    func trueIsTriggered()
    func falseIsTriggered()
    func nextIsTriggered()
}

class ViewController: UIViewController {
    
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var trueBtn: UIButton!
    @IBOutlet weak var falseBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    weak var presenter: ViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func trueIsTriggered(_ sender: UIButton) {
        presenter?.trueIsTriggered()
    }
    
    @IBAction func falseisTriggered(_ sender: UIButton) {
        presenter?.falseIsTriggered()
    }
    
    @IBAction func nextIsTriggered(_ sender: UIButton) {
        presenter?.nextIsTriggered()
    }
    
    
}

