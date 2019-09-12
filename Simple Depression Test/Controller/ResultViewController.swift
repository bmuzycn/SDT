//
//  ResultViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/20/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData
import Charts

class ResultViewController: UIViewController, DataDelegate, ChartViewDelegate {

    let interactor = Interactor()

    var currentUser: String = ""
    var totalScore = 0
    var totalScores = [Int]() //for total scores
    var scores = [Int]() //receive from menuVC and pass to reportVC
    var result = ""
    var results = Array<String>()
    var dateArray = [String]()
    var date = ""
    var scoreArray = [[Int]]() //for scores of each question
    var scoreArrayNum: Int?
    var numberOfFetch : Int?
    var flag = true //if the dataSet > fetchLimit
    var isDataSentFromRecordsMenu = false
    
    @IBAction func unwindSegueToResultView(unwindSegue: UIStoryboardSegue) {
        print("Welcome back to resultView")
    }
    @IBOutlet weak var menuView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var last25: UIButton!
    @IBOutlet weak var next25: UIButton!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var lineView: LineChartView!
    @IBOutlet weak var radarView: RadarChartView!
    @IBOutlet weak var barView: BarChartView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var exportButton: UIButton!
    
    
    weak var reportDelegate: ReportDelegate?
    var radarArray: [String] = []
    
    //Mark: data prepare
    fileprivate func dataClear() {
        totalScores.removeAll()
        dateArray.removeAll()
        scoreArray.removeAll()
        radarView.clear()
        //set bar chart
        barView.clear()
        lineView.isHidden = true
        //set line chart
        lineView.clear()
        dateLabel.text = ""
    }
    
