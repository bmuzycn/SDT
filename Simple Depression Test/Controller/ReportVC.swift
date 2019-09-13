//
//  ReportVC.swift
//  testExport
//
//  Created by Yu Zhang on 9/4/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import WebKit
import CoreData
import MessageUI

protocol ReportDelegate: AnyObject {
    func passResult(user: String, scores: [Int], total: Int, result: String, date: String)
    }
class ReportVC: UIViewController, WKNavigationDelegate, MFMailComposeViewControllerDelegate{
    var scores = [Int]()
    var total = 0
    var date = ""
    var result = ""
    var str = ""
    var user = ""
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var loadSpinner: UIActivityIndicatorView!
    @IBOutlet weak var webViewContainer: UIView!
    var reportView: WKWebView!
    weak var dataDelegate: DataDelegate?
    var reportComposer: ReportComposer!
    var htmlReport = ""
    
    let progressLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
        label.textColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        return label
    }()
    
    @IBAction func unwindSegueToReport(unwindSegue: UIStoryboardSegue) {
        print("Welcome to report")

            
    }
    // MARK: - show indicator
    func webView(_ reportView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        loadSpinner.startAnimating()
        progressLabel.isHidden = false
    }
    // hide indicator
    func webView(_ reportView: WKWebView, didFinish navigation: WKNavigation!) {
        loadSpinner.stopAnimating()
        loadSpinner.hidesWhenStopped = true
        progressLabel.isHidden = true

//        backButton.isEnabled = reportView.canGoBack
    }
    
    //
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(Float(reportView.estimatedProgress))
            progressLabel.text = String(Int(reportView.estimatedProgress * 100)) + "%"
        }
    }
    
    func receiveData() {
        let navVC = tabBarController?.viewControllers?[2] as! UINavigationController
        let chartVC = navVC.viewControllers[0] as! ResultViewController
        if !chartVC.dateArray.isEmpty {
            if chartVC.isDataSentFromRecordsMenu{
                chartVC.saveImage()
                self.user = chartVC.currentUser
                self.date = chartVC.date
                self.scores = chartVC.scores
                self.total = chartVC.totalScore
                self.result = chartVC.result
                print("data passed from menuView to reportVC")
            } else {
                chartVC.saveImage()
                self.user = chartVC.currentUser
                let last = chartVC.dateArray.count - 1
                self.date = chartVC.dateArray[chartVC.scoreArrayNum ?? last]
                self.scores = chartVC.scoreArray[chartVC.scoreArrayNum ?? last]
                self.total = chartVC.totalScores[chartVC.scoreArrayNum ?? last]
                self.result = chartVC.results[chartVC.scoreArrayNum ?? last]
                print("data passed from chartView to reportVC")
            }
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
    
    fileprivate func setupReportView() {
        //load reportView
        let webConfiguration = WKWebViewConfiguration()
        
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webViewContainer.frame.size.height))
        self.reportView = WKWebView (frame: customFrame , configuration: webConfiguration)
        reportView.translatesAutoresizingMaskIntoConstraints = false
        self.webViewContainer.addSubview(reportView)
        reportView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        reportView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
        reportView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
        reportView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        reportView.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
        reportComposer = ReportComposer()
        htmlReport = reportComposer.renderReport(name: user, date: date, scores: scores, total: total, result: result)
        let path1 = Bundle.main.path(forResource: AppLanguage.currentAppleLanguageFull(), ofType: "lproj")
        let path2 = Bundle.main.path(forResource: AppLanguage.currentAppleLanguage(), ofType: "lproj")
        let path3 = Bundle.main.path(forResource: "Base", ofType: "lproj")
        let url = URL(fileURLWithPath: path1 ?? path2 ?? path3!)
        reportView.navigationDelegate = self
        reportView.loadHTMLString(htmlReport, baseURL: url)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSpinner.style = .whiteLarge
        loadSpinner.color = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        loadSpinner.startAnimating()

        setBackGroundImage()
        receiveData()
        print("user:\(user)")
        print(date)

        setupReportView()
        reportView.navigationDelegate = self

        reportView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FileManager.default.clearTmpDirectory()
        clearArrays()
        removeCache()
    }
    
    override func loadView() {
        super.loadView()
            view.addSubview(progressLabel)
            progressLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                         progressLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40)])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add swipe gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            performSegue(withIdentifier: "unwindToResultView", sender: self)
        }
    }


    func clearArrays() {
        scores.removeAll()
        total = 0
        date = ""
        result = ""
        str = ""
        user = ""
        print("data was cleared")
    }

    func removeCache() {
        if #available(iOS 9.0, *)
        {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        }
        else
        {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("error")
            }
            URLCache.shared.removeAllCachedResponses()
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultViewController
        {
            removeCache()
        }
    }
    // MARK: - navigation method enable back button
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        if reportView.canGoBack {
            reportView.goBack()
        }
        else {
            reportView.loadHTMLString(htmlReport, baseURL: nil)
        }
    }
    
    @IBAction func saveToPDF(_ sender: Any) {
        reportComposer.createPDF(html: htmlReport, filename: "reportPHQ-9", formatter: reportView.viewPrintFormatter())
        showOptionsAlert()
    }
    
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Hi!".localized, message: "Your report has been successfully printed to a PDF file.\n\nWhat do you want to do now?".localized, preferredStyle: UIAlertController.Style.alert)
        
        let actionSave = UIAlertAction(title: "Save pdf".localized, style: UIAlertAction.Style.default) { (action) in
            if let filename = self.reportComposer.pdfFilename{
                print(filename)
                
                let path = URL(fileURLWithPath: filename)
                
                let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
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
                    self.present(vc, animated: true, completion: nil)
                    if let popOver = vc.popoverPresentationController {
                        popOver.sourceView = self.view
                        //popOver.sourceRect =
                        //popOver.barButtonItem
                    }
                }
            }
        
        let actionEmail = UIAlertAction(title: "Send by Email".localized, style: UIAlertAction.Style.default) { (action) in
            DispatchQueue.main.async {
                self.sendEmail()
            }
        }
        
        let actionNothing = UIAlertAction(title: "Nothing".localized, style: UIAlertAction.Style.default) { (action) in
            
        }
        
        alertController.addAction(actionSave)
        alertController.addAction(actionEmail)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setSubject("report of PHQ-9")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: reportComposer.pdfFilename!)!as Data, mimeType: "application/pdf", fileName: "reportPHQ-9")
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

extension ReportVC: ReportDelegate {
    func passResult(user: String, scores: [Int], total: Int, result: String, date: String) {
        self.user = user
        self.scores = scores
        self.total = total
        self.result = result
        self.date = date
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch {
            print(error)
            //catch the error somehow
        }
    }
}
