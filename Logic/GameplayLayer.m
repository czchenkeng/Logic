//
//  GameplayLayer.m
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameplayLayer.h"

@interface GameplayLayer (PrivateMethods)
- (void) createGame;
- (void) buildLevel;
- (void) addFigures;
- (void) generateCode;
- (void) generateTargets;
- (void) constructRowWithIndex:(int)row;
- (void) endGame;
- (void) nextRow;
- (void) showResult;
- (void) openLock;
- (void) calculateScore;
- (void) constructScoreLabel;
- (void) drawScoreToLabel;
@end

@implementation GameplayLayer

#pragma mark -
#pragma mark INIT CLASS
#pragma mark Designated initializer
- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
        currentDifficulty = [[GameManager sharedGameManager] currentDifficulty];
        activeRow = 0;
        isEndRow = NO;
        lastTime = 0;
        score = 0;
        targetSprite = nil;
        userCode = [[NSMutableArray alloc] init];
        placeNumbers = [[CCArray alloc] init];
        colorNumbers = [[CCArray alloc] init];
        scoreLabelArray = [[CCArray alloc] init];
        [self createGame];
    }
    return self;
}

#pragma mark Enter&exit scene
- (void)onEnter {
    panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)] autorelease];
    
    singleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    
    swipeRightRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)] autorelease];
    swipeRightRecognizer.delegate = self;
    
    //[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTapRecognizer];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panRecognizer];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:swipeRightRecognizer];
    //swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    //[swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp];
    //singleTapRecognizer.cancelsTouchesInView = NO;
    //panRecognizer.cancelsTouchesInView = NO;
    //[swipeRightRecognizer setCancelsTouchesInView:NO];
    //[panRecognizer requireGestureRecognizerToFail:swipeRightRecognizer];
    
    [super onEnter];
}

- (void)onExit {
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:panRecognizer];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:swipeRightRecognizer];
    //[[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:singleTapRecognizer];
    [super onExit];
}

#pragma mark -
#pragma mark GESTURES DELEGATE METHODS
#pragma mark Simultaneous
- (BOOL) gestureRecognizer:swipeRightRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:panRecognizer {
    return YES;
}

//- (BOOL) canBePreventedByGestureRecognizer:swipeRightRecognizer {
//    CCLOG(@"podminka");
//    return YES;
//}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CCLOG(@"podminka");
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan ||
       gestureRecognizer.state == UIGestureRecognizerStateChanged) 
    {
        //CCLOG(@"podminka NO");
        return NO;
    }
    else
    {
        //CCLOG(@"podminka YES");
        return YES;
    }
}


#pragma mark -
#pragma mark INITIALIZATION OF LEVEL
#pragma mark Composite method for starting level
- (void) createGame {
    [self buildLevel];
    [self addFigures];
    [self generateTargets];
    [self generateCode];
    [self constructScoreLabel];
    [self constructRowWithIndex:activeRow];
}

#pragma mark Build level
- (void) buildLevel {
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
    clippingNode = [CCLayer node];
    deadFiguresNode = [CCLayer node];
    Mask *deadFiguresNodeMask = [Mask maskWithRect:CGRectMake(0, LEVEL_DEAD_FIGURES_MASK_HEIGHT, 320, 480 - LEVEL_DEAD_FIGURES_MASK_HEIGHT)];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"LevelBg%@.plist", hw]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Level%@.plist", hw]];    
    sphereNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"Animations%@.pvr.ccz", hw]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Animations%@.plist", hw]];
    
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
            CCLOG(@"Logic debug: Unknown difficulty ID, cannot create string");
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
    
