//
//  Gameplay.m
//  TankGame
//
//  Created by ZhangXiaokang on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Barrier.h"
#import "Gameplay.h"
#import "Defender.h"
#import "Intruder.h"
#import "Popups.h"
#import "Level.h"
#import "IntruderBullet.h"
#import "DefenderBullet.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#include <stdlib.h>
#include <math.h>

//Bullet owner
int BULLET_OWNER_INTRUDER = 1;
int BULLET_OWNER_DEFENDER = 2;

@implementation Gameplay{
    //Physical Node
    CCPhysicsNode *_physicsNode;
    //Level Node
    CCNode *_levelNode;
    //Defender tank
    CCNode *_defender;
    //Intruder tank array
    NSMutableArray *_intruders;
    //Defense object array
    NSMutableArray *_barriers;
    //Level scense
    CCScene* level;
    //Defender label
    CCLabelTTF* _labelDefenderDefense;
    //Intruder label
    CCLabelTTF* _labelIntruderDefense;
    //Total number of intruder
    int _liveIntruderNum;
    //Level to load
    int _levelToLoad;
}

//Is called when CCB file has completed loading
- (void)didLoadFromCCB {
    //Tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //Game begin, load level
    CCLOG(@"Tank Game Begin");
    
    //Test
    //_physicsNode.debugDraw = true;
}


//This method will be called from other class to load level
- (void) loadLevelMap: (int) levelToLoad {
    CCLOG(@"load_level");
    _levelToLoad = levelToLoad;
    switch (levelToLoad)
    {
        case 1 :
            level = [CCBReader loadAsScene:@"Levels/Level1"];
            _defender = [CCBReader load:@"Defender_Small"];
            break;
        case 2 :
            level = [CCBReader loadAsScene:@"Levels/Level2"];
            _defender = [CCBReader load:@"Defender_Medium"];
            break;
        case 3:
            level = [CCBReader loadAsScene:@"Levels/Level3"];
            _defender = [CCBReader load:@"Defender_Large"];
            break;
    }
    
    [_levelNode addChild:level];
    
    //Defender tank
    _defender.position = ccp(160, 16);
    [_physicsNode addChild:_defender];
    
    //Load Intruder
    [self loadIntruderTanks];
    
    //Load defense object
    [self loadBarriers];
    
    //Set defender score label
    [self updateDefenderLabel];
    
    //Set intruder score label
    [self updateIntruderLabel];
    
    //Random movement intruders
    [self schedule:@selector(randomMoveIntruders) interval:(1.0/_levelToLoad)];
    [self schedule:@selector(randomFireIntruders) interval:(2.0/_levelToLoad)];
    
    //Collision delegate
    _physicsNode.collisionDelegate = self;
}

//Load intruders
- (void) loadIntruderTanks {
    //Load intruders
    _intruders = [[NSMutableArray alloc] init];
    NSArray *allChildren = level.children;
    for (CCNode * someNode in allChildren)
    {
        for(CCNode * node in someNode.children){
            if([node isKindOfClass:[Intruder class]])
            {
                [_intruders addObject: node];
                _liveIntruderNum += 1;
                CCLOG(@"Found intruder");
            }
        }
    }
}

//Load defense object
- (void) loadBarriers {
    _barriers = [[NSMutableArray alloc] init];
    NSArray *allChildren = level.children;
    for (CCNode * someNode in allChildren)
    {
        for(CCNode * node in someNode.children){
            if([node isKindOfClass:[Barrier class]])
            {
                CCNode *_node = [[CCNode  alloc] init];
                _node.position = node.position;
                [_barriers addObject: _node];
                CCLOG(@"Found Defense Object");
            }
        }
    }
}

//Lad defender score
- (void) updateDefenderLabel {
    [_labelDefenderDefense setString:[NSString stringWithFormat:@"%d",((Defender *)_defender).defense]];
}

//Load intruder score
- (void) updateIntruderLabel {
    [_labelIntruderDefense setString:[NSString stringWithFormat:@"%d", _liveIntruderNum]];
}

//==================== Random Movement for intruders ===============================//

- (void) randomMoveIntruders{
    for(CCNode * intruder in _intruders){
        [self randomMoveAndRotateIntruder:intruder];
    }
}


