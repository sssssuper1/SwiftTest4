//
//  PeripheralCell.swift
//  ZrySwiftTest4
//
//  Created by Edison on 2018/8/3.
//  Copyright © 2018年 Edison. All rights reserved.
//

import UIKit

class PeripheralCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var uuid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