//    rotorLeftLayer = [CCLayer node];
//    rotorRightLayer = [CCLayer node];
    rotorLeftLayer = [CCSprite node];
    rotorRightLayer = [CCSprite node];
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
    
    //score, time
    scoreTime = [CCLayer node];
    CCSprite *scoreTimeSprite = [CCSprite spriteWithSpriteFrameName:@"logik_score_time.png"];
    scoreTimeSprite.anchorPoint = CGPointMake(0.5, 1);
    scoreTimeSprite.position = ccp(160.00, 480.50);
    
    Mask *timerMask = [Mask maskWithRect:CGRectMake(279, 456.00, 39.5, 18)];
    timer = [[ProgressTimer alloc] init];
    
    CCSprite *scoreBlackBg = [CCSprite spriteWithSpriteFrameName:@"score_black_bg.png"];
    scoreBlackBg.position = ccp(36.00, 466.50);
    CCSprite *timeBlackBg = [CCSprite spriteWithSpriteFrameName:@"time_black_bg.png"];
    timeBlackBg.position = ccp(300.50, 466.00);
    
    scoreLayer = [CCLayer node];
    
    
    //green & orange lights, places & colors status
    for(int i = 0; i < 10; ++i){
        CCSprite *greenLight = [CCSprite spriteWithSpriteFrameName:@"greenLight.png"];
        greenLight.position = ccp(288, 82 + i*44);
        greenLight.opacity = 0;
        [movableNode addChild:greenLight z:i tag:i];
        [greenLights addObject:greenLight];
        RowStaticScore *pss = [[RowStaticScore alloc] init];
        pss.position = ccp(greenLight.position.x - 3, greenLight.position.y + 8);
        [clippingNode addChild:pss z:1-i];
        [placeNumbers addObject:pss];
        
        
        CCSprite *orangeLight = [CCSprite spriteWithSpriteFrameName:@"orangeLight.png"];
        orangeLight.position = ccp(308, 82 + i*44);
        orangeLight.opacity = 0;
        [movableNode addChild:orangeLight z:i + 10 tag:i + 10];
        [orangeLights addObject:orangeLight];
        RowStaticScore *css = [[RowStaticScore alloc] init];
        css.position = ccp(orangeLight.position.x - 5, orangeLight.position.y + 8);
        [clippingNode addChild:css z:1-i];
        [colorNumbers addObject:css];
    }
    
    //Pause
    CCSprite *buttonPauseOff = [CCSprite spriteWithSpriteFrameName:@"logik_pauza_01.png"];
    CCSprite *buttonPauseOn = [CCSprite spriteWithSpriteFrameName:@"logik_pauza_02.png"];    
    CCMenuItem *pauseItem = [CCMenuItemSprite itemFromNormalSprite:buttonPauseOff selectedSprite:buttonPauseOn target:self selector:@selector(pauseTapped:)];
    pauseItem.tag = kButtonPause;
    pauseItem.anchorPoint = CGPointMake(0.5, 1);
    pauseItem.position = ccp(152.00, 481.00);    
    pauseMenu = [CCMenu menuWithItems:pauseItem, nil];
    pauseMenu.position = CGPointZero;
    
    //add nodes to display list
    [self addChild:movableNode z:2 tag:2];
        [movableNode addChild:bg z:-1 tag:-1];
        [movableNode addChild:highlightSprite z:200];
        [movableNode addChild:deadFiguresNodeMask z:1];
            [deadFiguresNodeMask addChild:deadFiguresNode];
    [self addChild:codeBase z:3 tag:3];
    [self addChild:clippingNode z:4 tag:1];
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
    [self addChild:scoreTime z:12];
        [scoreTime addChild:scoreBlackBg z:1];
        [scoreTime addChild:timeBlackBg z:2];
        [scoreTime addChild:scoreLayer z:3];
        [scoreTime addChild:timerMask z:4];
            [timerMask addChild:timer z:1];
        [scoreTime addChild:scoreTimeSprite z:5];
    [self addChild:pauseMenu z:20];

    
    dustSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"dust1.plist"];
    [self addChild:dustSystem z:1000];
    
//    smokeSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"smoke.plist"];
//    [self addChild:smokeSystem z:1001];
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

