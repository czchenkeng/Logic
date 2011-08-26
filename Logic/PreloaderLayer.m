//
//  PreloaderLayer.m
//  Logic
//
//  Created by Pavel Krusek on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreloaderLayer.h"

@interface PreloaderLayer (PrivateMethods)
- (void) animationSequence;
@end


@implementation PreloaderLayer

- (void) buttonTapped:(id)sender {
    if ([[GameManager sharedGameManager] gameInProgress]) {
        CCLOG(@"co je?");
        [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kSlideInR];
    } else {
        [[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kSlideInR];
        //[[GameManager sharedGameManager] runSceneWithID:kCareerScene andTransition:kNoTransition];
        //[[GameManager sharedGameManager] runSceneWithID:kScoreScene andTransition:kNoTransition];
    }
    //[[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kNoTransition];
    //[[GameManager sharedGameManager] runSceneWithID:kCareerScene andTransition:kNoTransition];
    //[[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kNoTransition];
    //[[GameManager sharedGameManager] runSceneWithID:kScoreScene];
}

- (void) animationSequence {
    id factoryS = [CCSequence actions:[CCDelayTime actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.50], nil];
    id zakladS = [CCSequence actions:[CCDelayTime actionWithDuration:0.0], [CCFadeIn actionWithDuration:0.50], 
                  [CCDelayTime actionWithDuration:0.40], [CCFadeOut actionWithDuration:0.25], 
                  [CCDelayTime actionWithDuration:0.25], [CCFadeIn actionWithDuration:1.00], 
                  [CCFadeOut actionWithDuration:0.1], [CCDelayTime actionWithDuration:0.00], [CCFadeIn actionWithDuration:0.50],  nil];
    id blesk1S = [CCSequence actions:[CCDelayTime actionWithDuration:0.50], [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.40],[CCFadeOut actionWithDuration:0.25], nil];
    id blesk2S = [CCSequence actions:[CCDelayTime actionWithDuration:0.60], [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.30], [CCFadeOut actionWithDuration:0.25], 
                  [CCDelayTime actionWithDuration:1.35], [CCFadeIn actionWithDuration:0.10], [CCDelayTime actionWithDuration:0.10],
                  [CCFadeIn actionWithDuration:0.10], nil];
    id blesk3S = [CCSequence actions:[CCDelayTime actionWithDuration:0.70], [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.20], [CCFadeOut actionWithDuration:0.25], [CCDelayTime actionWithDuration:1.65],
                  [CCFadeIn actionWithDuration:0.1], nil];
    id blesk4S = [CCSequence actions:[CCDelayTime actionWithDuration:0.80], [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.10], [CCFadeOut actionWithDuration:0.25], nil];
    id hranyS = [CCSequence actions:[CCDelayTime actionWithDuration:0.80], [CCFadeIn actionWithDuration:0.10],
                 [CCDelayTime actionWithDuration:0.10], [CCFadeOut actionWithDuration:0.25],
                 [CCDelayTime actionWithDuration:1.65], [CCFadeIn actionWithDuration:0.05],[CCFadeOut actionWithDuration:0.05],  nil];
    
    [factory runAction:factoryS];
    [zaklad_mraky runAction:zakladS];
    [blesk1 runAction:blesk1S];
    [blesk2 runAction:blesk2S];
    [blesk3 runAction:blesk3S];
    [blesk4 runAction:blesk4S];
    [hrany runAction:hranyS];
}

- (id) init {
    self = [super initWithColor:ccc4(12,16,16,255)];
    if (self != nil) {        
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLoaderTexture];
        
        factory = [CCSprite spriteWithSpriteFrameName:@"factory.png"];
        zaklad_mraky = [CCSprite spriteWithSpriteFrameName:@"zaklad_mraky.png"];
        blesk1 = [CCSprite spriteWithSpriteFrameName:@"blesk1.png"];
        blesk2 = [CCSprite spriteWithSpriteFrameName:@"blesk2.png"];
        blesk3 = [CCSprite spriteWithSpriteFrameName:@"blesk3.png"];
        blesk4 = [CCSprite spriteWithSpriteFrameName:@"blesk4.png"];
        hrany = [CCSprite spriteWithSpriteFrameName:@"hrany.png"];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        factory.anchorPoint = ccp(0, 0);
        factory.position = kLoaderFactoryPosition;
        zaklad_mraky.anchorPoint = ccp(0, 0);
        zaklad_mraky.position = kLoaderZakladMrakyPosition;
        blesk1.anchorPoint = ccp(0, 0);
        blesk2.anchorPoint = ccp(0, 0);
        blesk3.anchorPoint = ccp(0, 0);
        blesk4.anchorPoint = ccp(0, 0);
        hrany.anchorPoint = ccp(0, 0);
        blesk1.position = kLoaderBlesk1Position;
        blesk2.position = kLoaderBlesk2Position;
        blesk3.position = kLoaderBlesk3Position;
        blesk4.position = kLoaderBlesk4Position;
        hrany.position = kLoaderHranyPosition;
        factory.opacity = 0;
        zaklad_mraky.opacity = 0;
        blesk1.opacity = 0;
        blesk2.opacity = 0;
        blesk3.opacity = 0;
        blesk4.opacity = 0;
        hrany.opacity = 0;
        
        [self addChild:zaklad_mraky];
        [self addChild:blesk1];
        [self addChild:blesk2];
        [self addChild:blesk3];
        [self addChild:blesk4];
        [self addChild:factory];
        [self addChild:hrany];
        
        [self animationSequence];
    }
    return self;
}

- (void)dealloc {
    //VYHAZET TEXTURY
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super dealloc];
}
@end
