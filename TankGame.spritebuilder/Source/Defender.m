//
//  Defender.m
//  TankGame
//
//  Created by ZhangXiaokang on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Defender.h"

@implementation Defender
- (id)init {
    self = [super init];
    
    if (self) {
        CCLOG(@"Defender created");
    }
    
    return self;
}

// Collision type
- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"defenderCollision";
    
    //Get custom properties from ccb file, and load different defense
    if ([self.tankType isEqualToString: @"small"]){
        self.defense = 2;
        
    } else if ([self.tankType isEqualToString: @"medium"]) {
        self.defense = 4;
    
    } else if ([self.tankType isEqualToString: @"large"]) {
        self.defense = 6;
    
    }
}

@end
