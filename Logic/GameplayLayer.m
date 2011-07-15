//
//  GameplayLayer.m
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameplayLayer.h"


@implementation GameplayLayer

#pragma mark Build level
- (void) prepareAssets {
    // set iPad / iPhone assets string
    NSString *hw = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        hw = @"Pad";
    }
    
    //init arrays
    greenLights = [[CCArray alloc] init];
    orangeLights = [[CCArray alloc] init];
    
    //init layers
    movableNode = [CCLayer node];
    figuresNode = [CCLayer node];
    
    //assetsLevelBgNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"LevelBg%@.pvr.ccz", hw]];
    //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"LevelBg%@.plist", hw]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"LevelBg%@.plist", hw]];
    
    //assetsLevelNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"Level%@.plist", hw]];
    //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Level%@.plist", hw]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Level%@.plist", hw]];
    
    sphereNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"Animations%@.pvr.ccz", hw]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Animations%@.plist", hw]];
    //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Animations%@.plist", hw]];
    
    NSString *bgFrame;
    NSString *levelEndFrame;
    
    switch (currentDifficulty) {
        case kEasy:
            bgFrame = @"4Lines.png";
            levelEndFrame = @"logik_levelend_4line.png";
            difficultyPadding = 67.00;
            break;
        case kMedium:
            bgFrame = @"5Lines.png";
            levelEndFrame = @"logik_levelend_5line.png";
            difficultyPadding = 50.00;
            break;
        case kHard:
            bgFrame = @"6Lines.png";
            levelEndFrame = @"logik_levelend_6line.png";
            difficultyPadding = 40.00;
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot create string");
            return;
            break;
    }
    
    CCSprite *bg = [CCSprite spriteWithSpriteFrameName:bgFrame];
    bg.anchorPoint = CGPointMake(0, 0);
    
    highlightSprite = [CCSprite spriteWithSpriteFrameName:@"highlight.png"];
    highlightSprite.position = ccp(150, 280);
    highlightSprite.visible = NO;
    
    codeBase = [CCSprite spriteWithSpriteFrameName:levelEndFrame];
    codeBase.position = ccp(133, 455);
    
    rotorLeftLayer = [CCLayer node];
    rotorRightLayer = [CCLayer node];
    rotorLeft = [CCSprite spriteWithSpriteFrameName:@"rotor_left.png"];
    rotorRight = [CCSprite spriteWithSpriteFrameName:@"rotor_right.png"];
    rotorLeftInside = [CCSprite spriteWithSpriteFrameName:@"rotor_left_inside.png"];
    rotorRightInside = [CCSprite spriteWithSpriteFrameName:@"rotor_right_inside.png"];
    rotorLeftLight = [CCSprite spriteWithSpriteFrameName:@"rotor_left_light.png"];
    rotorRightLight = [CCSprite spriteWithSpriteFrameName:@"rotor_right_light.png"];
    rotorLeftLayer.position = ccp(54.00, 430.00);
    rotorRightLayer.position = ccp(259.00, 434.00);
    
    //KRYTKA
    mantle = [CCSprite spriteWithSpriteFrameName:@"logik_krytka.png"];
    mantle.position = ccp(160.00, 456.00);
    
    //LIGHT UNDER SPHERE
    sphereLight = [CCSprite spriteWithSpriteFrameName:@"lightSphere.png"];
    sphereLight.opacity = 155;
    sphereLight.position = ccp(150.00, 411.00);
    [self schedule:@selector(alphaShadows:) interval:0.1];
    
    //SPHERE
    morphingSphereFrames = [NSMutableArray array];//convenient?
    for(int i = 1; i <= 15; ++i) {
        [morphingSphereFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"ball_anim%d.png", i]]];
    }
    sphereAnim = [CCAnimation animationWithFrames:morphingSphereFrames delay:0.1f];
    sphereSeq = [CCSequence actions:
                 [CCAnimate actionWithAnimation:sphereAnim restoreOriginalFrame:YES],
                 [CCCallFunc actionWithTarget:self selector:@selector(sphereAnimEnded)],
                 nil];
    sphere = [CCSprite spriteWithSpriteFrameName:@"ball_anim1.png"];
    [sphereNode addChild:sphere];
    [sphere runAction:sphereSeq];
    sphereNode.position = ccp(152, 474);
    
    base = [CCSprite spriteWithSpriteFrameName:@"pinchBase.png"];
    base.anchorPoint = CGPointMake(0, 0);
    
    //add nodes to display list
    [self addChild:movableNode z:2 tag:2];
        [movableNode addChild:bg z:-1 tag:-1];
        [movableNode addChild:highlightSprite z:200];
    [self addChild:codeBase z:3 tag:3];
    [self addChild:mantle z:5];
    [self addChild:base z:6 tag:11];
    [self addChild:figuresNode z:7];
    [self addChild:sphereLight z:8];
    [self addChild:rotorLeftLayer z:9];
        [rotorLeftLayer addChild:rotorLeft z:1];
        [rotorLeftLayer addChild:rotorLeftLight z:2];
        [rotorLeftLayer addChild:rotorLeftInside z:3];
    [self addChild:rotorRightLayer z:10];    
        [rotorRightLayer addChild:rotorRight z:1];
        [rotorRightLayer addChild:rotorRightLight z:2];
        [rotorRightLayer addChild:rotorRightInside z:3];
    [self addChild:sphereNode z:11 tag:11];
    
    dustSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"dust1.plist"];
    [self addChild:dustSystem z:1000];
    
    smokeSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"smoke.plist"];
    [self addChild:smokeSystem z:1001];
    [self schedule:@selector(test:) interval:3.00];
}

