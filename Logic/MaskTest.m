//
//  MaskTest.m
//  Logic
//
//  Created by Apple on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MaskTest.h"


@implementation MaskTest

- (void) onEnter {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    [super onEnter];
}

- (id)init {
    self = [super init];
    if (self) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLevelBgTexture];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLevelLevelTexture];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kSettingsTexture];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kMainMainTexture];
        
//        CGSize size = [[CCDirector sharedDirector] winSize];
//        
//        // Create an object and a mask
//        CCSprite *object = [CCSprite spriteWithSpriteFrameName:@"5Lines.png"];
//        CCSprite *mask = [CCSprite spriteWithSpriteFrameName:@"logik_levelend_6line.png"];
//        
//        // Set their positions
//        object.position = ccp(100, 100);
//        mask.position = ccp(100, 100);
//        
//        // Create a masked image based on the object and the mask and add it to the screen
//        CCMask *masked = [CCMask createMaskForObject:object withMask:mask];
//        [self addChild: masked];
        
//        id move = [CCMoveTo actionWithDuration:10 position:ccp(object.position.x, object.position.y - 300)];
//        [object runAction:move];
        
        CCSprite *object = [CCSprite spriteWithSpriteFrameName:@"5Lines.png"];
        object.anchorPoint = ccp(0, 0);
        //[self addChild:object];
        
        mask = [CCSprite spriteWithSpriteFrameName:@"doors.png"];
        //[self addChild:mask];
        [mask setPosition:ccp(130.f,240.f)];
        myMask = [CCMask createMaskForObject:object withMask:mask];
        [self addChild:myMask];
        
        //mask a new object
//        [myMask setObject:newObject];
//        [myMask setMask:newMask];
//        [myMask maskWithoutClear];
        //myMask now contains 2 masked objects
        
        CCSprite *buttonBackOff = [CCSprite spriteWithSpriteFrameName:@"back_off.png"];
        CCSprite *buttonBackOn = [CCSprite spriteWithSpriteFrameName:@"back_on.png"];
        
        CCMenuItem *backItem = [CCMenuItemSprite itemFromNormalSprite:buttonBackOff selectedSprite:buttonBackOn target:self selector:@selector(buttonTapped:)];
        backItem.tag = kButtonBack;
        backItem.anchorPoint = CGPointMake(0.5, 1);
        backItem.position = kLeftNavigationButtonPosition;
        
        CCMenu *topMenu = [CCMenu menuWithItems:backItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:1000];
        
    }
    return self;
}

- (void) buttonTapped:(CCMenuItem *)sender {
    pinch = [CCSprite spriteWithSpriteFrameName:@"pinchPurple.png"];
    pinch.position = ccp(30, 240);
    //[myMask setMask:mask];
    [myMask setObject:pinch];
    [myMask setMask:mask];
    //[myMask addChild:pinch];
    [myMask redrawMasked];
    
    pinch.position = ccp(pinch.position.x + 150, pinch.position.y);
    [myMask redrawMasked];
    
//    id move = [CCMoveTo actionWithDuration:2 position:ccp(pinch.position.x + 50, pinch.position.y)];
//    id seq = [CCSequence actions:move, [CCCallFunc actionWithTarget:self selector:@selector(animEnded)], nil];
//    [pinch runAction:seq];
//    CCSprite *pinch2 = [CCSprite spriteWithSpriteFrameName:@"pinchWhite.png"];
//    pinch2.position = ccp(30, 240);
//    [myMask setObject:pinch2];
//    [myMask setMask:mask];
//    pinch2.scale = 2.0f;
//    //[myMask addChild:pinch];
//    [myMask redrawMasked];
}

- (void) selectPinch:(CGPoint)touchLocation {
    CCSprite *newSprite = nil;
    
    if (CGRectContainsPoint(pinch.boundingBox, touchLocation)) {            
        newSprite = pinch;
    }
    selPinch = newSprite;
    CCLOG(@"pinch %@", selPinch);
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"moved");
    CGPoint location = [self convertTouchToNodeSpace:touch];
    //CGPoint location =  [[CCDirector sharedDirector] convertToGL:touchLocation];
    if (selPinch) {
        [selPinch setPosition:ccp( location.x,location.y )];
        [myMask redrawMasked];
    }

}

//- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    UITouch *myTouch = [touches anyObject];
//    CGPoint location = [myTouch locationInView:[myTouch view]];
//    
//    location =  [[CCDirector sharedDirector] convertToGL:location];
//    CCLOG(@"location %@", NSStringFromCGPoint(location));
//    
//    [pinch setPosition:ccp( location.x,location.y )];
//    [myMask redrawMasked];
//    
//}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectPinch:touchLocation];
    
    return YES;
}

- (void) animEnded {
    pinch.position = ccp(pinch.position.x + 50, pinch.position.y);
    [myMask redrawMasked];
}

@end
