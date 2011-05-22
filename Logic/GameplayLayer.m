//
//  GameplayLayer.m
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameplayLayer.h"


@implementation GameplayLayer

- (id) init {
    self = [super init];
    if (self != nil) {
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        [self addFigures];
    }
    return self;
}

- (void) addFigures {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    movableFigures = [[NSMutableArray alloc] init];
    
    spritesBgNode = [CCSpriteBatchNode batchNodeWithFile:@"gameAssets.pvr.ccz"];
    [self addChild:spritesBgNode];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gameAssets.plist"];
    
    NSArray *images = [NSArray arrayWithObjects:@"figure1.png", @"figure2.png", @"figure3.png", @"figure4.png", @"figure5.png", @"figure6.png", @"figure7.png", @"figure8.png", nil];
    CCLOG(@"count %i", images.count);
    for (int i = 0; i < images.count; ++i) {
        NSString *image = [images objectAtIndex:i];
        float offsetFraction = ((float)(i+1))/(images.count+1); 
        CCLOG(@"image %@", image);
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:image];
        sprite.position = ccp(winSize.width*offsetFraction, winSize.height/2);
        [spritesBgNode addChild:sprite z:i];
        //default je 0?
        [movableFigures addObject:sprite];
    }
    
}

- (void) selectSpriteForTouch:(CGPoint)touchLocation {
    CCSprite * newSprite = nil;
    for (CCSprite *sprite in [movableFigures reverseObjectEnumerator]) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {            
            newSprite = sprite;
            break;
        }
    }    
    if (newSprite != selSprite) {
//        [selSprite stopAllActions];
//        [selSprite runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
//        CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-4.0];
//        CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
//        CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:4.0];
//        CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
//        [newSprite runAction:[CCRepeatForever actionWithAction:rotSeq]];            
        selSprite = newSprite;
        CCLOG(@"z order of sprite before %i", selSprite.zOrder);
        if (selSprite) {
            [spritesBgNode reorderChild:selSprite z:selSprite.zOrder + 100];
            CCLOG(@"z order of sprite %i", selSprite.zOrder);
        }
    }
    
}

- (void) panForTranslation:(CGPoint)translation {    
    CCLOG(@"Sel Sprite %@", selSprite);
    if (selSprite) {
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        selSprite.position = newPos;
    }  
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {       
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    //CCLOG(@"Translation %f %f", translation.x, translation.y);
    [self panForTranslation:translation];    
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];
    CCLOG(@"Touch began %f %f", touchLocation.x, touchLocation.y);
    //return TRUE;
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"Touch end");
    CCLOG(@"Sel Sprite %@", selSprite);
}

- (void) dealloc {
    [movableFigures release];
    movableFigures = nil;
    [super dealloc];
}

@end