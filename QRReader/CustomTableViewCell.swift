//
//  CustomTableViewCell.swift
//  QRReader
//
//  Created by Artem Misesin on 5/5/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var priceTagLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