- (void) test:(ccTime)dt {
    //smokeSystem.visible = !smokeSystem.visible;
    if (shit) {
        [smokeSystem removeFromParentAndCleanup:YES];
    } else {
         smokeSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"smoke.plist"];
       [self addChild:smokeSystem z:1001]; 
    }
    shit = !shit;
}

#pragma mark Callback methods sphere & shadows
/* callback sphere animation */
- (void) sphereAnimEnded {
    float delay = 1.0 / (float)[Utils randomNumberBetween:10 andMax:20];
    //CCLOG(@"delay is %f", delay);
    [sphere stopAllActions];
    [sphereAnim setDelay:delay];
    sphereSeq = [CCSequence actions:
                 [CCAnimate actionWithAnimation:sphereAnim restoreOriginalFrame:YES],
                 [CCCallFunc actionWithTarget:self selector:@selector(sphereAnimEnded)],
                 nil];
    [sphere runAction:sphereSeq];
}

/* timer for rotor blue shadows */
- (void) alphaShadows:(ccTime)dt {
    int ranAlpha = [Utils randomNumberBetween:50 andMax:155];
    rotorLeftLight.opacity = ranAlpha;
    rotorRightLight.opacity = ranAlpha;
    sphereLight.opacity = ranAlpha;
}

#pragma mark 8 figures to base 
- (void) addFigures {    
    movableFigures = [[CCArray alloc] init];
    
    float pinchXpos[8] = {27.55, 66.11, 104.66, 143.22, 180.77, 218.33, 256.88, 294.44};
    
    for (int i = 0; i < 8; ++i) {
        Figure *figure = [[Figure alloc] initWithFigureType:i];
        figure.position = ccp(pinchXpos[i], 32.0f);
        figure.originalPosition = ccp(figure.position.x, figure.position.y);
        [figuresNode addChild:figure z:i];
        [movableFigures addObject:figure];
    }    
}

#pragma mark -
#pragma mark Targets for figures
#pragma mark Generate targets to array
- (void) generateTargets {
    targets = [[CCArray alloc] init];
    
    //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Level.plist"];
    for (int i = 0; i < currentDifficulty; ++i) {
        CCSprite *targetPoint = [CCSprite spriteWithSpriteFrameName:@"debug_center.png"];
        targetPoint.opacity = 255;
        [movableNode addChild:targetPoint z:100 + i];
        [targets addObject:targetPoint];
    }
}

#pragma mark Construct row with targets
- (void) constructRowWithIndex:(int)row {
    int i = 0;
    for (CCSprite *sprite in targets) {
        sprite.position = ccp(32.0 + i*difficultyPadding, 81.0 + row*44);
        i++; 
    }
}

#pragma mark -
#pragma mark Initialization of level
#pragma mark Composite method for starting level
- (void) createLevel {
    [self prepareAssets];
    [self addFigures];
    [self generateTargets];
    [self constructRowWithIndex:activeRow];
}

#pragma mark Enter&exit scene
- (void)onEnter {
    gestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)] autorelease];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:gestureRecognizer];
    [super onEnter];
}

- (void)onExit {
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:gestureRecognizer];
    [super onExit];
}

#pragma mark ***INIT***
- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
        currentDifficulty = [[GameManager sharedGameManager] currentDifficulty];
        activeRow = 3;
        [self createLevel];
        shit = YES;
    }
    return self;
}

#pragma mark -
#pragma mark Moving figures
- (void) selectSpriteForTouch:(CGPoint)touchLocation {
    Figure *newSprite = nil;
    for (Figure *sprite in movableFigures) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation) && sprite.isActive) {            
            newSprite = sprite;
            break;
        }
    }
    //[selSprite stopAllActions];
    //CCScaleTo *scale = [CCScaleTo actionWithDuration:.3 scale:1.4];
    //[newSprite runAction:scale];          
    selSprite = newSprite;
    if (selSprite) {
        [figuresNode reorderChild:selSprite z:selSprite.zOrder + 100];
    }   
}

- (void) panForTranslation:(CGPoint)translation {    
    if (selSprite) {
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        if (newPos.y < LEVEL_FIGURE_MAX_Y_MOVE)
            selSprite.position = newPos;
    }  
}

#pragma mark Detect target
- (void) activateTargetWithSprite:(CCSprite *)sprite andPlace:(int)place {
    if (targetSprite != sprite) {
        targetSprite = sprite;
        highlightSprite.visible = YES;
        highlightSprite.position = targetSprite.position;
        selSprite.place = place;
    }
}

- (void) detectTarget {
    if (selSprite) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        int i = 0;
        for (CCSprite *sprite in targets) {
            CGRect rect = CGRectMake(sprite.position.x, screenSize.height, sprite.boundingBox.size.width, 80 - screenSize.height);
            if (CGRectIntersectsRect(selSprite.boundingBox, rect)) {
                [self activateTargetWithSprite:sprite andPlace:i];
            }
            i++;
        } 
    }
}

#pragma mark Pan gestures handler
- (void) handlePan:(UIPanGestureRecognizer *)recognizer {    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];                
        [self selectSpriteForTouch:touchLocation];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        [self panForTranslation:translation];
        [self detectTarget];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {        
        CCLOG(@"Logic debug: touch ended");
    }        
}

#pragma mark -
#pragma mark Freeing memory
- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [movableFigures release];
    movableFigures = nil;
    [orangeLights release];
    orangeLights = nil;
    [greenLights release];
    greenLights = nil;
    
    [super dealloc];
}

@end