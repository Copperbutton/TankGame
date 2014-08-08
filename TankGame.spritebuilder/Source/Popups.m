//
//  Popups.m
//  TankGame
//
//  Created by ZhangXiaokang on 7/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Popups.h"
#import "Gameplay.h"

@implementation Popups

//replay this level, will load current level
- (void)replay_level{
    CCLOG(@"replay_level1");
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    
    NSArray *allChildren = gameplayScene.children;
    for (CCNode * someNode in allChildren)
    {
        if([someNode isKindOfClass:[Gameplay class]])
        {
            [(Gameplay *)someNode loadLevelMap:self.currentLevel];
        }
    }
    
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:transition];
}

//Go to next level, will load next level
- (void)next_Level {
    CCLOG(@"nextLevel_level2");
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay" ];
    
    NSArray *allChildren = gameplayScene.children;
    for (CCNode * someNode in allChildren)
    {
        if([someNode isKindOfClass:[Gameplay class]])
        {
            [(Gameplay *)someNode loadLevelMap:(self.currentLevel + 1)];
        }
    }
    
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:transition];
}

//Back to main scense
- (void) back_main {
    CCScene *mainScense = [CCBReader loadAsScene:@"MainScene"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] replaceScene:mainScense withTransition:transition];
}


//Resume to game
- (void) resume_game {
    self.parent.paused = NO;
    [self removeFromParent];
}

@end
