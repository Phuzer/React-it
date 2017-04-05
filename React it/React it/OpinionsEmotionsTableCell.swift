//
//  OpinionsTableCell.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 14/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit

class OpinionsEmotionsTableCell: UITableViewCell {

    @IBOutlet weak var viewAvatar: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelOpinionEmotion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
