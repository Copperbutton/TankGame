//
//  DefenderBullet.m
//  TankGame
//
//  Created by ZhangXiaokang on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DefenderBullet.h"

@implementation DefenderBullet

//Bullet should have different apperance
- (id)init {
    self = [super init];
    
    if (self) {
        CCLOG(@"Bullet created");
    }
    
    return self;
}

//Collision type
- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"defenderBulletCollision";
}


@end
