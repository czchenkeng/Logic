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
                   [CCDelayTime actionWithDuration:5.00],
                   [CCDelayTime actionWithDuration:1.00],
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

- (void) rucickaSpawn {
    id rotate = [CCRotateTo actionWithDuration:5.0 angle:36];
    //id bezierAction = [CCBezierTo actionWithDuration:5 bezier:bezier];
    //id rucickaAction = [CCSpawn actions: bezierAction, rotate, nil];
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
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Flow1280x1920_VO" ofType:@"mp4"];
//    NSURL *movieURL = [NSURL fileURLWithPath:path];
//    
//    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
//    [mp moviePlayer].controlStyle = MPMovieControlStyleNone;
//    
//    //    [player setScalingMode:MPMovieScalingModeAspectFit];
//    //    [mp setControlStyle:MPMovieControlStyleFullscreen];
//    //    [mp setShouldAutoplay:YES];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedPlaying:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];    

    //[self schedule:@selector(runAnimation) interval:0.5];
    //[self rucickaSpawn];
    [self schedule:@selector(runAnimation) interval:1];
    [super onEnter];
}

//- (void) moviePlayerLoadStateChanged:(NSNotification*)notification {
//    
//    CCLOG(@"moviePlayerLoadStateChanged");
//    
//    if ([mp moviePlayer].loadState != MPMovieLoadStateUnknown) {        
//        if ([mp moviePlayer].loadState != MPMovieLoadStatePlaythroughOK) {
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
//            [[[[CCDirector sharedDirector] openGLView] window] addSubview:mp.view];
//            [[mp moviePlayer] play];
//        }
//    } else if ([mp moviePlayer].loadState == MPMovieLoadStateUnknown) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
//        [self schedule:@selector(runAnimation) interval:1];
//    }
//    
//}
//
//- (void) movieFinishedPlaying:(NSNotification*)notification {    
//    CCLOG(@"movie finish");
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
//    [mp.view removeFromSuperview];
//    CCLOG(@"mp retain count %i", [mp retainCount]);
//    [self schedule:@selector(runAnimation) interval:1];
//}

- (void) runAnimation {
    [self unschedule:@selector(runAnimation)];
    [self animationSequence];
}

- (id) init {
    self = [super initWithColor:ccc4(12,16,16,255)];
    if (self != nil) {        
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLoaderTexture];
        
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
        ciselnik.position = ccp(160.00, 36.50);
        
        rucicka = [CCSprite spriteWithSpriteFrameName:@"rucicka.png"];
        rucicka.anchorPoint = ccp(0.5, -2.1);
        rucicka.rotation = -35;
        rucicka.position = ccp(159, -26);
        
        budik = [CCSprite spriteWithSpriteFrameName:@"budikbody.png"];
        budik.position = ccp(160.00, 36.50);
        
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
        
        controlPoint1 = ccp(134, 17-21);
        controlPoint2 = ccp(159, 30-21);
        endPosition = ccp(180, 17-21);
        
        //rucicka.position = controlPoint1;
        
        bezier.controlPoint_1 = controlPoint1;
        bezier.controlPoint_2 = controlPoint2;
        bezier.endPosition = endPosition;
    }
    return self;
}

-(void) draw
{	
//	glEnable(GL_LINE_SMOOTH);
//	glColor4ub(255, 0, 255, 255);
//	glLineWidth(2);
//    
//	float boxW = 2.0f;
//     CGPoint vertices1[] = { ccp(controlPoint1.x-boxW ,controlPoint1.y+boxW), ccp(controlPoint1.x+boxW ,controlPoint1.y+boxW), ccp(controlPoint1.x+boxW ,controlPoint1.y-boxW), ccp(controlPoint1.x-boxW ,controlPoint1.y-boxW) };
//     ccDrawPoly(vertices1, 4, YES);
//     
//     
//     glColor4ub(255, 0, 0, 255);
//     CGPoint vertices2[] = { ccp(controlPoint2.x-boxW ,controlPoint2.y+boxW), ccp(controlPoint2.x+boxW ,controlPoint2.y+boxW), ccp(controlPoint2.x+boxW ,controlPoint2.y-boxW), ccp(controlPoint2.x-boxW ,controlPoint2.y-boxW) };
//     ccDrawPoly(vertices2, 4, YES);
//     
//     glColor4ub(0, 0, 255, 255);
//     CGPoint vertices3[] = { ccp(endPosition.x-boxW ,endPosition.y+boxW), ccp(endPosition.x+boxW ,endPosition.y+boxW), ccp(endPosition.x+boxW ,endPosition.y-boxW), ccp(endPosition.x-boxW ,endPosition.y-boxW) };
//     ccDrawPoly(vertices3, 4, YES);
//	 
//	
//	glColor4ub(0, 255, 0, 255);
//	ccDrawCubicBezier(controlPoint1, controlPoint1, controlPoint2, endPosition,100);
}


- (void)dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    //[[mp moviePlayer] release];
//    CCLOG(@"mp retain count %i", [mp retainCount]);
//    [mp release];
//    mp = nil;
    [super dealloc];
}
@end