    fileprivate func dataSetting() {
        switch Settings.questionSet {
        case "phq9":
            PHQ9.fetchData(currentUser,numberOfFetch ?? 0)
            flag = PHQ9.flag
            radarArray = QuestionBank().radarArray
            if PHQ9.count == 0 {
                dataClear()
                
            }else {
                //set vars for receiving data
                if isDataSentFromRecordsMenu == false || numberOfFetch != nil {
                    totalScores = PHQ9.totalArray
                    dateArray = PHQ9.dateArray
                    scoreArray = PHQ9.scoresArray
                    results = PHQ9.resultArray
                }

            }
        case "gad7":
            GAD7.fetchData(currentUser,numberOfFetch ?? 0)
            flag = GAD7.flag
            radarArray = QuestionBank().radarArray
            if GAD7.count == 0 {
                dataClear()
                
            }else {
                if isDataSentFromRecordsMenu == false || numberOfFetch != nil {
                    //set vars for receiving data
                    totalScores = GAD7.totalArray
                    dateArray = GAD7.dateArray
                    scoreArray = GAD7.scoresArray
                    results = GAD7.resultArray
                }
            }
        default:
            break
        }

            //set radar chart
            if isDataSentFromRecordsMenu == false && totalScores.count > 0 {
                dateLabel.text = " Your Score:".localized + String(totalScores[totalScores.count - 1])
                radarView.setRadarData(radarArray, scoreArray[totalScores.count - 1], Settings.questionSet)
            }
            //set bar chart
            barView.setBarChartData(xValues: dateArray, yValues: totalScores, label: "Scores Records")
            lineView.isHidden = true
            barView.isHidden = false
            if totalScores.count > 3 {
                barView.legend.enabled = false
            } else {
                barView.legend.enabled = true
            }
            
            //long press gesture
            let longPressgesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetected(gesture:)))
            longPressgesture.allowableMovement = 20
            barView.addGestureRecognizer(longPressgesture)
            
            //set line chart
            lineView.setLineChartData(xValues: dateArray, yValues: totalScores, label: "Scores Records")
            
            //create a interactive chart delegate
            self.barView.delegate = self
            self.radarView.delegate = self
        
        if numberOfFetch == nil {
            numberOfFetch = 0
        }
    }
    
    fileprivate func setBackGroundImage() {
        if let bgImageView = view.viewWithTag(100) {
            bgImageView.removeFromSuperview()
            print("remove success")
        }
        if let backGroundImage = Settings.bgImage {
            let bgImageView = UIImageView(frame: view.frame)
            bgImageView.tag = 100
            bgImageView.image = backGroundImage
            bgImageView.contentMode = .scaleAspectFill
            view.addSubview(bgImageView)
            bgImageView.translatesAutoresizingMaskIntoConstraints = false
            let views = ["view": bgImageView]
            let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", metrics: nil, views: views)
            let vConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", metrics: nil, views: views)
            let allConstraints = hConstraint + vConstraint
            NSLayoutConstraint.activate(allConstraints)
            view.sendSubviewToBack(bgImageView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackGroundImage()
        let userVC = tabBarController?.viewControllers?[0] as! UserViewController
        currentUser = userVC.currentUser

        menuView.isHidden = true
        //create a instance of dataStored and fetch data from coredata
        dataSetting()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        isDataSentFromRecordsMenu = false
        scoreArrayNum = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.isHidden = true
        pageNum.text = Int(Settings.fetchLimit).description
        //Mark:add swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {

        if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            saveImage()
            tabBarController?.selectedIndex = 3
        }
    }
    
    //Mark: prepare segue for menuView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MenuViewController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
            destinationViewController.menuActionDelegate = self
            destinationViewController.currentUser = currentUser
        }
    }
    //MARK: save images for reportVC
    func saveImage() {
        if !dateArray.isEmpty {
        if lineView.isHidden == true{
            let _ = barView.save(to: "\(NSTemporaryDirectory())/image002.png", format: ChartViewBase.ImageFormat.png, compressionQuality: 1.0)
            print("barchart was saved")
        }else{
            let _ = lineView.save(to: "\(NSTemporaryDirectory())/image002.png", format: ChartViewBase.ImageFormat.png, compressionQuality: 1.0)
            print("linechart was saved")

        }
        
        let _ = radarView.save(to: "\(NSTemporaryDirectory())/image001.png", format: ChartViewBase.ImageFormat.png, compressionQuality: 1.0)
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindSegueToTest", sender: self)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        menuView.isHidden = !menuView.isHidden
    }
    
    
    //Go to reportView
    @IBAction func goToReportView(_ sender: Any) {
        tabBarController?.selectedIndex = 3

    }
    
    
    //Mark: save to csv file
    @IBAction func saveCsv(_ sender: Any) {
        saveCsv()
    }

    //Mark: buttons for radarchart
    @IBAction func prevButton(_ sender: UIButton) {
        if scoreArrayNum == nil {
            scoreArrayNum = scoreArray.count - 1
        }
        if let num = scoreArrayNum, num > 0 && num < dateArray.count{
            scoreArrayNum! -= 1
            radarView.setRadarData(radarArray, scoreArray[scoreArrayNum!], Settings.questionSet)
            nextButton.isHidden = false
            dateLabel.text = "\(dateArray[scoreArrayNum!])" + " Score:" + "\(totalScores[scoreArrayNum!])"

        }else{
            prevButton.isHidden = true
            nextButton.isHidden = false
        }
        
    }
    
    
    @IBAction func nextButton(_ sender: UIButton) {
        if let num = scoreArrayNum, num < scoreArray.count - 1 {
            scoreArrayNum! += 1
            radarView.setRadarData(radarArray, scoreArray[scoreArrayNum!], Settings.questionSet)
            prevButton.isHidden = false
            dateLabel.text = "\(dateArray[scoreArrayNum!]) Score:\(totalScores[scoreArrayNum!])"
        }
        else {
            nextButton.isHidden = true
            prevButton.isHidden = false
            
        }
    }
    
    //buttons for barchart
    @IBAction func lastViewButton(_ sender: UIButton) {
        // if data.count < 25
        
        if flag == false {
            last25.isHidden = true
            next25.isHidden = false
        }else {
            numberOfFetch! += 1
            dataSetting()
            next25.isHidden = false
        }
    }
    
    @IBAction func nextViewButton(_ sender: UIButton) {
        if numberOfFetch! >= 1 {
            numberOfFetch! -= 1
            last25.isHidden = false
            next25.isHidden = false
            dataSetting()
        }
        else {
//            dataSetting()
            next25.isHidden = true
            last25.isHidden = false
        }
        
    }
    
    @IBAction func switchButton(_ sender: UISegmentedControl) {
        switch segControl.selectedSegmentIndex{
        case 0:
            lineView.isHidden = true
            barView.isHidden = false
        case 1:
            barView.isHidden = true
            lineView.isHidden = false
            
        default:
            break;
        }
        saveImage()
    }
    
    @IBAction func numControlHidden(_ sender: UIButton) {
        stepper.isHidden = !stepper.isHidden
    }
    @IBOutlet weak var pageNum: UILabel!
    @IBAction func numberControl(_ sender: UIStepper) {
        pageNum.text = Int(sender.value).description
        Settings.fetchLimit = Int(sender.value)
        dataSetting()
    }
    
    
    // add long press gesture
@objc func longPressDetected(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.barView)
            let h = self.barView.getHighlightByTouchPoint(point)
            self.barView.highlightValue(x: (h?.x)!, dataSetIndex: (h?.dataSetIndex)!, stackIndex: (h?.stackIndex)!)
            if let xVal = h?.x {
            //create a instance of dataStored and fetch data from coredata
                let alert = UIAlertController(title: "⚠️"+"Delete Data".localized, message: "Warning! Data cannot be recovered after delete.".localized, preferredStyle: .alert)

                switch Settings.questionSet {
                case "phq9":
                    alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler:{(UIAlertAction) in PHQ9.deleteData(self.currentUser, self.numberOfFetch!, Int(xVal))
                        self.dataSetting()
                    } ))
                case "gad7":
                    alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler:{(UIAlertAction) in GAD7.deleteData(self.currentUser, self.numberOfFetch!, Int(xVal))
                        self.dataSetting()} ))
                default: break

                }
                
                alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler:nil))
                self.present(alert, animated: true, completion: nil)
                
            }
    }
}
    
    // User delegate
    func passResult(user :String) {
        currentUser = user        
    }
    
    //MARK: ChartViewDelegate
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("chartValueSelected y=\(entry.y) x=\(entry.x)")

        scoreArrayNum = Int(entry.x)
        if let num = scoreArrayNum {
            scores = scoreArray[num]
            radarView.setRadarData(radarArray, scores, Settings.questionSet)
            date = dateArray[num]
            totalScore = totalScores[num]
            dateLabel.text = "\(date)"+" Your Score:".localized+"\(totalScore)"
            saveImage()

        }

        
        //add notificationCenter
