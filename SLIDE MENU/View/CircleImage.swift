//
//  CircleImage.swift
//  SLIDE MENU
//
//  Created by Mac on 9/25/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
@IBDesignable
class CircleImage: UIImageView {
    
    override func awakeFromNib() {
        setupView()
    }
    func setupView()  {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    override func prepareForInterfaceBuilder() {
        setupView()
    }
}
