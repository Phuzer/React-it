//
//  EmotionView.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 02/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit

protocol EmotionViewDelegate: class {
    func btn1()
    func btn2()
    func btn3()
    func btn4()
    func btn5()
    func btn6()
}

class EmotionView: UIView {
    
    @IBOutlet var view: UIView!
    
    @IBAction func btn1(_ sender: Any) {
        self.delegate?.btn1()
    }
    
    @IBAction func btn2(_ sender: Any) {
        self.delegate?.btn2()
    }
    
    @IBAction func btn3(_ sender: Any) {
        self.delegate?.btn3()
    }
    
    @IBAction func btn4(_ sender: Any) {
        self.delegate?.btn4()
    }
    
    @IBAction func btn5(_ sender: Any) {
        self.delegate?.btn5()
    }
    
    @IBAction func btn6(_ sender: Any) {
        self.delegate?.btn6()
    }
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    
    var delegate:EmotionViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        Bundle.main.loadNibNamed("EmotionView", owner: self, options: nil)
        self.addSubview(self.view)
        
        self.label1.layer.cornerRadius = 37;
        self.label2.layer.cornerRadius = 37;
        self.label3.layer.cornerRadius = 37;
        self.label4.layer.cornerRadius = 37;
        self.label5.layer.cornerRadius = 37;
        self.label6.layer.cornerRadius = 37;
        self.label1.layer.masksToBounds = true;
        self.label2.layer.masksToBounds = true;
        self.label3.layer.masksToBounds = true;
        self.label4.layer.masksToBounds = true;
        self.label5.layer.masksToBounds = true;
        self.label6.layer.masksToBounds = true;
    }
    
}