//        NotificationCenter.default.post(name: NSNotification.Name("passData"), object: self)
    }
}

extension LineChartView {

    private class LineChartFormatter: NSObject, IAxisValueFormatter {

        var labels: [String] = []

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if Int(value) >= 0 && Int(value) < labels.count {
                return labels[Int(value)]
            }else {
                return ""
            }
        }

        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    

    func setLineChartData(xValues: [String], yValues: [Int], label: String) {
        var dataEntries: [ChartDataEntry] = []
        var colorArray = [UIColor]()
        for i in 0..<yValues.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(yValues[i]))
            dataEntries.append(dataEntry)
            colorArray.append(Settings.setColor(yValues[i]))

        }

        let chartDataSet = LineChartDataSet(entries: dataEntries, label: label)
        chartDataSet.circleHoleRadius = 0
        chartDataSet.circleRadius = 6
        chartDataSet.circleColors = colorArray
        let chartData = LineChartData(dataSet: chartDataSet)
        //to format xAxis
        let chartFormatter = LineChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        //to format yAxis
        let yAxis = self.leftAxis
        yAxis.granularityEnabled = true
        yAxis.granularity = 1
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = Double(QuestionBank().questionArray.count * 3 + 1)
        yAxis.valueFormatter = MyCustomAxisValueFormatter()
        self.rightAxis.enabled = false
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter)
        self.chartDescription?.text = ""
        var entries: [LegendEntry] = []
        for index in QuestionBank().severityArray.indices {
            let entry = LegendEntry.init(label: QuestionBank().severityArray[index], form: Legend.Form.circle, formSize: 5, formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: QuestionBank.severityColors[index])
            entries.append(entry)
        }
        legend.setCustom(entries: entries)
        self.data = chartData
    }
}

extension BarChartView {

    private class BarChartFormatter: NSObject, IAxisValueFormatter {

