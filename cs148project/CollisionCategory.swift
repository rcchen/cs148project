//
//  CollisionCategory.swift
//  cs148project
//
//  Created by Roger Chen on 8/14/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let Ball = CollisionCategory(rawValue: 1 << 0)
    static let Basket = CollisionCategory(rawValue: 1 << 1)
    
//    static let Ball = CollisionCategory(rawValue: -1)
//    static let Basket = CollisionCategory(rawValue: -1)
}
