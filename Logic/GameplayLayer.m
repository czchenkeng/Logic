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
- (void) jumpGamePlay;
- (void) showResult;
- (void) showColors:(id)sender data:(NSNumber *)rowObj;
- (void) openLock;
- (void) calculateScore;
- (void) constructScoreLabelWithLayer:(CCLayer *)layer andArray:(CCArray *)array andRotation:(float)rotation andXpos:(float)xPos andYPos:(float)yPos;
- (void) drawScoreToLabel:(int)value andArray:(CCArray *)array;
- (void) constructEndLabels:(int)time;
- (void) moves:(float)delay;
- (void) timeBonus:(float)delay;
@end

@implementation GameplayLayer

#pragma mark -
#pragma mark INIT
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
        isMovable = NO;
        trans = 0;
        isWinner = NO;
        isCareer = NO;
        CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
        isRetina = screenSize.height == 960.0f ? YES : NO;
        maxScore = [[[GameManager sharedGameManager] gameData] getMaxScore:currentDifficulty];
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
    
    longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)] autorelease];
    longPress.minimumPressDuration = LEVEL_MIN_PRESS_DURATION;
    longPress.delegate = self;
    
    longPress.cancelsTouchesInView = NO;
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panRecognizer];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:longPress];
    
    [super onEnter];
}

- (void)onExit {
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:panRecognizer];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:longPress];
    [super onExit];
}

#pragma mark -
#pragma mark GESTURES DELEGATE METHODS
#pragma mark Simultaneous
- (BOOL) gestureRecognizer:longPress shouldRecognizeSimultaneouslyWithGestureRecognizer:panRecognizer {
    return YES;
}

//- (BOOL) canBePreventedByGestureRecognizer:swipeRightRecognizer {
//    CCLOG(@"podminka");
//    return YES;
//}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    //CCLOG(@"podminka");
//    if(gestureRecognizer.state == UIGestureRecognizerStateBegan ||
//       gestureRecognizer.state == UIGestureRecognizerStateChanged) 
//    {
//        //CCLOG(@"podminka NO");
//        return NO;
//    }
//    else
//    {
//        //CCLOG(@"podminka YES");
//        return YES;
//    }
//}


#pragma mark -
#pragma mark INITIALIZATION OF LEVEL
#pragma mark Composite method for starting level
- (void) createGame {
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_LEVEL];
    gameInfo infoData;
    if ([[GameManager sharedGameManager] gameInProgress]) {
        infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        currentDifficulty = infoData.difficulty;
        activeRow = infoData.activeRow;
        CCLOG(@"co je v career? %i", infoData.career);
        isCareer = infoData.career == 0 ? NO : YES;
        CCLOG(@"pokus nacist data %i %i %i", infoData.activeRow, infoData.difficulty, infoData.career);
    } else {
        infoData.difficulty = currentDifficulty;
        infoData.activeRow = 0;
        infoData.career = 0;
        [[[GameManager sharedGameManager] gameData] insertGameData:infoData];
        //[GameManager sharedGameManager].gameInProgress = YES;//prenest do game data classy?
    }
    
    [self buildLevel];
    [self addFigures];
    [self generateTargets];
    [self generateCode];
    [self constructScoreLabelWithLayer:scoreLayer andArray:scoreLabelArray andRotation:0 andXpos:0 andYPos:456.50];
    [self constructRowWithIndex:activeRow];
    
    if (isCareer) {
        CCLOG(@"career here");
    } else {
        CCLOG(@"no career");
    }
    
//    blackout = [Blackout node];
//    [blackout setOpacity:0.9f];
//    id fadeOut = [CCFadeTo actionWithDuration:.7 opacity:0.8];
//    id fadeSeq = [CCSequence actions:fadeOut,[CCCallFunc actionWithTarget:self selector:@selector(blackoutCallback)], nil];
//    [self addChild:blackout z:100];
    //[blackout runAction:fadeSeq];
    
    if ([[GameManager sharedGameManager] gameInProgress]) {
        NSMutableArray *deadFigures = [[[GameManager sharedGameManager] gameData] getDeadFigures];
        if ([deadFigures count] > 0) {
            for (Figure *figure in deadFigures) {
                figure.position = figure.tempPosition;
                [deadFiguresNode addChild:figure z:2000];
            }
        }
        
        NSMutableArray *rows = [[[GameManager sharedGameManager] gameData] getRows];
        if ([rows count] > 0) {
            int dataRow;
            int dataPlaces;
            int dataColors;
            for (NSMutableDictionary *dict in rows) {
                CCLOG(@"row is %i", [[dict objectForKey:@"row"] intValue]);
                CCLOG(@"places are %i", [[dict objectForKey:@"places"] intValue]);
                CCLOG(@"colors are %i", [[dict objectForKey:@"colors"] intValue]);
                dataRow = [[dict objectForKey:@"row"] intValue];
                dataPlaces = [[dict objectForKey:@"places"] intValue];
                dataColors = [[dict objectForKey:@"colors"] intValue];
                //tohle do jedne funkce sjednotit s normalni hrou
                CCSprite *greenLight = [greenLights objectAtIndex:dataRow];
                if (dataPlaces > 0) {
                    id fadeToGreen = [CCFadeTo actionWithDuration:0.5f opacity:255];
                    [greenLight runAction:fadeToGreen];
                }
                    
                RowStaticScore *place = [placeNumbers objectAtIndex:dataRow];
                [place showNumber:dataPlaces];
                Mask *holderPlace = [Mask maskWithRect:CGRectMake(greenLight.position.x - 3, greenLight.position.y + 8, 9, 18)];
                [clippingNode addChild:holderPlace z:21 + dataRow];
                RowScore *rs = [[RowScore alloc] init];
                [holderPlace addChild:rs z:1];
                [rs moveToPosition:dataPlaces andMask:holderPlace];
                
                CCSprite *orangeLight = [orangeLights objectAtIndex:dataRow];
                if (dataColors > 0) {
                    id fadeToOrange = [CCFadeTo actionWithDuration:0.5f opacity:255];
                    [orangeLight runAction:fadeToOrange];
                }
                    
                RowStaticScore *color = [colorNumbers objectAtIndex:dataRow];
                [color showNumber:dataColors];
                Mask *holderColors = [Mask maskWithRect:CGRectMake(orangeLight.position.x - 5, orangeLight.position.y + 8, 9, 18)];
                [clippingNode addChild:holderColors z:21 + dataRow];
                RowScore *rc = [[RowScore alloc] init];
                [holderColors addChild:rc z:1];
                [rc moveToPosition:dataColors andMask:holderColors];
            }
        }
        [GameManager sharedGameManager].gameInProgress = YES;
        [self jumpGamePlay];
        
        [deadFigures release];
        deadFigures = nil;
        [rows release];
        rows = nil;
    }
}

