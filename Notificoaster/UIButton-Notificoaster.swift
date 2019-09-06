//
//  UIButton-Notificoaster.swft.swift
//  Notificoaster
//
//  Created by Scott Hetland on 2019-08-26.
//  Copyright © 2019 Scott Hetland. All rights reserved.
//

import UIKit

extension UIButton
{
    func loginButtonStyling(font: UIFont, height: CGFloat)
    {
        titleLabel?.font = font
        setTitleColor(UIColor.white, for: .normal)
        backgroundColor = UIColor(red: 82/255.0, green: 171/255.0, blue: 203/255.0, alpha: 1.0)
        clipsToBounds = true
        layer.cornerRadius = 0.5 * height
    }
}
