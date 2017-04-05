//
//  MomentsTableCell.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 09/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit

class MomentsTableCell: UITableViewCell {

    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var labelMoments: UILabel!
    @IBOutlet weak var labelAuthor: UILabel!
    @IBOutlet weak var imgViewThumbnail: UIImageView!
    @IBOutlet weak var imgViewFriends: UIImageView!
    @IBOutlet weak var imgViewGlobal: UIImageView!
    @IBOutlet weak var friendsReactions: UILabel!
    @IBOutlet weak var globalReactions: UILabel!
    @IBOutlet weak var trending: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
