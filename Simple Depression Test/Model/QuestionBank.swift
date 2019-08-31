//
//  QuestionBank.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/9/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
class QuestionBank {
    static let severityColorForGAD7 = [UIColor.green, .yellow, .orange, .red]
    static let severityColorForPHQ9 = [UIColor.green, .yellow, .orange, .red, .purple]
    var questions: [String] = []
    var questionArray: [String] = []
    var radarArray: [String] = []
    var severityArray: [String]  = []
    static var severityColors = severityColorForPHQ9
    
    init () {
        switch Settings.questionSet {
        case "phq9":
            questions = ["Little interest or pleasure in doing things".localized, "Feeling down, depressed, or hopeless".localized, "Trouble falling or staying asleep, or sleeping too much".localized, "Feeling tired or having little energy".localized, "Poor appetite or overeating".localized, "Feeling bad about yourself or that you are a failure or have let yourself or your family down".localized, "Trouble concentrating on things, such as reading the newspaper or watching television".localized, "Moving or speaking so slowly that other people could have noticed. Or the opposite being so figety or restless that you have been moving around a lot more than usual".localized, "Thoughts that you would be better off dead, or of hurting yourself".localized, "If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?".localized]
            questionArray = ["Interest deficit (anhedonia)".localized,"Depressed mood".localized,"Sleep disorder (increased or decreased)".localized,"Energy deficit".localized,"Appetite disorder (increased or decreased)".localized,"Guilt (worthlessness, hopelessness, regret)".localized,"Concentration deficit".localized,"Psychomotor retardation or agitation".localized,"Suicidality".localized]
            radarArray = ["Anhedonia".localized,"Low Mood".localized,"Sleep".localized,"Fatigue".localized,"Appetite".localized,"Worthlessness".localized,"Concentration".localized,"Movement".localized,"Suicide".localized,"Function impairment".localized]
            severityArray = ["None to minimal".localized, "Mild".localized, "Moderate".localized, "Moderately severe".localized, "Severe".localized]
            
        case "gad7":
            questions = ["Feeling nervous, anxious or on edge".localized, "Not being able to stop or control worrying".localized, "Worrying too much about different things".localized, "Trouble relaxing".localized, "Being so restless that it is hard to sit still".localized, "Becoming easily annoyed or irritable".localized, "Feeling afraid as if something awful might happen".localized, "If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?".localized]
            questionArray = ["Feeling nervous or anxious".localized, "Difficult to control the worry".localized, "Worrying too much about different things".localized, "Trouble relaxing".localized, "Restlessness".localized, "Irritability".localized, "Feeling afraid".localized]
            radarArray =  ["Feeling nervous".localized, "Difficult to ctrl...".localized, "Worry too much".localized, "Trouble relaxing".localized, "Restlessness".localized, "Irritability".localized, "Feeling afraid".localized, "Function impairment".localized]
            severityArray = ["None to minimal".localized, "Mild".localized, "Moderate".localized
                , "Severe".localized
            ]
        default: break
        }
    }



}