#pragma mark Generate game code 
- (void) generateCode {
    CCLOG(@"**************************************************************");
    CCLOG(@"***********************CODE***********************************");
    currentCode = [[NSMutableArray alloc] init];
    for (int i = 0; i < currentDifficulty; ++i) {
        int cheatCode = [Utils randomNumberBetween:0 andMax:8];
        switch (cheatCode) {
            case kYellow: 
                CCLOG(@"YELLOW");
                break;
            case kOrange:
                CCLOG(@"ORANGE");
                break;
            case kPink:
                CCLOG(@"PINK");
                break;
            case kRed:
                CCLOG(@"RED");
                break;
            case kPurple:
                CCLOG(@"PURPLE");
                break;
            case kBlue:
                CCLOG(@"BLUE");
                break;
            case kGreen:
                CCLOG(@"GREEN");
                break;
            case kWhite:
                CCLOG(@"WHITE");
                break;
            default:
                CCLOG(@"Unknown ID, cannot print code");
                break;
        }
        
        //Figure *figure = [[Figure alloc] initWithFigureType:[Utils randomNumberBetween:0 andMax:8]];
        Figure *figure = [[Figure alloc] initWithFigureType:cheatCode];
        figure.place = i;
        figure.anchorPoint = CGPointMake(0, 0);
        figure.position = ccp(6 + difficultyPadding*i, 10.0f);
        
        //        Figure *cheatFigure = [[Figure alloc] initWithFigureType:cheatCode];
        //        cheatFigure.anchorPoint = CGPointMake(0, 0);
        //        cheatFigure.position = ccp(6 + difficultyPadding*i, 10.0f);
        //        cheatFigure.opacity = 150;
        
        [codeBase addChild:figure z:i];
        //[cheat addChild:cheatFigure z:i];
        [currentCode addObject:figure];
    }
    CCLOG(@"***********************END CODE*******************************");
    CCLOG(@"**************************************************************");
}

#pragma mark Construct score Label
- (void) constructScoreLabel {
    for (int i = 0; i<8; i++) {
        Mask *scoreMask = [Mask maskWithRect:CGRectMake(9*i, 456.50, 9, 18)];
        [scoreLayer addChild:scoreMask z:i];
        ScoreNumber *scoreNumber = [[ScoreNumber alloc] init];
        [scoreMask addChild:scoreNumber];
        [scoreLabelArray addObject:scoreNumber];
    }
    [scoreLabelArray reverseObjects];
}

