//
//  BasePresenter.swift
//  Quizzler-iOS13
//
//  Created by LIN SHI ZHENG on 8/12/22.
//  Copyright © 2022 The App Brewery. All rights reserved.
//

import Foundation

open class BasePresenter: ViewControllerProtocol {
    
    weak var vc: ViewController?
    
    var isMcq = false
    var correctAnswer : Float = 0
    var totalQuestions : Float = 0
    
    var mcqQuestions : [String:[String:Bool]]?
    var trueAndFalseQuestions : [String:Bool]?
    
    init(vc: ViewController?) {
        self.vc = vc
        
        loadQuestions()
        getQuestion()
    }
    
    func trueIsTriggered() {
        setButtonsEnable(enable: false)
        checkAnswer(TfAns: true)
    }
    
    func falseIsTriggered() {
        setButtonsEnable(enable: false)
        checkAnswer(TfAns: false)
    }
    
    func nextIsTriggered() {
        guard let mcqCounts = mcqQuestions?.count, let trueAndFalseCount = trueAndFalseQuestions?.count, mcqCounts > 0 || trueAndFalseCount > 0 else {
            loadQuestions()
            getQuestion()
            return
        }
        
        if vc?.nextBtn.titleLabel?.text == "Retry" {
            loadQuestions()
            getQuestion()
        }
        setButtonsEnable(enable: true)
        resetBtnsColors()
        nextQuestion()
    }
    
    func setButtonsEnable(enable: Bool) {
        vc?.trueBtn.isEnabled = enable
        vc?.falseBtn.isEnabled = enable
        vc?.nextBtn.isEnabled = !enable
    }
    
    func resetBtnsColors() {
        DispatchQueue.main.async {
            if let vc = self.vc {
                vc.trueBtn.backgroundColor = .clear
                vc.falseBtn.backgroundColor = .clear
            }
        }
    }
    
    func loadQuestions() {

        resetToDefault()
        
        if let path = Bundle.main.path(forResource: "Questions", ofType: "plist"), let questionsDict = NSDictionary(contentsOfFile: path)  {
            if isMcq {
                mcqQuestions = questionsDict["MCQ"] as? [String:[String:Bool]]
                totalQuestions = Float(mcqQuestions!.count)
            } else {
                trueAndFalseQuestions = questionsDict["True and False"] as? [String:Bool]
                totalQuestions = Float(trueAndFalseQuestions!.count)
            }
        }
    }
    
    func getQuestion () {
        DispatchQueue.main.async {
            if let vc = self.vc, vc.isViewLoaded {
                if self.isMcq {
                    if let question = self.getMcqQuestion() {
                        vc.questionLbl.text = question
                    } else {
                        vc.questionLbl.text = "Your total Score is \(vc.progressBar.progress * 100)"
                        vc.nextBtn.setTitle("Retry", for: .normal)
                        self.setButtonsEnable(enable: false)
                    }
                    
                } else {
                    if let question = self.getTFQuestion() {
                        vc.questionLbl.text = question
                    } else {
                        vc.questionLbl.text = "Your total Score is \(vc.progressBar.progress * 100)"
                        vc.nextBtn.setTitle("Retry", for: .normal)
                        self.setButtonsEnable(enable: false)
                    }
                }
            }
        }
    }
    
    func nextQuestion() {
        if let currentQuestion = vc?.questionLbl.text {
            if isMcq {
                mcqQuestions?.removeValue(forKey: currentQuestion)
            } else {
                trueAndFalseQuestions?.removeValue(forKey: currentQuestion)
            }
        }
        getQuestion()
    }
    
    func answerIsCorrect(mcqAns: String? = nil, TfAns: Bool? = nil) -> Bool? {
        if let currentQuestion = vc?.questionLbl.text {
            if isMcq {
                if let isMcqAnswerCorrect = isMcqAnswerCorrect(question: currentQuestion, answer: mcqAns!) {
                    return isMcqAnswerCorrect
                }
            } else {
                if let isTfAnswerCorrect = isTFAnswerCorrect(question: currentQuestion, answer: TfAns!) {
                    return isTfAnswerCorrect
                }
            }
        }
        return nil
    }
    
    func checkAnswer(mcqAns: String? = nil, TfAns: Bool? = nil) {
        DispatchQueue.main.async {
            if let vc = self.vc {
                if let answerIsCorrect = self.answerIsCorrect(TfAns: true) {
                    vc.trueBtn.backgroundColor = answerIsCorrect ? .green : .red
                    self.correctAnswer += answerIsCorrect ? 1 : 0
                } else if let answerIsCorrect = self.answerIsCorrect(TfAns: false) {
                    vc.falseBtn.backgroundColor = answerIsCorrect ? .green : .red
                    self.correctAnswer += answerIsCorrect ? 1 : 0
                }
                self.updateProgressBar()
            }
        }
    }
    
    func getTFQuestion() -> String? {
        return trueAndFalseQuestions?.randomElement()?.key
    }
    
    func getMcqQuestion() -> String? {
        return mcqQuestions?.randomElement()?.key
    }
    
    func isTFAnswerCorrect(question: String, answer: Bool) -> Bool? {
        return trueAndFalseQuestions?[question] == answer
    }
    
    func isMcqAnswerCorrect(question: String, answer: String) -> Bool? {
        return mcqQuestions?[question]?[answer]
    }
    
    func updateProgressBar() {
        
        guard totalQuestions > 0 else { return }
        DispatchQueue.main.async {
            if let vc = self.vc {
                vc.progressBar.setProgress(self.correctAnswer / self.totalQuestions, animated: true)
            }
        }
    }
    
    func resetToDefault() {
        
        correctAnswer = 0
        
        DispatchQueue.main.async {
            if let vc = self.vc, vc.isViewLoaded {
                vc.progressBar.setProgress(0, animated: false)
                vc.nextBtn.isEnabled = false
                vc.nextBtn.setTitle("Next", for: .normal)
            }
        }
    }
}