//Genareate random movement for one intruder
- (void) randomMoveAndRotateIntruder:(CCNode * )intruder{
    //Check if the intruder alive
    if(((Intruder *)intruder).alive == false)
        return;
    
    //If current location will collide with barrier or other intruder, random trun away
    if(![self isCollideWithBarrier:intruder.position :intruder.rotation] ||
       ![self isCollideWithOtherIntruders:intruder]) {
        intruder.rotation = ((int)intruder.rotation + 90 * (arc4random() % 2 + 1)) % 360;
    } else {
        //Else move directly
        CGPoint newPosition;
        switch((int)intruder.rotation){
            case 0:
                newPosition = ccpAdd(intruder.position, ccp(0, 16));
                break;
            case 90:
                newPosition = ccpAdd(intruder.position, ccp(16, 0));
                break;
            case 180:
                newPosition = ccpAdd(intruder.position, ccp(0, -16));
                break;
            case 270:
                newPosition = ccpAdd(intruder.position, ccp(-16, 0));
                break;
        }
        
        //Use CCAction to control the movement of the intruder tank
        CCActionMoveTo *moteAction = [CCActionMoveTo actionWithDuration:0.3/_levelToLoad position:newPosition];
        [intruder runAction:moteAction];
    }
}

//Check if tank collide with barrier
-(Boolean) isCollideWithBarrier:(CGPoint)tankPosition :(int)tankRotation {
    for (CCNode * barrier in _barriers) {
        switch((int)tankRotation){
            //Move up: X in same level, Y closing
            case 0:
                if (abs(barrier.position.x - tankPosition.x) < 32 &&
                    barrier.position.y > tankPosition.y  &&
                    barrier.position.y - tankPosition.y <= 36)
                    return false;
                break;
            //Move right: Y in same level, X closing
            case 90:
                if(abs(barrier.position.y - tankPosition.y) < 32 &&
                   barrier.position.x > tankPosition.x  &&
                   barrier.position.x - tankPosition.x <= 36)
                    return false;
                break;
            //Move down
            case 180:
                if(abs(barrier.position.x - tankPosition.x) < 32 &&
                   tankPosition.y > barrier.position.y &&
                   tankPosition.y - barrier.position.y <= 36)
                    return false;
                break;
            //Move left
            case 270:
                if(abs(barrier.position.y - tankPosition.y) < 32 &&
                   tankPosition.x > barrier.position.x  &&
                   tankPosition.x - barrier.position.x <= 36)
                    return false;
                break;
        }
    }
    return true;
}

//Check if intruder collide with other intruder
-(Boolean) isCollideWithOtherIntruders:(CCNode *)currentIntruder {
    for(CCNode * otherIntruder in _intruders) {
        if ([otherIntruder isEqual: currentIntruder])
            continue;
        switch((int)currentIntruder.rotation){
                //Move up: X in same level, Y closing
            case 0:
                if (abs(otherIntruder.position.x - currentIntruder.position.x) < 32 &&
                    otherIntruder.position.y > currentIntruder.position.y  &&
                    otherIntruder.position.y - currentIntruder.position.y <= 36)
                    return false;
                break;
                //Move right: Y in same level, X closing
            case 90:
                if(abs(otherIntruder.position.y - currentIntruder.position.y) < 32 &&
                   otherIntruder.position.x > currentIntruder.position.x  &&
                   otherIntruder.position.x - currentIntruder.position.x <= 36)
                    return false;
                break;
                //Move down
            case 180:
                if(abs(otherIntruder.position.x - currentIntruder.position.x) < 32 &&
                   currentIntruder.position.y > otherIntruder.position.y &&
                   currentIntruder.position.y - otherIntruder.position.y <= 36)
                    return false;
                break;
                //Move left
            case 270:
                if(abs(otherIntruder.position.y - currentIntruder.position.y) < 32 &&
                   currentIntruder.position.x > otherIntruder.position.x  &&
                   currentIntruder.position.x - otherIntruder.position.x <= 36)
                    return false;
            break;
        }
    }
    return true;
}

//Generate random fire for intruders
- (void) randomFireIntruders{
    for(CCNode * intruder in _intruders){
        [self randomFireIntruder:intruder];
    }
}