#pragma mark -
#pragma mark TARGETS FOR FIGURES
#pragma mark Generate targets to array
- (void) generateTargets {
    targets = [[CCArray alloc] init];
    for (int i = 0; i < currentDifficulty; ++i) {
        CCSprite *targetPoint = [CCSprite spriteWithSpriteFrameName:@"debug_center.png"];
        targetPoint.opacity = 0;
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
#pragma mark CALLBACK METHODS
#pragma mark Sphere, shadows & pause button
- (void) sphereAnimEnded {
    float delay = 1.0 / (float)[Utils randomNumberBetween:10 andMax:20];
    [sphere stopAllActions];
    [sphereAnim setDelay:delay];
    sphereSeq = [CCSequence actions:
                 [CCAnimate actionWithAnimation:sphereAnim restoreOriginalFrame:YES],
                 [CCCallFunc actionWithTarget:self selector:@selector(sphereAnimEnded)],
                 nil];
    [sphere runAction:sphereSeq];
}

#pragma mark Shadows
- (void) alphaShadows:(ccTime)dt {
    int ranAlpha = [Utils randomNumberBetween:50 andMax:155];
    rotorLeftLight.opacity = ranAlpha;
    rotorRightLight.opacity = ranAlpha;
    sphereLight.opacity = ranAlpha;
}

#pragma mark Pause button
- (void) pauseTapped:(CCMenuItem *)sender { 
    //[[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kSlideInR];
    CCLOG(@"pause tapped");
    [self endGame];
}

#pragma mark -
#pragma mark END GAME
#pragma mark Composite method
- (void) endGame {
    CCLOG(@"Logic debug: END GAME");
    [[[GameManager sharedGameManager] gameData] writeScore:[Utils randomNumberBetween:1000 andMax:99999999] andDifficulty:currentDifficulty];
    [self openLock];
}

#pragma mark Open lock animations
- (void) openLock {    
    float delay = 0.00;
    
    //faze 1
    CCMoveTo *rightRotorOut = [CCMoveTo actionWithDuration:delay + 0.1 position:ccp(rotorRightLayer.position.x + 15, rotorRightLayer.position.y)];
    CCMoveTo *leftRotorOut = [CCMoveTo actionWithDuration:delay + 0.1 position:ccp(rotorLeftLayer.position.x - 15, rotorLeftLayer.position.y)];
    CCSequence *rotorRightSeq1 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.2f], rightRotorOut, nil];
    CCSequence *rotorLeftSeq1 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.2f], leftRotorOut, nil];
    
    //faze 2
    CCScaleTo *rightRotorScale = [CCScaleTo actionWithDuration:delay + 0.4 scale:1.4];
    CCScaleTo *leftRotorScale = [CCScaleTo actionWithDuration:delay + 0.4 scale:1.4];
    CCScaleTo *sphereScale = [CCScaleTo actionWithDuration:delay + 0.4 scale:1.4];
    CCMoveTo *sphereMoveBack = [CCMoveTo actionWithDuration:delay + 0.4 position:ccp(sphereNode.position.x, sphereNode.position.y + 15)];
    CCScaleTo *lightScale = [CCScaleTo actionWithDuration:delay + 0.4 scale:1.4];
    CCMoveTo *lightMoveBack = [CCMoveTo actionWithDuration:delay + 0.4 position:ccp(sphereLight.position.x, sphereLight.position.y + 15)];
    CCFadeTo *lightFade = [CCFadeTo actionWithDuration:delay + 0.4 opacity:120];
    CCMoveTo *rightRotorToRightAndBack = [CCMoveTo actionWithDuration:delay + 0.4 position:ccp(rotorRightLayer.position.x + 50, rotorRightLayer.position.y - 15)];
    CCMoveTo *leftRotorToLeftAndBack = [CCMoveTo actionWithDuration:delay + 0.4 position:ccp(rotorLeftLayer.position.x - 50, rotorLeftLayer.position.y - 15)];
    CCSpawn *rightRotorSpawn = [CCSpawn actions: rightRotorScale, rightRotorToRightAndBack, nil];
    CCSpawn *leftRotorSpawn = [CCSpawn actions: leftRotorScale, leftRotorToLeftAndBack, nil];
    CCSpawn *sphereSpawn = [CCSpawn actions: sphereScale, sphereMoveBack, nil];
    CCSpawn *lightSpawn = [CCSpawn actions: lightScale, lightMoveBack, lightFade, nil];
    CCSequence *rotorRightSeq2 = [CCSequence actions:[CCDelayTime actionWithDuration: delay + 0.5f], rightRotorSpawn, nil];
    CCSequence *rotorLeftSeq2 = [CCSequence actions:[CCDelayTime actionWithDuration: delay + 0.5f], leftRotorSpawn, nil];
    CCSequence *sphereScaleSeq2 = [CCSequence actions:[CCDelayTime actionWithDuration: delay + 0.5f], sphereSpawn, nil];
    CCSequence *lightSeq2 = [CCSequence actions:[CCDelayTime actionWithDuration: delay + 0.5f], lightSpawn, nil];
    
    //faze 3
    CCScaleTo *rightRotorScale2 = [CCScaleTo actionWithDuration:delay + 0.2 scale:1.5];
    CCScaleTo *leftRotorScale2 = [CCScaleTo actionWithDuration:delay + 0.2 scale:1.5];
    CCMoveTo *rightRotorToRightAndBack2 = [CCMoveTo actionWithDuration:delay + 0.4 position:ccp(rotorRightLayer.position.x + 60, rotorRightLayer.position.y + 8)];
    CCMoveTo *leftRotorToLeftAndBack2 = [CCMoveTo actionWithDuration:delay + 0.4 position:ccp(rotorLeftLayer.position.x - 60, rotorLeftLayer.position.y + 8)];
    CCScaleTo *sphereScale2 = [CCScaleTo actionWithDuration:delay + 0.4 scale:1.5];
    CCMoveTo *sphereMoveBack2 = [CCMoveTo actionWithDuration:delay + 0.4 position:ccp(sphereNode.position.x, sphereNode.position.y + 30)];
    CCSpawn *rightRotorSpawn2 = [CCSpawn actions: rightRotorScale2, rightRotorToRightAndBack2, nil];
    CCSpawn *leftRotorSpawn2 = [CCSpawn actions: leftRotorScale2, leftRotorToLeftAndBack2, nil];
    CCSpawn *sphereSpawn2 = [CCSpawn actions: sphereScale2, sphereMoveBack2, nil];
    CCSequence *rotorRightSeq3 = [CCSequence actions:[CCDelayTime actionWithDuration: delay + 0.9f], rightRotorSpawn2, nil];
    CCSequence *rotorLeftSeq3 = [CCSequence actions:[CCDelayTime actionWithDuration: delay + 0.9f], leftRotorSpawn2, nil];
    CCSequence *sphereScaleSeq3 = [CCSequence actions:[CCDelayTime actionWithDuration: delay + 0.9f], sphereSpawn2, nil];
    CCMoveTo *mantleBack = [CCMoveTo actionWithDuration:delay + 0.8 position:ccp(mantle.position.x, mantle.position.y + 60)];
    CCSequence *mantleSeq = [CCSequence actions:[CCDelayTime actionWithDuration: delay + 0.9f], mantleBack, nil];
    
    CCSequence *moveSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(movableNode.position.x, movableNode.position.y - 47)],
                           nil];
    CCSequence *codeSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(codeBase.position.x, codeBase.position.y - 47)],
                           nil];
    CCSequence *figSeq = [CCSequence actions:
                          [CCDelayTime actionWithDuration: delay + 1.3f],
                          [CCMoveTo actionWithDuration:.4 position:CGPointMake(figuresNode.position.x, figuresNode.position.y - 49)],
                          nil];
    CCSequence *baseSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(base.position.x, base.position.y - 49)],
                           nil];
    
    CCSequence *clippingSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(base.position.x, base.position.y - 49)],
                           nil];
    
    CCSequence *scoreSeq = [CCSequence actions:
                               [CCDelayTime actionWithDuration: delay + 0.0f],
                               [CCMoveTo actionWithDuration:.4 position:CGPointMake(base.position.x, base.position.y + 30)],
                               nil];
    CCSequence *pauseSeq = [CCSequence actions:
                            [CCDelayTime actionWithDuration: delay + 0.0f],
                            [CCMoveTo actionWithDuration:.4 position:CGPointMake(base.position.x, base.position.y + 60)],
                            nil];
    
    scoreLayer.visible = NO;
    timer.visible = NO;
    
    [rotorRightLayer runAction:rotorRightSeq1];
    [rotorLeftLayer runAction:rotorLeftSeq1];
    [rotorRightLayer runAction:rotorRightSeq2];
    [rotorLeftLayer runAction:rotorLeftSeq2];
    [sphereNode runAction:sphereScaleSeq2];
    [sphereLight runAction:lightSeq2];
    [rotorRightLayer runAction:rotorRightSeq3];
    [rotorLeftLayer runAction:rotorLeftSeq3];
    [sphereNode runAction:sphereScaleSeq3];
    [mantle runAction:mantleSeq];
    [movableNode runAction:moveSeq];
    [codeBase runAction:codeSeq];
    [figuresNode runAction:figSeq];
    [base runAction:baseSeq];
    [clippingNode runAction:clippingSeq];
    [scoreTime runAction:scoreSeq];
    [pauseMenu runAction:pauseSeq];
    
    
    
    //temporary end screen
