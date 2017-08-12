//
//  CGPoint+Extensions.swift
//  cs148project
//
//  Subset of the following source
//  https://github.com/raywenderlich/SKTUtils/blob/master/SKTUtils/CGPoint%2BExtensions.swift
//
//  Created by Roger Chen on 8/12/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import CoreGraphics
import Foundation

public extension CGPoint {

    /**
     * Returns the length (magnitude) of the vector described by the CGPoint.
     */
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    /**
     * Normalizes the vector described by the CGPoint to length 1.0 and returns
     * the result as a new CGPoint.
     */
    func normalized() -> CGPoint {
        let len = length()
        return len>0 ? self / len : CGPoint.zero
    }
    
}

/**
 * Divides the x and y fields of a CGPoint by the same scalar value and returns
 * the result as a new CGPoint.
 */
public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
