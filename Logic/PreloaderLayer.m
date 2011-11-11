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
- (void) rucickaSpawn;
@end


@implementation PreloaderLayer


- (void) animationSequence {
    PLAYSOUNDEFFECT(ANIMATION);
    id compositionSpawn = [CCSpawn actions:[CCScaleTo actionWithDuration:4.50 scale:1.14], 
                           [CCMoveTo actionWithDuration:4.50 position:ccp(composition.position.x + 4, composition.position.y + 7)], nil];
    
    id compositionS = [CCSequence actions:[CCDelayTime actionWithDuration:0.50],
                       compositionSpawn,
                       nil];
            
    id factoryS = [CCSequence actions:[CCFadeIn actionWithDuration:0.50],
                   [CCCallFunc actionWithTarget:self selector:@selector(rucickaSpawn)],
                   [CCDelayTime actionWithDuration:6.00],
                   [CCFadeOut actionWithDuration:0.50],
                   nil];
    id budikS = [CCSequence actions:[CCFadeIn actionWithDuration:0.50], 
                 [CCDelayTime actionWithDuration:5.00],
                 [CCDelayTime actionWithDuration:1.00],
                 [CCFadeOut actionWithDuration:0.50],
                 nil];
    id ciselnikS = [CCSequence actions:[CCFadeIn actionWithDuration:0.50], 
                    [CCDelayTime actionWithDuration:5.00],
                    [CCDelayTime actionWithDuration:1.00],
                    [CCFadeOut actionWithDuration:0.50],
                    nil];
    id rucickaS = [CCSequence actions:[CCFadeIn actionWithDuration:0.50], 
                   [CCDelayTime actionWithDuration:5.00],
                   [CCDelayTime actionWithDuration:1.00],
                   [CCFadeOut actionWithDuration:0.30],
                   nil];
    id zakladS = [CCSequence actions:[CCFadeIn actionWithDuration:0.50], 
                  [CCDelayTime actionWithDuration:0.90], 
                  [CCFadeOut actionWithDuration:0.30],
                  [CCFadeIn actionWithDuration:0.80],//2.5
                  [CCFadeOut actionWithDuration:0.10],
                  [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.80],//3.5
                  [CCFadeOut actionWithDuration:0.10],
                  [CCFadeIn actionWithDuration:0.50],
                  [CCDelayTime actionWithDuration:0.30],
                  [CCFadeOut actionWithDuration:0.10],//4.5
                  [CCFadeIn actionWithDuration:0.50],
                  [CCDelayTime actionWithDuration:1.00],
                  [CCFadeOut actionWithDuration:0.50],//5.5
                  nil];
    
    id blesk1S = [CCSequence actions:[CCDelayTime actionWithDuration:1.00],
                  [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.30],
                  [CCFadeOut actionWithDuration:0.30],
                  [CCDelayTime actionWithDuration:0.90],
                  [CCFadeIn actionWithDuration:0.10],//2.7
                  [CCFadeOut actionWithDuration:0.5],
                  [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.20],
                  [CCFadeOut actionWithDuration:0.1],//3.6
                  [CCDelayTime actionWithDuration:0.50],
                  [CCFadeIn actionWithDuration:0.30],
                  [CCFadeOut actionWithDuration:0.1],//4.5
                  [CCDelayTime actionWithDuration:1.00],//5.5
                  nil];
    id blesk2S = [CCSequence actions:[CCDelayTime actionWithDuration:1.10],
                  [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.20],
                  [CCFadeOut actionWithDuration:0.30],
                  [CCDelayTime actionWithDuration:0.90],//2.60
                  [CCFadeIn actionWithDuration:0.10],
                  [CCFadeOut actionWithDuration:0.50],
                  [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.20],
                  [CCFadeOut actionWithDuration:0.10],//3.60
                  [CCDelayTime actionWithDuration:1.90],//5.50
                nil];
    id blesk3S = [CCSequence actions:[CCDelayTime actionWithDuration:1.20], 
                  [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.10],
                  [CCFadeOut actionWithDuration:0.30],//1.70
                  [CCDelayTime actionWithDuration:1.60],
                  [CCFadeIn actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.10],//3.50
                  [CCFadeOut actionWithDuration:0.10],
                  [CCDelayTime actionWithDuration:0.50],
                  [CCFadeIn actionWithDuration:0.30],
                  [CCFadeOut actionWithDuration:0.10],//4.50
                  [CCDelayTime actionWithDuration:1.00],//5.50
                nil];
    id blesk4S = [CCSequence actions:[CCDelayTime actionWithDuration:1.30],
                  [CCFadeIn actionWithDuration:0.10],
                  [CCFadeOut actionWithDuration:0.30],//1.70
                  [CCDelayTime actionWithDuration:3.80],//5.50
                  nil];
    id hranyS = [CCSequence actions:[CCDelayTime actionWithDuration:1.30], 
                 [CCFadeIn actionWithDuration:0.10],
                 [CCFadeOut actionWithDuration:0.30],//1.70
                 [CCDelayTime actionWithDuration:1.60],
                 [CCFadeIn actionWithDuration:0.10],
                 [CCFadeOut actionWithDuration:0.10],//3.50
                 [CCDelayTime actionWithDuration:2.00],
                 nil];
    
    [budik runAction:budikS];
    [ciselnik runAction:ciselnikS];
    [rucicka runAction:rucickaS];
    [factory runAction:factoryS];
    [zaklad_mraky runAction:zakladS];
    [blesk1 runAction:blesk1S];
    [blesk2 runAction:blesk2S];
    [blesk3 runAction:blesk3S];
    [blesk4 runAction:blesk4S];
    [hrany runAction:hranyS];
    [composition runAction:compositionS];
}