- (void) blackoutCallback {
    //[blackout removeFromParentAndCleanup:YES];
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
    
    timerMask = [Mask maskWithRect:CGRectMake(279, 456.00, 39.5, 18)];
    timer = [[ProgressTimer alloc] init];
    finalTimeLayer = [CCLayer node];
    
    CCSprite *scoreBlackBg = [CCSprite spriteWithSpriteFrameName:@"score_black_bg.png"];
    scoreBlackBg.position = ccp(36.00, 466.50);
    CCSprite *timeBlackBg = [CCSprite spriteWithSpriteFrameName:@"time_black_bg.png"];
    timeBlackBg.position = ccp(300.50, 466.00);
    
    scoreLayer = [CCLayer node];
    finalScoreLayer = [CCLayer node];
    
    
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
    
    //end game menu
    CCSprite *buttonEndOff = [CCSprite spriteWithSpriteFrameName:@"end_off.png"];
    CCSprite *buttonEndOn = [CCSprite spriteWithSpriteFrameName:@"end_on.png"];
    CCMenuItem *endGameItem = [CCMenuItemSprite itemFromNormalSprite:buttonEndOff selectedSprite:buttonEndOn target:self selector:@selector(endGameTapped:)];
    
    endGameItem.tag = kButtonEndGame;
    endGameItem.anchorPoint = CGPointMake(0.5, 1);
    endGameItem.position = ccp(152.00, 541.00);    
    endGameMenu = [CCMenu menuWithItems:endGameItem, nil];
    endGameMenu.position = CGPointZero;
    
    //panels
    scorePanel = [CCSprite spriteWithSpriteFrameName:@"panel_score.png"];
    scorePanel.scaleX = 5;
    scorePanel.scaleY = 22;
    scorePanel.visible = NO;
    [scorePanel setPosition:ccp(-700.00, 0.00)];
    
    
    replayPanel = [CCSprite spriteWithSpriteFrameName:@"rameno_right.png"];
    replayPanel.scaleX = 5;
    replayPanel.scaleY = 22;
    replayPanel.visible = NO;
    [replayPanel setPosition:ccp(1000.00, 367.00)];
    
    gameMenuLeftPanel = [CCSprite spriteWithSpriteFrameName:@"rameno_left.png"];
    gameMenuLeftPanel.scaleX = 5;
    gameMenuLeftPanel.scaleY = 22;
    gameMenuLeftPanel.visible = NO;
    [gameMenuLeftPanel setPosition:ccp(-700.00, 0.00)];
    
    //panels buttons/menus
    CCSprite *buttonReplayOff = [CCSprite spriteWithSpriteFrameName:@"logik_replay1.png"];
    CCSprite *buttonReplayOn = [CCSprite spriteWithSpriteFrameName:@"logik_replay2.png"];
    
    CCSprite *buttonGameMenuOff = [CCSprite spriteWithSpriteFrameName:@"logik_gmenu1.png"];
    CCSprite *buttonGameMenuOn = [CCSprite spriteWithSpriteFrameName:@"logik_gmenu2.png"];
    
    //CCSprite *buttonContinueOff = [CCSprite spriteWithSpriteFrameName:@"logik_continue1.png"];
    //CCSprite *buttonContinueOn = [CCSprite spriteWithSpriteFrameName:@"logik_continue2.png"];
    
    CCMenuItem *replayItem = [CCMenuItemSprite itemFromNormalSprite:buttonReplayOff selectedSprite:buttonReplayOn target:self selector:@selector(menuTapped:)];
    replayItem.tag = kButtonReplay;
    CCMenu *replayMenu = [CCMenu menuWithItems:replayItem, nil];
    replayMenu.position = ccp(66.00, 31.50);;
    [replayPanel addChild:replayMenu z:1];
    
    CCMenuItem *gameMenuItemLeft = [CCMenuItemSprite itemFromNormalSprite:buttonGameMenuOff selectedSprite:buttonGameMenuOn target:self selector:@selector(menuTapped:)];
    gameMenuItemLeft.tag = kButtonGameMenu;
    CCMenu *gameMenuLeft = [CCMenu menuWithItems:gameMenuItemLeft, nil];
    gameMenuLeft.position = ccp(195.50, 35.50);
    [gameMenuLeftPanel addChild:gameMenuLeft z:2];
    
    CCSprite *shadowBase = [CCSprite spriteWithSpriteFrameName:@"shadowBase.png"];
    shadowBase.anchorPoint = ccp(0,1);
    shadowBase.position = ccp(0, 115);
    
    
    //add nodes to display list
    [self addChild:movableNode z:1 tag:2];
        [movableNode addChild:bg z:-1 tag:-1];
        [movableNode addChild:highlightSprite z:200];
        [movableNode addChild:deadFiguresNodeMask z:1];
        [deadFiguresNodeMask addChild:deadFiguresNode z:1];
    [self addChild:shadowBase z:2];
    [self addChild:codeBase z:3 tag:3];
    [self addChild:clippingNode z:4 tag:1];
    [self addChild:base z:5 tag:11];
    [self addChild:figuresNode z:5];
    [self addChild:mantle z:7];
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
    [self addChild:scoreTime z:14];
        [scoreTime addChild:scoreBlackBg z:1];
        [scoreTime addChild:timeBlackBg z:2];
        [scoreTime addChild:scoreLayer z:3];
        [scoreTime addChild:timerMask z:4];
            [timerMask addChild:timer z:1];
        [scoreTime addChild:finalTimeLayer z:5];
        [scoreTime addChild:finalScoreLayer z:6];
        [scoreTime addChild:scoreTimeSprite z:7];
    [self addChild:pauseMenu z:20];
    [self addChild:endGameMenu z:21];
    [self addChild:scorePanel z:22];
    [self addChild:replayPanel z:31];
    [self addChild:gameMenuLeftPanel z:32];

    
    //dustSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"dust1.plist"];
    //[self addChild:dustSystem z:1000];
}

