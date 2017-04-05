//
//  MyReactionsCell.swift
//  React it
//
//  Created by Marco Cruz on 03/02/2017.
//  Copyright © 2017 Marco Cruz. All rights reserved.
//

import UIKit

class MyReactionsCell: UITableViewCell {

    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var reaction: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
