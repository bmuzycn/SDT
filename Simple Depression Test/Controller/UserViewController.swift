//
//  UserViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/16/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData
class UserViewController: UIViewController, UITextFieldDelegate{
   
    var currentUser = ""
    var name: String?
    var users = [String]()
    var usersArray: [String] = ["default".localized]
//    weak var userDelegate: UserDelegate?
    weak var dataDelegate: DataDelegate?
    var isNewUser = false

    
    @IBAction func unwindSegueToUserView(unwindSegue: UIStoryboardSegue) {
        print("Welcome back to userView")
    }



    @IBOutlet weak var gestureImage: UIImageView!
    @IBOutlet weak var userID: UITextField!
    @IBOutlet weak var usersView: UIPickerView! 
    override func viewDidLoad() {
        super.viewDidLoad()

        //add swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        userID.clearButtonMode = .whileEditing
    }
    
    fileprivate func setBackGroundImage() {
        if let bgImageView = view.viewWithTag(100) {
            bgImageView.removeFromSuperview()
            print("remove success")
        }
        if let backGroundImage = Settings.bgImage {
            let bgImageView = UIImageView(frame: view.frame)
            bgImageView.image = backGroundImage
            bgImageView.contentMode = .scaleAspectFill
            bgImageView.tag = 100
            view.addSubview(bgImageView)
            bgImageView.translatesAutoresizingMaskIntoConstraints = false
            let views = ["view": bgImageView]
            let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", metrics: nil, views: views)
            let vConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", metrics: nil, views: views)
            let allConstraints = hConstraint + vConstraint
            NSLayoutConstraint.activate(allConstraints)
            view.sendSubviewToBack(bgImageView)
            bgImageView.setNeedsDisplay()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = Settings.bgColorForTextField
        setBackGroundImage()
        dataUpdate()
        userID.placeholder = "Enter a username".localized
    }
    
    func dataUpdate() {
        //fetch data from CoreData
        fetchUsers()
        if !users.isEmpty{
            usersArray = users
        }
        //load pickerView
        usersView.dataSource = self
        usersView.delegate = self
        userID.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stopAnimation))
        view.addGestureRecognizer(tapGesture)
    }
    
    //add swipe gestures
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            goChartView()
//            performSegue(withIdentifier: "unwindSegueToResultView", sender: nil)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            goQuestionView()

        }
    }
    
    //add start animation for gesture guide
    private func startAnimation() {
        var times: Int?
        let timesToDisapear = 5
        let userKey = "timeOfUse"
        UserDefaults.standard.object(forKey: userKey)
        times = UserDefaults.standard.integer(forKey: userKey)
        if times == nil || times! < timesToDisapear {
            gestureImage.image = UIImage(named: "swipe")
            UIView.transition(with: gestureImage, duration: 0.5, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                self.gestureImage.alpha = 0.1
            })
            if times == nil {times = 1} else {times = times! + 1}
            UserDefaults.standard.setValue(times!, forKey: userKey)
            print("time of use \(UserDefaults.standard.integer(forKey: userKey))")
        } else {
            self.gestureImage.isHidden = true
        }
    }
    
    //stop animation
    @objc func stopAnimation() {
        self.gestureImage.isHidden = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultViewController
        {
            let vc = segue.destination as? ResultViewController
            dataDelegate = vc
            dataDelegate?.passResult(user: currentUser)
        }else if segue.destination is QuestionViewController {
            let vc = segue.destination as? QuestionViewController
            dataDelegate = vc
            dataDelegate?.passResult(user: currentUser)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newUserButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "New User".localized, message: "Enter a name".localized, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter a username".localized
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (finished) in
            let textField = alert.textFields![0]// Force unwrapping because we know it exists.
            self.userID.text = textField.text
            self.saveNewUser()
            if self.isNewUser {
            self.goQuestionView()
            }
            }))
        if let presented = self.presentedViewController {
            presented.removeFromParent()
        }
        if presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
        //        self.present(alert, animated: true, completion: nil)
    }
    
 
    @IBAction func addUser(_ sender: UIButton) {
        saveNewUser()
        fetchUsers()
        if !users.isEmpty{
            usersArray = users
        }
        dataUpdate()
        findUserName()
    }
    
    func findUserName() {
        for index in users.indices {
            if userID.text == users[index] {
                usersView.selectRow(index, inComponent: 0, animated: true)
            }
            
        }
    }
    
    func saveNewUser() {
        for index in users.indices {
            if userID.text == users[index] {
                userID.text = ""
                isNewUser = false
                let alert = UIAlertController(title: "Note".localized, message: "User exists!".localized, preferredStyle: .alert)
                if let presented = self.presentedViewController {
                    presented.removeFromParent()
                }
                if presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                }
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
                usersView.selectRow(index, inComponent: 0, animated: true)
                break
            }
            
        }
        if userID.text != "" {
            currentUser = userID.text!
            let context = AppDelegate.viewContext
            let newUser = User(context: context)
            newUser.fetchUser(user: currentUser)
            if newUser.userflag == true {
                isNewUser = false

                let alert = UIAlertController(title: "Note".localized, message: "User exists!".localized, preferredStyle: .alert)
                if let presented = self.presentedViewController {
                    presented.removeFromParent()
                }
                if presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                }
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
            }else {
            isNewUser = true
            newUser.userID = currentUser

            do{
                try context.save()
                print("\(currentUser) saved")
                
            }catch let error as NSError {
                print("Could not save. \(error),\(error.userInfo)")
            }
            }
        }
            
        else {
            let alert = UIAlertController(title: "Note".localized, message: "Please input a user name".localized, preferredStyle: .alert)
            if let presented = self.presentedViewController {
                presented.removeFromParent()
            }
            if presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
            isNewUser = false

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
        }
    }
    
    @IBAction func selectButton(_ sender: Any) {
        goQuestionView()
    }

    @IBAction func deleteButton(_ sender: Any) {
        let alert = UIAlertController(title: "⚠️"+"Delete User".localized + ": \(currentUser)", message: "Warning! All the records under this user will be deleted.".localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler:{[unowned self](UIAlertAction) in self.deleteUser()} ))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteUser() {
        let context = AppDelegate.viewContext
        let user = User(context: context)
        user.deleteUsers(currentUser, context)
        print("deleted")
        dataUpdate()
    }
    
    func goChartView() {
        let toView = tabBarController?.viewControllers?[2] as! UINavigationController
        view.superview?.insertSubview(toView.view, at: 1)
        toView.view.transform = CGAffineTransform(translationX: -view.frame.width, y: 0)
        UIView.animate(withDuration: 0.25, delay: TimeInterval(0.0), options: [.curveEaseOut, .preferredFramesPerSecond60], animations: {
            toView.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in
            if finished {
                
                self.tabBarController?.selectedIndex = 2
            }
        })
    }
    
    func goQuestionView() {
        let toView = tabBarController?.viewControllers?[1] as! QuestionViewController
        print("toView.user:\(toView.cUser)")
        view.superview?.insertSubview(toView.view, at: 1)
        toView.view.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
        UIView.animate(withDuration: 0.25, delay: TimeInterval(0.0), options: [.curveEaseOut, .preferredFramesPerSecond60], animations: {
            toView.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion:
            { finished in
            if finished {
//                toView.view.removeFromSuperview()
                self.tabBarController?.selectedIndex = 1
            }
        }
        )
        
//        performSegue(withIdentifier: "unwindToTest", sender: self)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "questionView") as! ViewController
//        self.present(vc, animated: true)
//
//        //pass currentUser to vc
//        userDelegate = vc
//        userDelegate?.userReady(name: currentUser)
        }
    
    
    func fetchUsers() {
        users.removeAll()
        let managedContext = AppDelegate.viewContext
        let fetchRequest: NSFetchRequest = User.fetchRequest()
        let sortbyName = NSSortDescriptor(key: "userID", ascending: true)
        fetchRequest.sortDescriptors = [sortbyName]
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest)
            print(fetchedResults.count)
            if fetchedResults.count > 0{
                for item in fetchedResults {
                    if item.value(forKey: "userID") != nil {
                    users.append(item.value(forKey: "userID") as! String)
                }
                }
            }
            
        }catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
    }

    var keyboardHeight: CGFloat = 0.0
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        animateViewMoving(up: true, moveValue: 120)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 120)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
//        self.view.frame.offsetBy(dx:0, dy:movement)
        self.view.frame = self.view.frame.offsetBy(dx:0, dy:movement)
        UIView.commitAnimations()
    }
    
 
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        userID.resignFirstResponder()
        //or
        //self.view.endEditing(true)
        saveNewUser()
        dataUpdate()
        findUserName()
        return true
    }
}

extension UserViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in usersView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        currentUser = usersArray[row]
        var color: UIColor
        if pickerView.selectedRow(inComponent: component) == row {
            color = #colorLiteral(red: 0, green: 0.3225687146, blue: 1, alpha: 1)
        } else {
            color = UIColor.darkText
        }
        
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        return NSAttributedString(string: currentUser, attributes: attributes)
    }
    

    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return usersArray.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        currentUser = usersArray[row]
//
//        return usersArray[row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentUser = usersArray[row]
        pickerView.reloadAllComponents()
    }
}