#pragma mark 8 figures to base 
- (void) addFigures {    
    movableFigures = [[CCArray alloc] init];
    
    float pinchXpos[8] = {30.55, 69.11, 107.66, 145.22, 182.77, 220.33, 258.88, 296.44};
    
    for (int i = 0; i < 8; ++i) {
        Figure *figure = [[Figure alloc] initWithFigureType:i];
        figure.position = ccp(pinchXpos[i], 29.0f);
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
        NSString *debugCode = @"";
        switch (cheatCode) {
            case kYellow: 
                CCLOG(@"YELLOW");
                debugCode = @"YELLOW";
                break;
            case kOrange:
                CCLOG(@"ORANGE");
                debugCode = @"ORANGE";
                break;
            case kPink:
                CCLOG(@"PINK");
                debugCode = @"PINK";
                break;
            case kRed:
                CCLOG(@"RED");
                debugCode = @"RED";
                break;
            case kPurple:
                CCLOG(@"PURPLE");
                debugCode = @"PURPLE";
                break;
            case kBlue:
                CCLOG(@"BLUE");
                debugCode = @"BLUE";
                break;
            case kGreen:
                CCLOG(@"GREEN");
                debugCode = @"GREEN";
                break;
            case kWhite:
                CCLOG(@"WHITE");
                debugCode = @"WHITE";
                break;
            default:
                CCLOG(@"Unknown ID, cannot print code");
                break;
        }
        
        //Figure *figure = [[Figure alloc] initWithFigureType:[Utils randomNumberBetween:0 andMax:8]];
        Figure *figure = [[Figure alloc] initWithFigureType:cheatCode];
        figure.place = i;
        figure.anchorPoint = CGPointMake(0, 0);
        figure.position = ccp(6 + difficultyPadding*i, 5.0f);
        
        Figure *cheatFigure = [[Figure alloc] initWithFigureType:cheatCode];
        cheatFigure.anchorPoint = CGPointMake(0, 0);
        cheatFigure.position = ccp(100 + 20*i, 460);
        cheatFigure.scale = 0.5;
        cheatFigure.opacity = 255;
        
        [codeBase addChild:figure z:i];
        //[cheat addChild:cheatFigure z:i];
        [currentCode addObject:figure];
        
//        CCLabelBMFont *debugText = [CCLabelBMFont labelWithString:debugCode fntFile:@"BellGothicBoldHt.fnt"];
//        debugText.anchorPoint = ccp(0, 0.5);
//        [debugText setPosition:ccp(10 + i*60, 470)];
        [self addChild:cheatFigure z:3000 + i];
    }
    CCLOG(@"***********************END CODE*******************************");
    CCLOG(@"**************************************************************");
}

#pragma mark Construct score Label
- (void) constructScoreLabelWithLayer:(CCLayer *)layer andArray:(CCArray *)array andRotation:(float)rotation andXpos:(float)xPos andYPos:(float)yPos {
    for (int i = 0; i<8; i++) {
        Mask *scoreMask = [Mask maskWithRect:CGRectMake(xPos + 9*i, yPos, 9, 18)];
        [layer addChild:scoreMask z:i];
        ScoreNumber *scoreNumber = [[ScoreNumber alloc] init];
        scoreNumber.rotation = rotation;
        [scoreMask addChild:scoreNumber];
        [array addObject:scoreNumber];
    }
    [array reverseObjects];
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
    CCLOG(@"pause tapped");
    [self endGame];
    //[[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kSlideInR];
}

