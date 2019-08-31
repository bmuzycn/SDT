//
//  SettingViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 1/14/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import UIKit

class DisplaySettingViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var fontSize: UISlider!
    @IBOutlet weak var themesLabel: UILabel!
    @IBOutlet weak var fontColorLabel: UILabel!
    @IBOutlet weak var bgColorlabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontSize.minimumValue = 12
        fontSize.maximumValue = 50
        updateAppearance()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentFontSize = UserDefaults.standard.value(forKey: "FontSize") {
            fontSize.setValue(currentFontSize as! Float, animated: false)
        }
    }
    
    func updateAppearance() {
        setBackGroundImage()
        textLabel.textColor = Settings.textColor
        themesLabel.textColor = Settings.textColor
        fontColorLabel.textColor = Settings.textColor
        bgColorlabel.textColor = Settings.textColor
        fontSizeLabel.textColor = Settings.textColor
        view.backgroundColor = Settings.bgColorForTextField
        view.setNeedsDisplay()
    }
    
    @IBAction func fontSizeSlider(_ sender: UISlider) {
        Settings.textFont = UIFont.systemFont(ofSize: CGFloat(sender.value))
        textLabel.font = Settings.textFont
        textLabel.textAlignment = .center
        textLabel.setNeedsDisplay()
        UserDefaults.standard.set(sender.value, forKey: "FontSize")
    }
    
    @IBAction func minimalistButton(_ sender: Any) {
        Settings.textColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        Settings.colorForHeadView = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        Settings.bgColorForMenuView = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        Settings.bgColorForTableView = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        Settings.bgColorForTextField = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        Settings.bgImage = UIImage(named: "minimalist")
        updateAppearance()
    }
    
    @IBAction func casualButton(_ sender: Any) {
        Settings.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        Settings.bgColorForMenuView = #colorLiteral(red: 0.01124551333, green: 0.1593088508, blue: 0.8386157155, alpha: 0.9)
        Settings.colorForHeadView = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 0.85)
        Settings.bgColorForTableView = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        Settings.bgColorForTextField = #colorLiteral(red: 0.003229425987, green: 0.07242881507, blue: 0.4763471484, alpha: 1)
        Settings.bgImage = UIImage(named: "casual")
        updateAppearance()
    }
    
    @IBAction func retroButton(_ sender: Any) {
        Settings.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        Settings.bgColorForMenuView = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 0.9)
        Settings.colorForHeadView = #colorLiteral(red: 0.6352941176, green: 0.5176470588, blue: 0.368627451, alpha: 1)
        Settings.bgColorForTableView = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        Settings.bgColorForTextField = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        Settings.bgImage = UIImage(named: "retro")
        updateAppearance()
    }
    
    @IBAction func springButton(_ sender: Any) {
        Settings.textColor = #colorLiteral(red: 0.2854510391, green: 0.0003517432249, blue: 0.249270095, alpha: 1)
        Settings.bgColorForMenuView = #colorLiteral(red: 0, green: 0.9768045545, blue: 0.7691109625, alpha: 0.8)
        Settings.colorForHeadView = #colorLiteral(red: 0.007898898743, green: 0.8235294223, blue: 0.5207733696, alpha: 1)
        Settings.bgColorForTableView = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        Settings.bgColorForTextField = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        Settings.bgImage = UIImage(named: "spring")
        updateAppearance()
    }
    
    @IBAction func warmButton(_ sender: Any) {
        Settings.textColor = #colorLiteral(red: 0, green: 0.1780764182, blue: 0.3107971328, alpha: 1)
        Settings.bgColorForMenuView = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 0.9)
        Settings.colorForHeadView = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        Settings.bgColorForTableView = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        Settings.bgColorForTextField = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        Settings.bgImage = UIImage(named: "warm")
        updateAppearance()
    }
    
    @IBAction func pinkButton(_ sender: Any) {
        Settings.textColor = #colorLiteral(red: 0, green: 0.2054565439, blue: 0.1160986162, alpha: 1)
        Settings.bgColorForMenuView = #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 0.9)
        Settings.colorForHeadView = #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)
        Settings.bgColorForTableView = #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)
        Settings.bgColorForTextField = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        Settings.bgImage = UIImage(named: "pink")
        updateAppearance()
    }
    
    @IBAction func fontColorButtons(_ sender: UIButton) {
        let colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)]
        if 0...4 ~= sender.tag {
            buttonAnimation(sender)
            Settings.textColor = colors[sender.tag]
            updateAppearance()
        }
    }
    
    @IBAction func bgColorButtons(_ sender: UIButton) {
        let colors = [#colorLiteral(red: 0.9117823243, green: 0.9118037224, blue: 0.9117922187, alpha: 1),#colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1),#colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1),#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1),#colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1)]
        if 0...4 ~= sender.tag {
            buttonAnimation(sender)
            Settings.bgColorForTextField = colors[sender.tag]
            updateAppearance()
            if let bgImageView = view.viewWithTag(100) {
                bgImageView.removeFromSuperview()
            }
        }
    }
    
    func buttonAnimation(_ sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