//    CCSprite *buttonFbOff = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb1.png"];
//    CCSprite *buttonFbOn = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb2.png"];
//    
//    CCMenuItem *fbItem = [CCMenuItemSprite itemFromNormalSprite:buttonFbOff selectedSprite:buttonFbOn target:self selector:@selector(fbTapped:)];
//    fbItem.tag = kButtonFb;
//    fbItem.position = ccp(100.00, 300.00);
//    
//    CCMenu *finalMenu = [CCMenu menuWithItems:fbItem, nil];
//    finalMenu.position = CGPointZero;
    //[self addChild:finalMenu z:20];
    
    //end temp screen
}

#pragma mark -
#pragma mark END ROW
#pragma mark Result algorithm
- (void) endOfRow {
    colors = 0;
    places = 0;
    int i = 0;
    
    for (Figure *codeSprite in currentCode) {
        for (Figure *userSprite in userCode) {
            if (userSprite.place == i) {
                if (userSprite.currentFigure == codeSprite.currentFigure) {
                    places++;
                }
            }
        }
        i++;
    }
    
    for (Figure *codeSprite in currentCode) {
        for (Figure *userSprite in userCode) {
            if (codeSprite.currentFigure == userSprite.currentFigure && !userSprite.isCalculated) {
                userSprite.isCalculated = YES;
                colors++;
                break;
            }
        }    
    }
    
    colors = colors - places;
    
    CCLOG(@"Logic debug: PLACES %i AND COLORS %i", places, colors);
    [self showResult];
    [self calculateScore];
    if (places == currentDifficulty || activeRow == 9) {
        [self endGame];
    } else {
        [self nextRow];
    }
}