#pragma mark Final menu buttons
- (void) menuTapped:(CCMenuItem *)sender {
    switch (sender.tag) {
        case kButtonReplay: 
            [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kNoTransition];
            break;
        case kButtonGameMenu:
            [[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kSlideInL];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;    
    }

}


#pragma mark End game button
- (void) endGameTapped:(CCMenuItem *)sender { 
    CCLOG(@"end game tapped");
    float delay;
    if (isWinner) {
        finalScoreLabel.visible = NO;
        CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:0.4 position:ccp(-700.00, 0.00)];
        CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:0.4 scaleX:5 scaleY:22];
        CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:1.0 angle:0];
        CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
        
        CCSequence *scoreTimeSeq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: 0.0f],
                                    [CCMoveTo actionWithDuration:.3 position:CGPointMake(scoreTime.position.x, scoreTime.position.y + 30)],
                                    [CCCallFunc actionWithTarget:self selector:@selector(labelsOutCallback)],
                                    nil];
        
        if (score < maxScore) {
            id wdBigOut = [CCFadeOut actionWithDuration:.2];
            [wdBig runAction:wdBigOut];
        } else {
            id superBigOut = [CCFadeOut actionWithDuration:.2];
            id superSmallOut = [CCFadeOut actionWithDuration:.2];
            [superBig runAction:superBigOut];
            [superSmall runAction:superSmallOut];
        }
        
        [scoreTime runAction:scoreTimeSeq];
        [scorePanel runAction:moveLeftGibSeq];
        delay = 0.4;
    } else {
        delay = 0.3;
        id fadeFailLabel = [CCFadeOut actionWithDuration:.3];
        id fadeFailLabelBig = [CCFadeOut actionWithDuration:.3];
        
        [failLabelSmall runAction:fadeFailLabel];
        [failLabelBig runAction:fadeFailLabelBig];
    }
    
    CCSequence *endGameMenuSeq = [CCSequence actions:
                            [CCDelayTime actionWithDuration: 0.0f],
                            [CCMoveTo actionWithDuration:.4 position:CGPointMake(endGameMenu.position.x, endGameMenu.position.y + 60)],
                            nil];
    
    CCMoveTo *replayMoveIn = [CCMoveTo actionWithDuration:0.6 position:ccp(225.50, 235.00)];
    CCScaleTo *replayScaleInX = [CCScaleTo actionWithDuration:0.6 scaleX:1.0 scaleY:1.0];
    CCRotateTo *replayRotationIn = [CCRotateTo actionWithDuration:0.6 angle:1];        
    CCSpawn *replaySeq = [CCSpawn actions:[CCDelayTime actionWithDuration: delay], replayMoveIn, replayScaleInX, replayRotationIn, nil];
    
    CCMoveTo *gmLeftMoveIn = [CCMoveTo actionWithDuration:.6 position:ccp(100.00, 161.00)];
    CCScaleTo *gmLeftScaleInX = [CCScaleTo actionWithDuration:.6 scaleX:1.0 scaleY:1.0];
    CCRotateTo *gmLeftRotationIn = [CCRotateTo actionWithDuration:.6 angle:-2];
    CCSpawn *moveGmLeftSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: delay], gmLeftMoveIn, gmLeftScaleInX, gmLeftRotationIn, nil];
    
    replayPanel.visible = YES;
    gameMenuLeftPanel.visible = YES;
    
    [replayPanel runAction:replaySeq];
    [gameMenuLeftPanel runAction:moveGmLeftSeq];
    [endGameMenu runAction:endGameMenuSeq];
    
    CCSprite *buttonFbOff = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb1.png"];
    CCSprite *buttonFbOn = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb2.png"];
    CCSprite *buttonMailOff = [CCSprite spriteWithSpriteFrameName:@"logik_iconmail1.png"];
    CCSprite *buttonMailOn = [CCSprite spriteWithSpriteFrameName:@"logik_iconmail2.png"];
    
    CCMenuItem *fbItem = [CCMenuItemSprite itemFromNormalSprite:buttonFbOff selectedSprite:buttonFbOn target:self selector:@selector(fbMailTapped)];
    fbItem.tag = kButtonFb;
    fbItem.position = ccp(70.00, 30.00);
    
    CCMenuItem *mailItem = [CCMenuItemSprite itemFromNormalSprite:buttonMailOff selectedSprite:buttonMailOn target:self selector:@selector(fbMailTapped)];
    mailItem.tag = kButtonMail;
    mailItem.position = ccp(260.00, 30.00);
    
    CCMenu *finalMenu = [CCMenu menuWithItems:fbItem, mailItem, nil];
    finalMenu.position = CGPointZero;
    [self addChild:finalMenu z:60];
}

- (void) fbMailTapped {
    CCLOG(@"fb mail tapped");
}

- (void) labelsOutCallback {
    wdBig.visible = NO;
    superBig.visible = NO;
    superSmall.visible = NO;
}


#pragma mark -
#pragma mark END GAME
#pragma mark Composite method
- (void) endGame {
    CCLOG(@"Logic debug: END GAME");
    //if (activeRow == 9) {
        id actionDelay = [CCDelayTime actionWithDuration:0.2];
        [self runAction:[CCSequence actions:actionDelay, [CCCallFuncND actionWithTarget:self selector:@selector(results:data:) data:[NSNumber numberWithInt:activeRow]], nil]];
    //}
    [[[GameManager sharedGameManager] gameData] writeScore:[Utils randomNumberBetween:1000 andMax:99999999] andDifficulty:currentDifficulty];
    [[[GameManager sharedGameManager] gameData] gameDataCleanup];
    isMovable = NO;
    longPress.enabled = NO;
    isWinner = currentDifficulty == places ? YES : NO;
    [[[GameManager sharedGameManager] gameData] updateCareerData:isWinner];
    [self constructEndLabels:[timer stopTimer]];
    [self openLock];
}


