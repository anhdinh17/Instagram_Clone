//
//  Extensions.swift
//  Instagram
//
//  Created by Anh Dinh on 4/14/21.
//

import Foundation
import UIKit

extension UIView {
    var top: CGFloat{
        frame.origin.y
    }
    
    var bottom: CGFloat{
        frame.origin.y + height
    }
    
    var left: CGFloat{
        frame.origin.x
    }
    
    var right: CGFloat{
        frame.origin.x + width
    }
    
    var width: CGFloat{
        frame.size.width
    }
    
    var height: CGFloat{
        frame.size.height
    }
}
