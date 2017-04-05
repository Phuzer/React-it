//
//  OpinionView.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 02/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit

protocol OpinionViewDelegate: class {
    func btnThumbsUp()
    func btnThumbsDown()
}

class OpinionView: UIView {

    @IBOutlet weak var btnDown: UIButton!
    @IBOutlet weak var btnUp: UIButton!
    @IBOutlet var view: UIView!
    
    @IBAction func btnThumbsUp(_ sender: Any) {
        self.delegate?.btnThumbsUp()
    }
    
    @IBAction func btnThumbsDown(_ sender: Any) {
        self.delegate?.btnThumbsDown()
    }
    
    var delegate:OpinionViewDelegate?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        Bundle.main.loadNibNamed("OpinionView", owner: self, options: nil)
        self.addSubview(self.view)
        
        self.btnUp.layer.cornerRadius = 35
        self.btnDown.layer.cornerRadius = 35
        self.btnUp.layer.masksToBounds = true;
        self.btnDown.layer.masksToBounds = true;
    }

}