- (void) constructEndLabels:(int)time {
    movingTime = [[CCArray alloc] init];
    movingScore = [[CCArray alloc] init];
    //time label
    [timerMask removeFromParentAndCleanup:YES];
    NSString *finalTime = [NSString stringWithFormat:@"%02d%02d", time/60, time%60];
    CCSprite *timePiece;
    int colonFlag = 0;
    for (int i = 0; i < finalTime.length; i++) {
        if (i == 2) {
            colonFlag = 4;
            CCSprite *colon = [CCSprite spriteWithSpriteFrameName:@"colon.png"];
            colon.anchorPoint = ccp(0,0);
            colon.position = ccp(279 + i*9, 456);
            [finalTimeLayer addChild:colon z:i];
            [movingTime addObject:colon];
        }
        int piece = [[NSString stringWithFormat:@"%c", [finalTime characterAtIndex:i]] intValue];
        timePiece = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", piece]];
        timePiece.anchorPoint = ccp(0,0);
        timePiece.position = ccp(279 + i*9 + colonFlag, 456);
        [finalTimeLayer addChild:timePiece z:i];
        [movingTime addObject:timePiece];
    }
    
    //score label
    NSString *finalScore = [NSString stringWithFormat:@"%i", score];
    CCSprite *labelPiece;
    for (int i = 0; i < 8; i++) {
        if (i < 8 - finalScore.length) {
            labelPiece = [CCSprite spriteWithSpriteFrameName:@"empty.png"];
        } else {
            CCLOG(@"kolik je i %i", i);
            int piece = [[NSString stringWithFormat:@"%c", [finalScore characterAtIndex:i - (8 - finalScore.length)]] intValue];
            labelPiece = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", piece]];
        }
        labelPiece.anchorPoint = ccp(0,0);
        labelPiece.position = ccp(9*i, 456.00);
        [finalScoreLayer addChild:labelPiece z:i];
        [movingScore addObject:labelPiece];        
    }
}

#pragma mark Open lock animations
- (void) openLock {
    PLAYSOUNDEFFECT(OPEN_LOCK);
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
                          [CCMoveTo actionWithDuration:.4 position:CGPointMake(figuresNode.position.x, figuresNode.position.y - 51)],
                          nil];
    CCSequence *baseSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(base.position.x, base.position.y - 49)],
                           nil];
    
    CCSequence *clippingSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(clippingNode.position.x, clippingNode.position.y - 49)],
                           [CCCallFunc actionWithTarget:self selector:@selector(openLockEnded)],
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
    
    smokeSystem1 = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"smoke2.plist"];
    smokeSystem1.autoRemoveOnFinish = YES;
    smokeSystem1.position = ccp(70, smokeSystem1.position.y);
    [self addChild:smokeSystem1 z:6];
    
    smokeSystem2 = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"smoke2.plist"];
    smokeSystem2.autoRemoveOnFinish = YES;
    smokeSystem2.position = ccp(250, smokeSystem2.position.y);
    [self addChild:smokeSystem2 z:6];
    
    [self schedule:@selector(deleteParticle) interval:2.00];
}

- (void) deleteParticle {
    [smokeSystem1 stopSystem];
    [smokeSystem2 stopSystem];
    [self unschedule:@selector(deleteParticle)];
}

