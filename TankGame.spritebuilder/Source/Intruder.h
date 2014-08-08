//
//  Intruder.h
//  TankGame
//
//  Created by ZhangXiaokang on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Intruder : CCSprite

//Level of defence
@property (nonatomic, assign) int defense;
@property (atomic, assign) Boolean alive;
@end