- (void) showResult {
    CCSprite *greenLight = [greenLights objectAtIndex:activeRow];
    if (places > 0) {
        id fadeToGreen = [CCFadeTo actionWithDuration:0.5f opacity:255];
        [greenLight runAction:fadeToGreen]; 
    }   
    RowStaticScore *place = [placeNumbers objectAtIndex:activeRow];
    [place showNumber:places];
    //Mask *holderPlace = [Mask maskWithRect:CGRectMake(greenLight.position.x - 3, greenLight.position.y + 8 - dislocation, 9, 18)];//DISLOCATION
    Mask *holderPlace = [Mask maskWithRect:CGRectMake(greenLight.position.x - 3, greenLight.position.y + 8, 9, 18)];
    [clippingNode addChild:holderPlace z:21 + activeRow];
    RowScore *rs = [[RowScore alloc] init];
    [holderPlace addChild:rs z:1];
    [rs moveToPosition:places andMask:holderPlace];
    
    
    CCSprite *orangeLight = [orangeLights objectAtIndex:activeRow];
    if (colors > 0) {
        id fadeToOrange = [CCFadeTo actionWithDuration:0.5f opacity:255];
        [orangeLight runAction:fadeToOrange];
    }    
    RowStaticScore *color = [colorNumbers objectAtIndex:activeRow];
    [color showNumber:colors];
    //Mask *holderColors = [Mask maskWithRect:CGRectMake(orangeLight.position.x - 5, orangeLight.position.y + 8 - dislocation, 9, 18)];//DISLOCATION
    Mask *holderColors = [Mask maskWithRect:CGRectMake(orangeLight.position.x - 5, orangeLight.position.y + 8, 9, 18)];
    [clippingNode addChild:holderColors z:21 + activeRow];
    RowScore *rc = [[RowScore alloc] init];
    [holderColors addChild:rc z:1];
    [rc moveToPosition:colors andMask:holderColors];
}

- (void) calculateScore {
    lastTime = timer.gameTime - lastTime;
    //CCLOG(@"ACTIVE ROW %i", activeRow + 1);
    //CCLOG(@"GAME TIME %i", lastTime);
    //float sc = 264000 * ( (10 / (activeRow + 1)) + ( 25 / lastTime ) - 1 );
    float sc = 264000 * ( (10 / (activeRow + 1)) + ( 25 / 50 ) - 1 );
    int diffCoef;
    switch (currentDifficulty) {
        case kEasy:
            diffCoef = 64;
            break;
        case kMedium:
            diffCoef = 8;
            break;
        case kHard:
            diffCoef = 1;
            break;
    }
    sc /= diffCoef;
    score += (int)sc;
    
    CCLOG(@"AND SCORE IS %i", score);
    [self drawScoreToLabel];    
}

- (void) drawScoreToLabel {
    NSString *scoreString = [NSString stringWithFormat:@"%i", score];
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[scoreString length]];
    for (int i=0; i < [scoreString length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [scoreString characterAtIndex:i]];
        [characters addObject:ichar];
    }
    ScoreNumber *tempScoreNumber;
    for (int i=0; i < [characters count]; i++) {
        tempScoreNumber = [scoreLabelArray objectAtIndex:i];
        [tempScoreNumber moveToPosition:[[[[characters reverseObjectEnumerator] allObjects] objectAtIndex:i] intValue]];
    }
}