- (void) openLockEnded {
    float delayStep1 = 2.50;
    float delayStep2 = 8.00;

    CGSize screenSize = [CCDirector sharedDirector].winSize;
    blackout = [Blackout node];
    [blackout setOpacity:0];
    id fadeIn = [CCFadeTo actionWithDuration:0.3 opacity:128];
    id fadeSeq = [CCSequence actions:[CCDelayTime actionWithDuration: delayStep1], fadeIn, nil];
    [self addChild:blackout z:12];
        
    CCSequence *endButtonSeq = [CCSequence actions:
                               [CCDelayTime actionWithDuration: delayStep1],
                               [CCMoveTo actionWithDuration:.3 position:CGPointMake(endGameMenu.position.x, endGameMenu.position.y - 60)],
                               nil];
    
    [blackout runAction:fadeSeq];
    [endGameMenu runAction:endButtonSeq];
    
    if (isWinner) {
        finalScoreArray = [[CCArray alloc] init];
        finalScoreLabel = [CCLayer node];
        finalScoreLabel.visible = NO;
        finalScoreLabel.rotation = -2;
        [self addChild:finalScoreLabel z:40];
        [self constructScoreLabelWithLayer:finalScoreLabel andArray:finalScoreArray andRotation:-2 andXpos:155 andYPos:226];
        //score Panel
        scorePanel.visible = YES;
        CCMoveTo *spMoveIn = [CCMoveTo actionWithDuration:.5 position:ccp(100.00, 225.00)];
        CCScaleTo *spScaleInX = [CCScaleTo actionWithDuration:.5 scaleX:1.0 scaleY:1.0];
        CCRotateTo *spRotationIn = [CCRotateTo actionWithDuration:.5 angle:-2];
        CCSpawn *moveSpSeq = [CCSpawn actions:spMoveIn, spScaleInX, spRotationIn, nil];
        CCSequence *spSeqIn = [CCSequence actions:[CCDelayTime actionWithDuration: delayStep2], moveSpSeq, [CCCallFunc actionWithTarget:self selector:@selector(spInCallback)], nil];
        
        CCSequence *scoreTimeSeq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: delayStep2],
                                    [CCMoveTo actionWithDuration:.3 position:CGPointMake(scoreTime.position.x, scoreTime.position.y - 30)],
                                    nil];
        
        CCLabelBMFont *movesLabelBig = [CCLabelBMFont labelWithString:@"MOVES:" fntFile:@"Gloucester_levelBig.fnt"];
        movesLabelBig.scale = isRetina ? 1 : 0.5;
        movesLabelBig.opacity = 0;
        movesLabelBig.rotation = -2;
        movesLabelBig.position = ccp(screenSize.width/2 - 15, screenSize.height/2 + 40);
        [self addChild:movesLabelBig z:21];
        CCSequence *movesTimeSeq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: 0.5f],
                                    [CCFadeIn actionWithDuration:.3],
                                    nil];
        CCSequence *movesTimeOutSeq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: 1.8f],
                                    [CCFadeOut actionWithDuration:.2],
                                    nil];
        
        CCLabelBMFont *timeLabelBig = [CCLabelBMFont labelWithString:@"TIME BONUS:" fntFile:@"Gloucester_levelBig.fnt"];
        timeLabelBig.scale = isRetina ? 1 : 0.5;
        timeLabelBig.opacity = 0;
        timeLabelBig.rotation = -2;
        timeLabelBig.position = ccp(screenSize.width/2 - 15, screenSize.height/2 + 40);
        [self addChild:timeLabelBig z:21];
        CCSequence *movesTime2Seq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: 2.3f],
                                    [CCFadeIn actionWithDuration:.3],[CCCallFunc actionWithTarget:self selector:@selector(timeBonusCallback)],
                                    nil];
        CCSequence *movesTimeOut2Seq = [CCSequence actions:
                                       [CCDelayTime actionWithDuration: 3.2f],
                                       [CCFadeOut actionWithDuration:.2],
                                       nil];
        if (score < maxScore) {
            wdBig = [CCLabelBMFont labelWithString:@"WELL DONE!" fntFile:@"Gloucester_levelBig.fnt"];
            wdBig.scale = isRetina ? 1 : 0.5;
            wdBig.opacity = 0;
            wdBig.rotation = -2;
            wdBig.position = ccp(screenSize.width/2 - 15, screenSize.height/2 + 40);
            [self addChild:wdBig z:21];
            CCSequence *wdSeq = [CCSequence actions:
                                         [CCDelayTime actionWithDuration: 3.5f],
                                         [CCFadeIn actionWithDuration:.3],
                                         nil];
            [wdBig runAction:wdSeq];
        } else {
            superBig = [CCLabelBMFont labelWithString:@"EXCELLENT!" fntFile:@"Gloucester_levelBig.fnt"];
            superBig.scale = isRetina ? 1 : 0.5;
            superBig.opacity = 0;
            superBig.rotation = -2;
            superBig.position = ccp(screenSize.width/2 - 15, screenSize.height/2 + 65);
            [self addChild:superBig z:21];
            
            superSmall = [CCLabelBMFont labelWithString:@"NEW HIGH SCORE" fntFile:@"Gloucester_levelSmall.fnt"];
            superSmall.scale = isRetina ? 1 : 0.5;
            superSmall.opacity = 0;
            superSmall.rotation = -2;
            superSmall.position = ccp(screenSize.width/2 - 15, screenSize.height/2 + 40);
            [self addChild:superSmall z:21];
            
            CCSequence *super1Seq = [CCSequence actions:
                                 [CCDelayTime actionWithDuration: 3.5f],
                                 [CCFadeIn actionWithDuration:.3],
                                 nil];
            CCSequence *super2Seq = [CCSequence actions:
                                     [CCDelayTime actionWithDuration: 3.5f],
                                     [CCFadeIn actionWithDuration:.3],
                                     nil];
            [superBig runAction:super1Seq];
            [superSmall runAction:super2Seq];
        }
        
        
        [scorePanel runAction:spSeqIn];
        [scoreTime runAction:scoreTimeSeq];
        [movesLabelBig runAction:movesTimeSeq];
        [movesLabelBig runAction:movesTimeOutSeq];
        [timeLabelBig runAction:movesTime2Seq];
        [timeLabelBig runAction:movesTimeOut2Seq];
        //[self moves:0.8];
        //[self timeBonus:2.5];
    } else {
        failLabelSmall = [CCLabelBMFont labelWithString:@"THIS CODE WAS TOUGH" fntFile:@"Gloucester_levelSmall.fnt"];
        failLabelSmall.scale = isRetina ? 1 : 0.5;
        failLabelSmall.opacity = 0;
        failLabelSmall.rotation = -2;
        failLabelSmall.position = ccp(screenSize.width/2 - 15, screenSize.height/2);
        [self addChild:failLabelSmall z:30];
        
        failLabelBig = [CCLabelBMFont labelWithString:@"TRY IT AGAIN!" fntFile:@"Gloucester_levelBig.fnt"];
        failLabelBig.scale = isRetina ? 1 : 0.5;
        failLabelBig.opacity = 0;
        failLabelBig.rotation = -2;
        failLabelBig.position = ccp(screenSize.width/2 - 15, screenSize.height/2 - 25);
        [self addChild:failLabelBig z:30];
        
        id fadeFailLabel = [CCFadeIn actionWithDuration:.3];
        id fadeFailLabelBig = [CCFadeIn actionWithDuration:.3];
        
        [failLabelSmall runAction:fadeFailLabel];
        [failLabelBig runAction:fadeFailLabelBig];
    }
    
}

//- (void) moves:(float)delay {
//    CGSize screenSize = [CCDirector sharedDirector].winSize;
//    [self drawScoreToLabel:score andArray:finalScoreArray];
//    int i = 0;
//    for (CCSprite *scoreSprite in movingScore) {
//        id moveSeq = [CCSpawn actions:
//                        //[CCDelayTime actionWithDuration: delay + i*0.1f],
//                        [CCMoveTo actionWithDuration:.2 position:ccp(screenSize.width /2 + 50 , screenSize.height/2 - 100)],
//                        [CCFadeOut actionWithDuration:.2], nil];
//        id delaySeq = [CCSequence actions:[CCDelayTime actionWithDuration: delay + i*0.1f], moveSeq, nil];
//        [scoreSprite runAction:delaySeq];
//        i++;
//    }
//}
//
//- (void) timeBonus:(float)delay {
//    CGSize screenSize = [CCDirector sharedDirector].winSize;
//    int i = 0;
//    for (CCSprite *timeSprite in movingTime) {
//        id moveSeq = [CCSpawn actions:
//                      [CCMoveTo actionWithDuration:.2 position:ccp(screenSize.width /2 - 50 , screenSize.height/2 - 100)],
//                      [CCFadeOut actionWithDuration:.2], nil];
//        id delaySeq = [CCSequence actions:[CCDelayTime actionWithDuration: delay + i*0.1f], moveSeq, nil];
//        [timeSprite runAction:delaySeq];
//        i++;
//    }
//}

