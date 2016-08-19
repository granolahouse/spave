//
//  SpendingsTableViewCell.swift
//  spave
//
//  Created by Dominik Faber on 19.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit

class SpendingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var expense: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}