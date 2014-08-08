//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "MainScene.h"

@implementation MainScene

- (void) start_level1 {
    [self play:1];
}

- (void) start_level2 {
    [self play:2];
}

- (void) start_level3 {
    [self play:3];
}

- (void)play: (int) levelToStart {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    
    //start scense, load given level
    NSArray *allChildren = gameplayScene.children;
    for (CCNode * someNode in allChildren)
    {
        if([someNode isKindOfClass:[Gameplay class]])
        {
            [(Gameplay *)someNode loadLevelMap:levelToStart];
        }
    }
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:transition];
}

- (void) exit {
    exit(0);
}
@end
