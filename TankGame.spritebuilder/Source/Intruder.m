//
//  Intruder.m
//  TankGame
//
//  Created by ZhangXiaokang on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Intruder.h"

@implementation Intruder
- (id)init {
    self = [super init];
    
    if (self) {
        CCLOG(@"Intruder created");
    }
    
    return self;
}

// Collision type
- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"intruderCollision";
    self.defense = 3;
    self.alive = true;
}

@end