- (void) nextRow {
    [userCode removeAllObjects];
    activeRow ++;
    [self constructRowWithIndex:activeRow];
//    if (currAreaPos == 1) {
//        [self swipeArea:1];
//    }
//    if (activeRow == LEVEL_SWIPE_AFTER_ROW) {
//        isMovable = YES;
//        //movableFlag = YES;
//        dislocation = LEVEL_DISLOCATION;
//        //currAreaPos ++;
//        [self swipeArea:1];
//    }
}

- (void) generateDeadRow {
    for (Figure *userSprite in userCode) {
        Figure *deadFigure = [[Figure alloc] initWithFigureType:userSprite.currentFigure];
        //CGPoint newPos = ccp(userSprite.position.x, userSprite.position.y + dislocation - LEVEL_DEAD_FIGURES_MASK_HEIGHT);//DISLOCATION
        CGPoint newPos = ccp(userSprite.position.x, userSprite.position.y - LEVEL_DEAD_FIGURES_MASK_HEIGHT);
        deadFigure.position = newPos;
        [deadFiguresNode addChild:deadFigure z:2000];//mrknout na z-index
        [movableFigures removeObject:userSprite];
        [userSprite destroy];        
        //[[[GameManager sharedGameManager] gameData] insertDeadFigure://SQL for save game
    }
}

#pragma mark -
#pragma mark DETECT TARGET
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

#pragma mark -
#pragma mark END FIGURE MOVE
- (void) figureMoveEnded:(id)sender data:(Figure *)sprite {    
    highlightSprite.visible = NO;
    
    //new figure to base
    Figure *figure = [[Figure alloc] initWithFigureType:sprite.currentFigure];
    figure.position = sprite.originalPosition;
    figure.position = ccp(sprite.originalPosition.x, sprite.originalPosition.y - 40);
    figure.originalPosition = ccp(sprite.originalPosition.x, sprite.originalPosition.y);
    [figuresNode addChild:figure z:movableFigures.count + 1];
    [movableFigures addObject:figure];
    CCMoveTo *moveToBase = [CCMoveTo actionWithDuration:.2 position:CGPointMake(figure.position.x, figure.originalPosition.y)];
    [figure runAction:moveToBase];
    
    sprite.isOnActiveRow = YES;
    sprite.oldPlace = sprite.place;
    //sprite.tempPosition = ccp(sprite.position.x, sprite.position.y + dislocation);//DISLOCATION
    sprite.tempPosition = ccp(sprite.position.x, sprite.position.y);
    
    Figure *tempSprite = nil;
    for (Figure *userSprite in userCode) {
        if (userSprite.place == sprite.place) {
            tempSprite = userSprite;
        }
    }
    if (tempSprite) {
        [userCode removeObject:tempSprite];
        [movableFigures removeObject:tempSprite];
        [tempSprite destroy];
    }
    
    [userCode addObject:sprite];
    
    [figuresNode reorderChild:selSprite z:sprite.zOrder - 100];
    
    if (userCode.count == currentDifficulty) {
        isEndRow = YES;
    }
}

- (void) swapFigure:(Figure *)sprite {
    highlightSprite.visible = NO;
    Figure *existSprite = nil;
    for (Figure *userSprite in userCode) {
        if (userSprite.oldPlace == sprite.place) {
            existSprite = userSprite;
        }
    }
    if (existSprite) {
        existSprite.place = sprite.oldPlace;
        existSprite.oldPlace = sprite.oldPlace;
        existSprite.position = sprite.tempPosition;
        //existSprite.tempPosition = ccp(sprite.tempPosition.x, sprite.tempPosition.y + dislocation);
        existSprite.tempPosition = ccp(sprite.tempPosition.x, sprite.tempPosition.y);
    }
    sprite.oldPlace = sprite.place;
}

- (void) figureSetCorrectPosition:(id)sender data:(Figure *)sprite {
    //sprite.tempPosition = ccp(sprite.position.x, sprite.position.y + dislocation);
    sprite.tempPosition = ccp(sprite.position.x, sprite.position.y);
    [figuresNode reorderChild:selSprite z:sprite.zOrder - 100];
}

