//
//  IntruderBullet.m
//  TankGame
//
//  Created by ZhangXiaokang on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "IntruderBullet.h"

@implementation IntruderBullet

//Bullet should have different apperance
- (id)init {
    self = [super init];
    
    if (self) {
        CCLOG(@"Intruder Bullet created");
    }
    
    return self;
}

//Collision type
- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"intruderBulletCollision";
}

@end
