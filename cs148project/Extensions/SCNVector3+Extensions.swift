//
//  SCNVector3+Extensions.swift
//  cs148project
//
//  Subset of the following source:
//  https://github.com/devindazzle/SCNVector3Extensions/blob/master/SCNVector3Extensions.swift
//
//  Created by Roger Chen on 8/14/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import SceneKit

public extension SCNVector3 {
    /**
     * Calculates the distance between two SCNVector3. Pythagoras!
     */
    func distance(vector: SCNVector3) -> Float {
        return (self - vector).length()
    }

    /**
     * Returns the length (magnitude) of the vector described by the SCNVector3
     */
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
}

/**
 * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
