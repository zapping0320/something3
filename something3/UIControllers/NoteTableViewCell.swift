//
//  NoteTableViewCell.swift
//  something3
//
//  Created by 김동현 on 30/01/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelAlarm: UILabel!
    @IBOutlet weak var labelContent: UILabel!
    @IBOutlet weak var labelDate: UILabel!
}
