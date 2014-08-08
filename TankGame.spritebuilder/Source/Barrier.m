//
//  Barrier.m
//  TankGame
//
//  Created by ZhangXiaokang on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Barrier.h"

@implementation Barrier

// Collision type
- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"barrierCollision";
}

@end
