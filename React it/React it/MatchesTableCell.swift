//
//  MatchesTableCell.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 09/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit

class MatchesTableCell: UITableViewCell {

    @IBOutlet weak var notificationNumber: UILabel!
    @IBOutlet weak var labelTeams: UILabel!
    @IBOutlet weak var labelMoments: UILabel!
    @IBOutlet weak var labelGameStatus: UILabel!
    @IBOutlet weak var imgViewHomeTeam: UIImageView!
    @IBOutlet weak var imgViewVisitorTeam: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
