//
//  HowToLayer.m
//  Logic
//
//  Created by Pavel Krusek on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HowToLayer.h"


@implementation HowToLayer

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kHowToTexture];
        
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"howto_bg.png"];
        [bg setPosition:kHowToBgPosition];
        [self addChild:bg z:1];
        
        howTo = [CCLayer node];
        [self addChild:howTo z:3];
        
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"howto.png"];
        [sprite setPosition:kHowToHeaderPosition];
        [howTo addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"copy.png"];
        sprite.anchorPoint = ccp(0.5, 1);
        [sprite setPosition:kHowToCopyPosition];
        [howTo addChild:sprite z:3];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"screen.png"];
        sprite.position = kHowToScreenPosition;
        sprite.scale = 0.8;
        sprite.opacity = 0;
        sprite.tag = 1;
        [howTo addChild:sprite z:4];
        
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"screen_finger.png"];
        sprite.position = kHowToFingerPosition;
        sprite.scale = 0.9;
        [howTo addChild:sprite z:4];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"prst.png"];
        sprite.anchorPoint = ccp(0.5, 0);
        sprite.position = kHowToFinger2Position;
        sprite.scale = 0.9;
        sprite.tag = 2;
        sprite.opacity = 0;
        [howTo addChild:sprite z:5];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pincl_1.png"];
        sprite.position = kHowToPincl1Position;
        sprite.scale = 0.9;
        [howTo addChild:sprite z:5];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"red.png"];
        sprite.position = kHowToRedPosition;
        sprite.scale = 1;
        sprite.opacity = 0;
        sprite.tag = 3;
        [howTo addChild:sprite z:5];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pincl_2.png"];
        sprite.position = kHowToPincl2Position;
        sprite.scale = 0.9;
        [howTo addChild:sprite z:6];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"green.png"];
        sprite.position = kHowToGreenPosition;
        sprite.scale = 1;
        sprite.opacity = 0;
        sprite.tag = 4;
        [howTo addChild:sprite z:6];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"score=.png"];
        sprite.position = kHowToScorePosition;
        sprite.tag = 5;
        sprite.opacity = 0;
        [howTo addChild:sprite z:7];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_credits.png"];
        sprite.position = kHowToCreditsHeaderPosition;
        [howTo addChild:sprite z:8];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"credits.png"];
        sprite.anchorPoint = ccp(0.5, 1);
        sprite.position = kHowToCreditsCopyPosition;
        [howTo addChild:sprite z:9];
        
        [self schedule:@selector(startAnimation) interval:2];

        id anim1FadeOut = [CCFadeTo actionWithDuration:0.75 opacity:100];
        id anim1FadeIn = [CCFadeTo actionWithDuration:0.75 opacity:255];
        id anim1Spawn1 = [CCSpawn actions:anim1FadeIn, [CCScaleTo actionWithDuration:0.75 scale:0.8], nil];
        id anim1Spawn2 = [CCSpawn actions:anim1FadeOut, [CCScaleTo actionWithDuration:0.75 scale:0.75], nil];
        id anim1Seq = [CCSequence actions:anim1Spawn1, anim1Spawn2, nil];
        [(CCSprite*)[howTo getChildByTag:1] runAction:[CCRepeatForever actionWithAction:anim1Seq]];
        
        CCSprite *finger = (CCSprite*)[howTo getChildByTag:2];
        id anim2FadeIn = [CCFadeTo actionWithDuration:0.0 opacity:255];
        id anim2Move = [CCMoveTo actionWithDuration:0.5 position:ccp(finger.position.x + ADJUST_2(50), finger.position.y)];
        id anim2Rotate = [CCRotateTo actionWithDuration:0.5 angle:15];
        id anim2Spawn = [CCSpawn actions:anim2Move, anim2Rotate, nil];
        id anim2FadeOut = [CCFadeOut actionWithDuration:0.5];
        id anim2Move2 = [CCMoveTo actionWithDuration:0 position:ccp(finger.position.x - ADJUST_2(50), finger.position.y)];
        id anim2RotateBack = [CCRotateTo actionWithDuration:0 angle:0];
        id anim2Seq = [CCSequence actions:anim2FadeIn, [CCDelayTime actionWithDuration:0.0], anim2Spawn, [CCDelayTime actionWithDuration:0.2], anim2FadeOut, anim2Move2, anim2RotateBack,
                       [CCDelayTime actionWithDuration:0.5], nil];
        [finger runAction:[CCRepeatForever actionWithAction:anim2Seq]];
        
        id anim3FadeOut = [CCFadeTo actionWithDuration:0.5 opacity:50];
        id anim3FadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
        id anim3Seq = [CCSequence actions:anim3FadeIn, anim3FadeOut, nil];
        [(CCSprite*)[howTo getChildByTag:3] runAction:[CCRepeatForever actionWithAction:anim3Seq]];
        
        id anim4FadeOut = [CCFadeTo actionWithDuration:0.5 opacity:50];
        id anim4FadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
        id anim4Seq = [CCSequence actions:anim4FadeIn, anim4FadeOut, nil];
        [(CCSprite*)[howTo getChildByTag:4] runAction:[CCRepeatForever actionWithAction:anim4Seq]];
        
        id anim5FadeOut = [CCFadeTo actionWithDuration:1 opacity:100];
        id anim5FadeIn = [CCFadeTo actionWithDuration:1 opacity:255];
        id anim5Spawn1 = [CCSpawn actions:anim5FadeIn, [CCScaleTo actionWithDuration:0.75 scale:1.2], nil];
        id anim5Spawn2 = [CCSpawn actions:anim5FadeOut, [CCScaleTo actionWithDuration:0.75 scale:1.00], nil];
        id anim5Seq = [CCSequence actions:anim5Spawn1, anim5Spawn2, nil];
        [(CCSprite*)[howTo getChildByTag:5] runAction:[CCRepeatForever actionWithAction:anim5Seq]];
        
    }
    return self;
}

- (void) startAnimation {
    CCMoveTo *htMove = [CCMoveTo actionWithDuration:30 position:ccp(howTo.position.x, ADJUST_2(1369))];
    htMove.tag = 100;
    [howTo runAction:htMove];
    [self unschedule:@selector(startAnimation)];
}

- (void) onEnter {
    panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)] autorelease];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panGestureRecognizer];
    [super onEnter];
}

- (void) onExit {
	[[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:panGestureRecognizer];
	[super onExit];
}

#pragma mark -
#pragma mark PAN METHODS
#pragma mark Adjust position for pan
- (CGPoint) boundLayerPos:(CGPoint)newPos {
    CGPoint retval = newPos;
    retval.x = howTo.position.x;
    retval.y = MIN(-retval.y, 0);
    retval.y = MIN(-retval.y, ADJUST_2(1369));
    return retval;
}

#pragma mark Moving layer - pan callback
- (void) moveBoard:(CGPoint)translation from:(CGPoint)lastLocation {
	CGPoint target_position = ccpAdd(translation, lastLocation);
    howTo.position = [self boundLayerPos:target_position];
}

#pragma mark Pan handler
- (void) handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [howTo stopActionByTag:100];
        [self unschedule:@selector(startAnimation)];
        zbLastPos = howTo.position;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint translation = [recognizer translationInView:recognizer.view];
		translation.y = -1 * translation.y;
		[self moveBoard:translation from:zbLastPos];
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
        zbLastPos = howTo.position;
    }
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end