//Move intruder randomly
- (void) randomFireIntruder:(CCNode * )intruder{
    //Check if alive
    if(((Intruder *)intruder).alive == false)
        return;
    
    //Defender bullet
    CCNode *intruderBullet = [CCBReader load:@"IntruderBullet"];
    //((IntruderBullet *)_intruderBullet).owner = BULLET_OWNER_INTRUDER;
    
    
    //Add bullet to the physicasNode of the scene
    [_physicsNode addChild:intruderBullet];
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection;
    //Generate bullet
    switch ((int)intruder.rotation) {
        case 0:
            launchDirection = ccp(0, 1);
            intruderBullet.position = ccpAdd(intruder.position, ccp(0,32));
            break;
        case 90:
            launchDirection = ccp(1, 0);
            intruderBullet.position = ccpAdd(intruder.position, ccp(32,0));
            break;
        case 180:
            launchDirection = ccp(0, -1);
            intruderBullet.position = ccpAdd(intruder.position, ccp(0, -32));
            break;
        case 270:
            launchDirection = ccp(-1, 0);
            intruderBullet.position = ccpAdd(intruder.position, ccp(-32,0));
            break;
    }
    intruderBullet.rotation = intruder.rotation;
    CGPoint force = ccpMult(launchDirection, 10 * _levelToLoad);
    [intruderBullet.physicsBody applyForce:force];
    
    [self tankFireEffect:intruderBullet];
}

//=========================Collision Handler ====================================//

//Collision: intruder and defenderbullet
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair intruderCollision:(CCNode *)nodeA
           defenderBulletCollision:(CCNode *)nodeB
{
    CCLOG(@"Defender Bullet hit intruder");
    
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeB];
    } key:nodeB];
    //To void the fore from bullet on the tank...
    
    //Check defense: if defense 0, remove it
    Intruder* currentIntruder = (Intruder *)nodeA;
    
    //If bullet came from the intruder will be ignored.
    if(((DefenderBullet *)nodeB).owner == BULLET_OWNER_INTRUDER){
        return;
    }
    
     currentIntruder.defense -= 1;
    //Add shot effect
    [self bulletHitEffect:currentIntruder];
    if(currentIntruder.defense <= 0){
        //Remove the intruder
        currentIntruder.alive = false;

        [[_physicsNode space] addPostStepBlock:^{
            [self objectRemoved:nodeA];
        } key:nodeA];
        
        [_intruders removeObject:nodeA];
        
        //Update intruder score
        _liveIntruderNum -= 1;
        [self updateIntruderLabel];
        
        //Remove the object from intruder array
        [_intruders removeObject:currentIntruder];
        
        //Check if win
        if([self checkIfWin] == true)
            [self winPopup];
        
        //Add destroy partial effect
        [self tankDestroyEffect: currentIntruder];
    }
}

//Check if the intruder win
-(Boolean) checkIfWin{
    for(Intruder * intruder in _intruders){
        if(intruder.alive == true)
            return false;
    }
    return true;
}

//Intruder vs intruder bullet
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair intruderCollision:(CCNode *)nodeA
           intruderBulletCollision:(CCNode *)nodeB
{
    CCLOG(@"Intruder bullet hit intruder, remove bullet");
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeB];
    } key:nodeB];
}


//Intruder bullet hit defender
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair defenderCollision:(CCNode *)nodeA
                            intruderBulletCollision:(CCNode *)nodeB
{
    CCLOG(@"Intruder Bullet hit defender, remove bullet");
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeB];
    } key:nodeB];
    
    //Check defense: if defense 0, remove it from parent
    Defender* currentDefender = (Defender *)nodeA;
    currentDefender.defense -= 1;
    
    //Add shot partial effect
    [self bulletHitEffect:currentDefender];
    
    //Update intruder score
    [self updateDefenderLabel];
    
    if(currentDefender.defense == 0){
        [[_physicsNode space] addPostStepBlock:^{
            [self objectRemoved:nodeA];
        } key:nodeA];
        
        // Add partial effect
        [self tankDestroyEffect:currentDefender];
        
        // Game Over
        [self defeatPopup];
    }
}

//Defender bullet hit defender
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair defenderCollision:(CCNode *)nodeA
           defenderBulletCollision:(CCNode *)nodeB {
    CCLOG(@"Defender bullet somehow hit defender, remove bullt");
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeB];
    } key:nodeB];
}

