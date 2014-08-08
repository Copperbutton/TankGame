//
//  Defender.h
//  TankGame
//
//  Created by ZhangXiaokang on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Defender : CCSprite

@property (nonatomic) NSString* tankType;

//Level of defence
@property (nonatomic, assign) int defense;


@end