- (void) spInCallback {
    finalScoreLabel.visible = YES;
}

- (void) timeBonusCallback {
    int fuckUp = 98654871;
    [self drawScoreToLabel:fuckUp andArray:finalScoreArray]; 
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
    
    gameRow row;
    row.row = activeRow;
    row.colors = colors;
    row.places = places;
    [[[GameManager sharedGameManager] gameData] insertRow:row];
    
    
    //[self showResult];
    [self calculateScore];
    if (places == currentDifficulty || activeRow == 9) {
        [self endGame];
    } else {
        [self nextRow];
    }
}

- (void) showResult:(int)row {
    float delay = 0.0f;
    CCSprite *greenLight = [greenLights objectAtIndex:row];
    if (places > 0) {
        delay = 1.0f;
        id fadeToGreen = [CCFadeTo actionWithDuration:0.5f opacity:255];
        [greenLight runAction:fadeToGreen];
        PLAYSOUNDEFFECT(SHOW_RESULT_GREEN);
    }   
    RowStaticScore *place = [placeNumbers objectAtIndex:row];
    [place showNumber:places];
    Mask *holderPlace = [Mask maskWithRect:CGRectMake(greenLight.position.x - 3, greenLight.position.y + trans + 8, 9, 18)];
    [self addChild:holderPlace z:100 + row];
    RowScore *rs = [[RowScore alloc] init];
    [holderPlace addChild:rs z:1];
    [rs moveToPosition:places andMask:holderPlace];
        
    CCSprite *orangeLight = [orangeLights objectAtIndex:row];
    if (colors > 0) {
        id spawnOrange = [CCSpawn actions:[CCFadeTo actionWithDuration:0.5f opacity:255], [CCCallFuncND actionWithTarget:self selector:@selector(showColors:data:) data:[NSNumber numberWithInt:row]], nil];
        id fadeToOrange = [CCSequence actions:[CCDelayTime actionWithDuration: delay], spawnOrange, nil];
        [orangeLight runAction:fadeToOrange];
    } else {
        [self showColors:nil data:[NSNumber numberWithInt:row]];
    }
}

- (void) showColors:(id)sender data:(NSNumber *)rowObj {
    if (colors > 0)
        PLAYSOUNDEFFECT(SHOW_RESULT_YELLOW);
    int row = [rowObj intValue];
    CCSprite *orangeLight = [orangeLights objectAtIndex:row];
    RowStaticScore *color = [colorNumbers objectAtIndex:row];
    [color showNumber:colors];
    Mask *holderColors = [Mask maskWithRect:CGRectMake(orangeLight.position.x - 5, orangeLight.position.y + trans + 8, 9, 18)];
    [self addChild:holderColors z:100 + row];
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
    [self drawScoreToLabel:score andArray:scoreLabelArray];    
}

- (void) drawScoreToLabel:(int)value andArray:(CCArray *)array {
    NSString *scoreString = [NSString stringWithFormat:@"%i", value];
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[scoreString length]];
    for (int i=0; i < [scoreString length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [scoreString characterAtIndex:i]];
        [characters addObject:ichar];
    }
    ScoreNumber *tempScoreNumber;
    for (int i=0; i < [characters count]; i++) {
        tempScoreNumber = [array objectAtIndex:i];
        [tempScoreNumber moveToPosition:[[[[characters reverseObjectEnumerator] allObjects] objectAtIndex:i] intValue]];
    }
}

- (void) nextRow {
    [userCode removeAllObjects];
    
    id actionDelay = [CCDelayTime actionWithDuration:0.2];
	[self runAction:[CCSequence actions:actionDelay, [CCCallFuncND actionWithTarget:self selector:@selector(results:data:) data:[NSNumber numberWithInt:activeRow]], nil]];
    
    activeRow ++;
    [self constructRowWithIndex:activeRow];
    [self jumpGamePlay];
}

- (void) results:(id)sender data:(NSNumber *)row {
    [self showResult:[row intValue]];
}

- (void) jumpGamePlay {
    if (activeRow >= LEVEL_SWIPE_AFTER_ROW) {
        isMovable = YES;
    }
    
    if (activeRow == 7) {
        jump = -45;
    }
    if (activeRow >= 8) {
        jump = -90;
    }
    
    if (activeRow == 7 || activeRow >= 8) {
        id move = [CCMoveTo actionWithDuration:.2 position:CGPointMake(movableNode.position.x, jump)];
        id move1 = [CCMoveTo actionWithDuration:.2 position:CGPointMake(clippingNode.position.x, jump)];
        [movableNode runAction:move];
        [clippingNode runAction:move1];
        
        trans = jump;
    }
}

