//
//  Level1.m
//  TankGame
//
//  Created by ZhangXiaokang on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level1.h"
#import "Defender.h"

@implementation Level1{
    //Physical Node
    CCPhysicsNode *_physicsNode;
    CCSprite* _intruder1;
    CCSprite* _intruder2;
    CCSprite* _intruder3;
    CCSprite* _intruder4;
    CCSprite* _intruder5;
    CCSprite* _intruder6;
}
- (void) didLoadFromCCB {
    CCLOG(@"LOAD LEVEL 1 SUCCESS!!!!!");
    self._defender = [CCBReader load:@"Defender"];
    ((Defender *)self._defender).defense = 5;
    self._defender.position = ccpAdd(_physicsNode.position,ccp(160, 20));
    [_physicsNode addChild:self._defender];
}

@end
