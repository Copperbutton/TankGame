//
//  IntruderBullet.h
//  TankGame
//
//  Created by ZhangXiaokang on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface IntruderBullet : CCSprite

//Owner of bulelt, so that from same owner wont harm them self
@property (nonatomic, assign) int owner;

@end