- (void) generateDeadRow {
    for (Figure *userSprite in userCode) {
        Figure *deadFig = [[Figure alloc] initWithFigureType:userSprite.currentFigure];
        CGPoint newPos = ccp(userSprite.position.x, userSprite.position.y - LEVEL_DEAD_FIGURES_MASK_HEIGHT - trans);
        deadFig.position = newPos;
        [deadFiguresNode addChild:deadFig z:1];//mrknout na z-index
        
        deadFigure dbFigure;
        dbFigure.color = deadFig.currentFigure;
        dbFigure.position = deadFig.position;
        [[[GameManager sharedGameManager] gameData] insertDeadFigure:dbFigure];
        
        [movableFigures removeObject:userSprite];
        [userSprite destroy];        
    }
    
    gameInfo infoData;
    infoData.difficulty = currentDifficulty;
    infoData.activeRow = activeRow + 1;//posledni radek? data length v dbase a tak... zatim srat
    infoData.career = isCareer ? 1 : 0;
    [[[GameManager sharedGameManager] gameData] insertGameData:infoData];
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
    PLAYSOUNDEFFECT(FIGURE_MOVE);
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
    sprite.tempPosition = ccp(sprite.position.x, sprite.position.y);
    spriteEndPosition = sprite.position.y;//mozna vyhodime
    sprite.movePosition = ccp(sprite.position.x, sprite.position.y - trans);
    CCLOG(@"JAKY JE Y? %f", sprite.position.y);
    
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
    
    selSprite = nil;
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
        existSprite.tempPosition = ccp(sprite.tempPosition.x, sprite.tempPosition.y);
    }
    sprite.oldPlace = sprite.place;
}

- (void) figureSetCorrectPosition:(id)sender data:(Figure *)sprite {
    sprite.tempPosition = ccp(sprite.position.x, sprite.position.y);
    [figuresNode reorderChild:selSprite z:sprite.zOrder - 100];
    selSprite = nil;
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
    scale.tag = kFigureZoom;
    [newSprite runAction:scale];          
    selSprite = newSprite;
    CCLOG(@"sel sprite %@", selSprite);
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
        CCScaleTo *scale = [CCScaleTo actionWithDuration:0.3 scale:1.0];
        [selSprite runAction:scale];        
        if (targetSprite != nil) {//animation to target
            CCSequence *moveSeq;
            if (selSprite.isOnActiveRow) {
                [self swapFigure:selSprite];
                moveSeq = [CCSequence actions:
                           [CCMoveTo actionWithDuration:.03*activeRow position:CGPointMake(targetSprite.position.x + 2.5, targetSprite.position.y + 5 + trans)],
                           [CCCallFuncND actionWithTarget:self selector:@selector(figureSetCorrectPosition:data:) data:selSprite],
                           nil];
            } else {
                moveSeq = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.03*activeRow position:CGPointMake(targetSprite.position.x + 2.5, targetSprite.position.y + 5 + trans)],
                           [CCCallFuncND actionWithTarget:self selector:@selector(figureMoveEnded:data:) data:selSprite],
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
//- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
//    CCLOG(@"SINGLE TOUCH");
////    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
////    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
////    touchLocation = [self convertToNodeSpace:touchLocation];                
////    [self selectSpriteForTouch:touchLocation];
//}


- (CGPoint) boundMovePos:(CGPoint)translation withPosition:(CGPoint)position andNode:(CCNode *)node {
    CGPoint retval = ccp(node.position.x, node.position.y + translation.y);
    retval.y = MIN(retval.y, position.y);
    //CCLOG(@"retval1 %@", NSStringFromCGPoint(retval));
    if (activeRow == 7) {
        retval.y = MAX(retval.y, position.y - 45);
    }
    if (activeRow > 7) {
        retval.y = MAX(retval.y, position.y - 90);
    }
    
    //CCLOG(@"retval2 %@", NSStringFromCGPoint(retval));
    return retval;
}

#pragma mark Pan gestures handler
- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        if (abs(translation.x) > 30 && !selSprite) {
            if (isEndRow) {
                PLAYSOUNDEFFECT(ROW_SWIPE);
                isEndRow = NO;
                [self generateDeadRow];
                [self endOfRow];
            }
        } else {
            if (selSprite) {
                [self panForTranslation:translation];
                [self detectTarget];
            } else {
                CGPoint touchLocation = [recognizer locationInView:recognizer.view];
                touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
                touchLocation = [self convertToNodeSpace:touchLocation];
                if (isMovable && translation.y > 0 && touchLocation.y > MIN_DISTANCE_SWIPE_Y) {
                    longPress.enabled = NO;
                    [movableNode setPosition:[self boundMovePos:translation withPosition:ccp(0, 0) andNode:movableNode]];
                    [clippingNode setPosition:[self boundMovePos:translation withPosition:ccp(0, 0) andNode:clippingNode]];
                    for (Figure *figure in movableFigures) {
                        if (figure.isOnActiveRow) {
                            [figure setPosition:[self boundMovePos:translation withPosition:ccp(0, figure.movePosition.y) andNode:figure]];
                            figure.tempPosition = figure.position;
                        }
                    }
                    trans = movableNode.position.y;
                }
            }
        }
        [recognizer setTranslation:CGPointZero inView:recognizer.view];

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (isMovable && [movableNode numberOfRunningActions] == 0 && movableNode.position.y > jump) {
            longPress.enabled = YES;
            id move = [CCMoveTo actionWithDuration:.1 position:CGPointMake(movableNode.position.x, jump)];
            id move1 = [CCMoveTo actionWithDuration:.1 position:CGPointMake(clippingNode.position.x, jump)];
            [movableNode runAction:move];
            [clippingNode runAction:move1];
            for (Figure *figure in movableFigures) {
                if (figure.isOnActiveRow) {
                    id movef = [CCMoveTo actionWithDuration:.1 position:ccp(figure.position.x, figure.position.y + jump - movableNode.position.y)];
                    [figure runAction:movef];
                    figure.tempPosition = ccp(figure.position.x, figure.position.y + jump - movableNode.position.y);
                }
            }
            trans = jump;
        }    
        [self endTouch];
    }
}

- (void) handlePress:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];                
        [self selectSpriteForTouch:touchLocation];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {            
        [selSprite stopActionByTag:kFigureZoom];
        selSprite.scale = 1;
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
    [movingTime release];
    movingTime = nil;
    [movingScore release];
    movingScore = nil;
    
    [super dealloc];
}

@end