//
//  CardTableCell.swift
//  FinalProject
//
//  Created by Student on 12/14/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class CardTableCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var flavorText: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