#pragma mark -
#pragma mark GESTURES METHODS & CALLBACKS
- (void) selectSpriteForTouch:(CGPoint)touchLocation {
    Figure *newSprite = nil;
    for (Figure *sprite in movableFigures) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation) && sprite.isActive) {            
            newSprite = sprite;
            break;
        }
    }
    //[selSprite stopAllActions];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:.3 scale:1.4];
    [newSprite runAction:scale];          
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

- (void) endTouch {
    if (selSprite) {
        CCScaleTo *scale = [CCScaleTo actionWithDuration:.3 scale:1.0];
        [selSprite runAction:scale];        
        if (targetSprite != nil) {//animation to target
            CCSequence *moveSeq;
            if (selSprite.isOnActiveRow) {
                [self swapFigure:selSprite];
                moveSeq = [CCSequence actions:
                           //[CCMoveTo actionWithDuration:.03*activeRow position:CGPointMake(targetSprite.position.x + 1, targetSprite.position.y + 5 - dislocation)],//DISLOCATION
                           [CCMoveTo actionWithDuration:.03*activeRow position:CGPointMake(targetSprite.position.x + 1, targetSprite.position.y + 5)],
                           [CCCallFuncND actionWithTarget:self selector:@selector(figureSetCorrectPosition:data:) data:selSprite],
                           nil];
            } else {
                moveSeq = [CCSequence actions:
                           //[CCMoveTo actionWithDuration:.03*activeRow position:CGPointMake(targetSprite.position.x + 1, targetSprite.position.y + 5 - dislocation)],//DISLOCATION
                           [CCMoveTo actionWithDuration:.03*activeRow position:CGPointMake(targetSprite.position.x + 1, targetSprite.position.y + 5)],
                           [CCCallFuncND actionWithTarget:self selector:@selector(figureMoveEnded:data:) data:selSprite],//najit v zalozkach modernejsi zpusob jak volat callback!!!!!!!!!!!!!!!!!!!
                           nil];
            }
            [selSprite runAction:moveSeq];
        } else {//animation back to base
            CCMoveTo *moveBack = [CCMoveTo actionWithDuration:.3 position:CGPointMake(selSprite.originalPosition.x, selSprite.originalPosition.y)];
            [selSprite runAction:moveBack];
            [figuresNode reorderChild:selSprite z:selSprite.zOrder - 100];
        }
        targetSprite = nil;
    }
}

#pragma mark -
#pragma mark UIGesture RECOGNIZER HANDLERS
#pragma mark Touch gestures handler
- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CCLOG(@"SINGLE TOUCH");
//    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
//    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
//    touchLocation = [self convertToNodeSpace:touchLocation];                
//    [self selectSpriteForTouch:touchLocation];
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
        [self endTouch];
    }
//    if (recognizer.state == UIGestureRecognizerStateChanged) {        
//        CGPoint translation = [recognizer translationInView:recognizer.view];
//        translation = ccp(translation.x, -translation.y);
//        [self panForTranslation:translation];
//        [self detectTarget];
//        [recognizer setTranslation:CGPointZero inView:recognizer.view];
//    } else if (recognizer.state == UIGestureRecognizerStateEnded) {        
//        CCLOG(@"Logic debug: touch ended");
//    }
}

- (void) handleSwipe:(UISwipeGestureRecognizer *)recognizer {
    if (isEndRow) {
        isEndRow = NO;
        [self generateDeadRow];
        [self endOfRow];
    }
    CCLOG(@"DIRECTION %i", recognizer.direction);
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        CCLOG(@"SWIPE RIGHT");
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        CCLOG(@"SWIPE UP");
    }
}

#pragma mark -
#pragma mark FREEING MEMORY
- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [movableFigures release];
    movableFigures = nil;
    [orangeLights release];
    orangeLights = nil;
    [greenLights release];
    greenLights = nil;
    [currentCode dealloc];
    currentCode = nil;
    [userCode dealloc];
    userCode = nil;
    
    [super dealloc];
}

@end