//
//  Question.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/10/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import Foundation
class Question {
    let questionText : String
    let answerNum : Int
    
    init (text: String, answer: Int) {
        questionText = text
        answerNum = answer
    }
}