- (void) runThunderbolt {
    [self unschedule:@selector(runThunderbolt)];
    Thunderbolt *t = [Thunderbolt node];
    [t initWithStartPoint:ADJUST_CCP(ccp(50, 530)) andEndPoint:ADJUST_CCP_OFFSET_X(ccp(136, 63)) andType:@"long_" andScale:YES];
    t.position = ADJUST_CCP(ccp(50, 530));
    [self addChild:t z:1000];
}

- (void) rucickaSpawn {
    id rotate = [CCRotateTo actionWithDuration:5.0 angle:36];
    id rucickaAction = [CCSpawn actions: rotate, nil];
    id preloadEnd = [CCSequence actions:rucickaAction, [CCDelayTime actionWithDuration:1.80], [CCCallFunc actionWithTarget:self selector:@selector(loaderEnd)], nil];
    [rucicka runAction:preloadEnd];
}

- (void) loaderEnd {
    [self schedule:@selector(startGame) interval:1.00f];
}

- (void) startGame {
    [self unschedule:@selector(startGame)];
    [[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kFadeTrans]; 
}

- (void) onEnter {
    [self schedule:@selector(runAnimation) interval:1];
    [super onEnter];
}

- (void) runAnimation {
    [self unschedule:@selector(runAnimation)];
    [self animationSequence];
    [self schedule:@selector(runThunderbolt) interval:5.00];
}

- (id) init {
    self = [super initWithColor:ccc4(12,16,16,255)];
    if (self != nil) {
        CCLOG(@"\n\n\n\nPRELOADER INIT\n\n\n\n");
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLoaderTexture];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kThunderboltsTexture];
        
        composition = [CCLayer node];
        [self addChild:composition z:1];
        
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
        
        ciselnik = [CCSprite spriteWithSpriteFrameName:@"ciselnik.png"];
        ciselnik.position = kLoaderCiselnikPosition;
        
        rucicka = [CCSprite spriteWithSpriteFrameName:@"rucicka.png"];
        rucicka.anchorPoint = ccp(0.5, -2.1);
        rucicka.rotation = -35;
        rucicka.position = kLoaderRucickaPosition;
        
        budik = [CCSprite spriteWithSpriteFrameName:@"budikbody.png"];
        budik.position = kLoaderBudikPosition;
        
        [composition addChild:zaklad_mraky z:1];
        [composition addChild:blesk1 z:2];
        [composition addChild:blesk2 z:3];
        [composition addChild:blesk3 z:4];
        [composition addChild:blesk4 z:5];
        [composition addChild:factory z:6];
        [composition addChild:hrany z:7];
        [self addChild:ciselnik z:8];
        [self addChild:budik z:10];
        [self addChild:rucicka z:9];
        ciselnik.opacity = 0;
        budik.opacity = 0;
        rucicka.opacity = 0;
    }
    return self;
}



- (void)dealloc {
    CCLOG(@"\n\n\n\n\n\nDEALLOC PRELOADER\n\n\n\n\n\n");
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super dealloc];
}
@end
