//
//  ItemCell.swift
//  DoIt
//
//  Created by Florian Van Den Berghe on 06/04/2018.
//  Copyright © 2018 iem. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var itemChecked: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemCategory: UILabel!
    @IBOutlet weak var itemDate: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
}