        var labels: [String] = []

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if Int(value) >= 0 && Int(value) < labels.count {
                return labels[Int(value)]
            }else {
                return ""
            }
        }

        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }

    func setBarChartData(xValues: [String], yValues: [Int], label: String) {
        var dataEntries: [BarChartDataEntry] = []
        var colorArray = [UIColor]()
        for i in 0..<yValues.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(yValues[i]))
            dataEntries.append(dataEntry)
            colorArray.append(Settings.setColor(yValues[i]))
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: label)
        chartDataSet.colors = colorArray
        let chartData = BarChartData(dataSet: chartDataSet)
        //to format xAxis
        let chartFormatter = BarChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        //to format yAxis
        let yAxis = self.leftAxis
        yAxis.granularityEnabled = true
        yAxis.granularity = 1
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = Double(QuestionBank().questionArray.count * 3 + 1)
        yAxis.valueFormatter = MyCustomAxisValueFormatter()
        self.rightAxis.enabled = false
        
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter)
        var entries: [LegendEntry] = []
        for index in QuestionBank().severityArray.indices {
            let entry = LegendEntry.init(label: QuestionBank().severityArray[QuestionBank().severityArray.count - index - 1], form: Legend.Form.square, formSize: 5, formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: QuestionBank.severityColors[QuestionBank.severityColors.count - index - 1])
            entries.append(entry)
        }

        legend.setCustom(entries: entries)
        legend.drawInside = true
        legend.verticalAlignment = .bottom
        legend.horizontalAlignment = .right
        legend.orientation = .vertical
        legend.textColor = UIColor(white: 0.1, alpha: 0.5)

        //set barView
        self.chartDescription?.text = ""
        self.animate(xAxisDuration: 1, yAxisDuration: 0.1)
        self.data = chartData
        self.setVisibleXRangeMinimum(5.0)
        self.xAxis.granularityEnabled = true
        
    }


    
}



extension RadarChartView {

    private class RadarChartFormatter: NSObject, IAxisValueFormatter {

        var labels: [String] = []

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let index = Int(value)
            if index < labels.count && index >= 0 {
                return labels[index]
            } else {
                return ""
                
            }
        }
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }

    
    func setRadarData(_ xValues: [String],_ yValues: [Int],_ label: String) {

        var dataEntries: [RadarChartDataEntry] = Array()
        var totalScore = 0
        for i in 0...yValues.count - 1 {
            let dataEntry = RadarChartDataEntry(value: Double(yValues[i]))
            dataEntries.append(dataEntry)
        }
        for i in 0...yValues.count - 2 {
            totalScore += yValues[i]
        }
        
        let chartDataSet = RadarChartDataSet(entries: dataEntries, label: label)
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = Settings.setColor(totalScore)
        chartDataSet.drawValuesEnabled = false
        let chartData = RadarChartData(dataSet: chartDataSet)


        let chartFormatter = RadarChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.chartDescription?.text = ""
        self.yAxis.axisMinimum = 0
        self.yAxis.axisMaximum = 2
        self.yAxis.granularityEnabled = true
        self.yAxis.granularity = 1
        self.legend.enabled = false
        self.yAxis.gridAntialiasEnabled = true
        self.animate(xAxisDuration: 1, yAxisDuration: 0.2)
        self.data = chartData
    }
}

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    
    func reopenMenu()
}

extension ResultViewController {
    
    @IBAction func openMenu(_ sender: AnyObject) {
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    @IBAction func edgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .right)
        
        MenuHelper.mapGestureStateToInteractor(
            sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "openMenu", sender: nil)
        }
    }
    
    
}

extension ResultViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension ResultViewController : MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: true){
            self.performSegue(withIdentifier: segueName, sender: sender)
        }
    }
    func reopenMenu(){
        performSegue(withIdentifier: "openMenu", sender: nil)
    }
}

extension ResultViewController {
    func  saveCsv() {
        let dateSave = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: dateSave)
        var str = ""
        print(totalScores.count)
        
        //load data to string
        for i in 0..<totalScores.count {
            let date = dateArray[i]
            
            str.append("name: \(currentUser),date:\(date)\n")
            var n = 0
            for score in scoreArray[i] {
                str.append("question\(n+1),\(score)\n")
                n = n + 1
            }
            str.append("total,\(totalScores[i])\n\n")
        }
        
        let fileName = "\(dateString).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        //write data using string.write
        
        do {
            try str.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
            if let popOver = vc.popoverPresentationController {
                popOver.sourceView = self.view
                popOver.barButtonItem = navigationItem.rightBarButtonItem
                //popOver.sourceRect =
                //popOver.barButtonItem
            }
        } catch {
            print(error)
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
}
