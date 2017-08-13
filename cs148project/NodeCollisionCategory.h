//
//  NodeCollisionCategory.h
//  cs148project
//
//  Created by Roger Chen on 8/12/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

#ifndef NodeCollisionCategory_h
#define NodeCollisionCategory_h

typedef NS_OPTIONS(NSUInteger, CollisionCategory) {
    CollisionCategoryBall = 1 << 0,
    CollisionCategoryBasket = 1 << 1
};

#endif /* NodeCollisionCategory_h */