//Intruder bullet hit barrier
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair intruderBulletCollision:(CCNode *)nodeA
                            barrierCollision:(CCNode *)nodeB
{
    CCLOG(@"Intruder Bullet hit barrier, remove bullet");
    //Add partile effect
    [self tankFireEffect:nodeA];
    
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeA];
    } key:nodeA];
}

//Defender bullet hit barrier
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair defenderBulletCollision:(CCNode *)nodeA
                   barrierCollision:(CCNode *)nodeB
{
    CCLOG(@"Intruder Bullet hit wall, remove bullet");
    //Add partile effect
    [self tankFireEffect:nodeA];
    
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeA];
    } key:nodeA];
}

//Intruder bullet hit intruder bullet
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair intruderBulletCollision:(CCNode *)nodeA
                   intruderBulletCollision:(CCNode *)nodeB
{
    CCLOG(@"Intruder Bullet hit intruder bullet!");
    [self bulletHitEffect:nodeA];
    
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeA];
    } key:nodeA];
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeB];
    } key:nodeB];
}

//Intruder bullet hit defneder bulelt
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair intruderBulletCollision:(CCNode *)nodeA
           defenderBulletCollision:(CCNode *)nodeB
{
    CCLOG(@"Intruder Bullet hit defender bullet, remove both");
    [self bulletHitEffect:nodeA];
    
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeA];
    } key:nodeA];
    [[_physicsNode space] addPostStepBlock:^{
        [self objectRemoved:nodeB];
    } key:nodeB];
}

//Remove object from parent
- (void)objectRemoved:(CCNode *)object {
    [object removeFromParent];
    CCLOG(@"Removed from screen");
}


//============================== popup handler =============================//

//Win pop up
- (void) winPopup {
    //Find the level child
    int levelNum  = 0;
    NSArray *allChildren = level.children;
    for (CCNode * someNode in allChildren)
    {
        if([someNode isKindOfClass:[Level class]])
        {
            levelNum = ((Level *)someNode).levelNum;
        }
    }
    
    //Decide which pop up should be load
    Popups *popup;
    switch (levelNum) {
        case 1:
            popup = (Popups *)[CCBReader load:@"Popups/WinPopupLevel1"];
            popup.currentLevel = 1;
            break;
        case 2:
            popup = (Popups *)[CCBReader load:@"Popups/WinPopupLevel1"];
            popup.currentLevel = 2;
            break;
        case 3:
            popup = (Popups *)[CCBReader load:@"Popups/WinPopupLevel2"];
            //Set current level to 1, so that it start from level 1
            popup.currentLevel = 1;
            break;
            
    }
    
    //popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(80, 160);
    
    [self addChild:popup];
}

//defeat pop up
- (void) defeatPopup {
    self.paused = YES;
    
    //Find the level child
    int levelNum  = 0;
    NSArray *allChildren = level.children;
    for (CCNode * someNode in allChildren)
    {
        if([someNode isKindOfClass:[Level class]])
        {
            levelNum = ((Level *)someNode).levelNum;
        }
    }
    
    //Decide which pop up should be load
    Popups *popup = (Popups *)[CCBReader load:@"Popups/DefeatPopup"];;
    switch (levelNum) {
        case 1:
            popup.currentLevel = 1;
            break;
        case 2:
            popup.currentLevel = 2;
            break;
        case 3:
            popup.currentLevel = 3;
            break;
    }
    
    //popup.positionType = CCPositionTypeNormalized;
    popup.position = ccp(80, 160);
    
    [self addChild:popup];
}

//============================== controller ================================//
//Fire defender
- (void)fireDefender {
    //Defender bullet
    CCNode *defenderBullet = [CCBReader load:@"DefenderBullet"];
    
    //Add bullet to the physicasNode of the scene
    [_physicsNode addChild:defenderBullet];
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection;
    //If up
    switch((int)_defender.rotation){
        case 0:
            launchDirection = ccp(0, 1);
            //Position defender bullet at the beginning of the tank
            defenderBullet.position = ccpAdd(_defender.position, ccp(0,20));
            break;
            
        case 90:
            launchDirection = ccp(1, 0);
            defenderBullet.position = ccpAdd(_defender.position, ccp(20, 0));
            break;
            
        case 180:
            launchDirection = ccp(0, -1);
            defenderBullet.position = ccpAdd(_defender.position, ccp(0, -18));
            break;
            
        case 270:
            launchDirection = ccp(-1, 0);
            defenderBullet.position = ccpAdd(_defender.position, ccp(-18,0));
            break;
    }
    defenderBullet.rotation = _defender.rotation;
    CGPoint force = ccpMult(launchDirection, 10 * _levelToLoad);
    [defenderBullet.physicsBody applyForce:force];
    
    //Load particle effect
    [ self tankFireEffect:defenderBullet];
}

//Touch control for intruder movement

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //Get touch location
    CGPoint touchLocation = [touch locationInWorld];
    //convert defender location into world space
    CGPoint defenderLocation = [_physicsNode convertToWorldSpace:_defender.position];
    //Caculate the orintation vector
    CGPoint distance = CGPointMake(touchLocation.x - defenderLocation.x, touchLocation.y - defenderLocation.y);
    
    //move left or right
    if(fabsf(distance.x) >= fabsf(distance.y)){
        //move right
        if(distance.x >= 0)
            [self moveDefenderRight];
        //Move left
        else
            [self moveDefenderLeft];
    //Move up or down
    } else {
        //Move up
        if(distance.y >= 0)
            [self moveDefenderUp];
        //Move down
        else
            [self moveDefenderDown];
    }
    
}

//Move up defender
- (void)moveDefenderUp{
    CCLOG(@"defender move up");
    int rotation = _defender.rotation;
    _defender.rotation = 0;
    //Move only when in given direction
    if(rotation == 0 &&
       [self isCollideWithBarrier:_defender.position :_defender.rotation] &&
       [self isCollideWithOtherIntruders:_defender])
            _defender.position = ccpAdd(_defender.position, ccp(0, 16));
}

//Move down defender
- (void) moveDefenderDown{
    CCLOG(@"defender move down");
    int rotation = _defender.rotation;
    _defender.rotation = 180;
    if(rotation == 180 &&
       [self isCollideWithBarrier:_defender.position :_defender.rotation] &&
       [self isCollideWithOtherIntruders:_defender])
        _defender.position = ccpAdd(_defender.position, ccp(0, -16));
}

//Move left defender
- (void) moveDefenderLeft{
    CCLOG(@"defender move left");
    int rotation = _defender.rotation;
    _defender.rotation = 270;
    if(rotation == 270 &&
       [self isCollideWithBarrier:_defender.position :_defender.rotation] &&
       [self isCollideWithOtherIntruders:_defender])
        _defender.position = ccpAdd(_defender.position, ccp(-16, 0));
}

//Move right defender
- (void) moveDefenderRight{
    CCLOG(@"defender move right");
    int rotation = _defender.rotation;
    _defender.rotation = 90;
    if(rotation == 90 &&
       [self isCollideWithBarrier:_defender.position :_defender.rotation] &&
       [self isCollideWithOtherIntruders:_defender])
        _defender.position = ccpAdd(_defender.position, ccp(16, 0));
}

//Pause Game
- (void) pauseGame {
    self.paused = YES;
    Popups *popup = (Popups *)[CCBReader load:@"Popups/PausePopup"];
    popup.position = ccp(80, 160);
    [self addChild:popup];
}

//==============================Particle effect ===================================//

-(void) bulletHitEffect: (CCNode *)node {
    //Load particle effect
    CCParticleSystem *bulletHit = (CCParticleSystem *)[CCBReader load:@"BulletHitEffect"];
    bulletHit.autoRemoveOnFinish = TRUE;
    bulletHit.position = node.position;
    [node.parent addChild:bulletHit];
}

-(void) tankDestroyEffect: (CCNode *)node {
    CCParticleSystem *tankeDestroy = (CCParticleSystem *)[CCBReader load:@"TankDestroyEffect"];
    tankeDestroy.autoRemoveOnFinish = TRUE;
    tankeDestroy.position = node.position;
    [node.parent addChild:tankeDestroy];
}

-(void) tankFireEffect: (CCNode *)node {
    CCParticleSystem *tankeFire = (CCParticleSystem *)[CCBReader load:@"TankFireEffect"];
    tankeFire.autoRemoveOnFinish = TRUE;
    tankeFire.position = node.position;
    [node.parent addChild:tankeFire];
}
@end
