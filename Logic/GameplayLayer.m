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
- (void) setupTutor;
- (void) tutorDisable;
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
- (void) constructScoreLabelWithLayer:(CCLayer *)layer andArray:(CCArray *)array andLength:(int)length andRotation:(float)rotation andXpos:(float)xPos andYPos:(float)yPos;
- (void) drawScoreToLabel:(int)value andArray:(CCArray *)array andStyle:(BOOL)animated andZero:(BOOL)toZero;
- (void) drawTimeToLabel:(int)value andArray:(CCArray *)array andStyle:(BOOL)animated andZero:(BOOL)toZero;
- (void) constructEndLabels:(int)time andZero:(BOOL)toZero;
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
        fid = 0;
        tutorStep = 0;
        CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
        isRetina = screenSize.height == 960.0f ? YES : NO;
        maxScore = [[[GameManager sharedGameManager] gameData] getMaxScore:currentDifficulty];
        userCode = [[NSMutableArray alloc] init];
        placeNumbers = [[CCArray alloc] init];
        colorNumbers = [[CCArray alloc] init];
        scoreLabelArray = [[CCArray alloc] init];
        //scoreCalc = [ScoreCalc scoreWithColors:8 pins:currentDifficulty];
        //[scoreCalc retain];
        [self createGame];
    }
    return self;
}

#pragma mark Enter&exit scene
- (void)onEnter {
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_LEVEL];
    [[GameManager sharedGameManager] playLoopSounds];
    
    panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)] autorelease];
    
    longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)] autorelease];
    longPress.minimumPressDuration = LEVEL_MIN_PRESS_DURATION;
    longPress.delegate = self;
    
    longPress.cancelsTouchesInView = NO;
    
    singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    singleTap.cancelsTouchesInView = NO;
    singleTap.enabled = NO;
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panRecognizer];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:longPress];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTap];
    
    blackout = [Blackout node];
    [blackout setOpacity:230];
    id fadeOut = [CCFadeTo actionWithDuration:.7 opacity:0];
    CCEaseIn *easeFadeOut = [CCEaseIn actionWithAction:fadeOut rate:5];
    id fadeSeq = [CCSequence actions:easeFadeOut,[CCCallFunc actionWithTarget:self selector:@selector(blackoutCallback)], nil];
    [self addChild:blackout z:5000];
    [blackout runAction:fadeSeq];
    
    [super onEnter];
}

- (void)onExit {
    //longPress.cancelsTouchesInView = YES;
    longPress.delegate = nil;
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:panRecognizer];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:longPress];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:singleTap];
    [super onExit];
}

- (void) blackoutCallback {
    [blackout removeFromParentAndCleanup:YES];
}

#pragma mark -
#pragma mark GESTURES DELEGATE METHODS
#pragma mark Simultaneous
- (BOOL) gestureRecognizer:longPress shouldRecognizeSimultaneouslyWithGestureRecognizer:panRecognizer {
    return YES;
}

#pragma mark -
#pragma mark INITIALIZATION OF LEVEL
#pragma mark Composite method for starting level
- (void) createGame {
    gameInfo infoData;
    if ([[GameManager sharedGameManager] gameInProgress]) {
        infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        currentDifficulty = infoData.difficulty;
        activeRow = infoData.activeRow;
        isCareer = infoData.career == 0 ? NO : YES;
        score = infoData.score;
        gameTime = infoData.gameTime;
    } else {
        gameTime = 0;
        infoData.difficulty = currentDifficulty;
        infoData.activeRow = 0;
        infoData.career = 0;
        infoData.score = 0;
        infoData.gameTime = 0;
        [[[GameManager sharedGameManager] gameData] insertGameData:infoData];
    }
    
    [self buildLevel];
    [self addFigures];
    [self generateTargets];
    [self generateCode];
    [self constructScoreLabelWithLayer:scoreLayer andArray:scoreLabelArray andLength:8 andRotation:0 andXpos:0 andYPos:456.50];
    //[self constructScoreLabelWithLayer:scoreLayer andArray:scoreLabelArray andLength:8 andRotation:0 andXpos:31 andYPos:487.00];//ipad hot fix
    [self constructRowWithIndex:activeRow];
    
    if (isCareer) {
        CCLOG(@"**************************************************\ncareer here**************************************************\n");
    } else {
        CCLOG(@"**************************************************\nno career**************************************************\n");
    }
    
    //POZOR!!! VOLA SE VZDY!!! OSETRIT!!!!!
    if ([[GameManager sharedGameManager] gameInProgress]) {
        NSMutableArray *deadFigures = [[[GameManager sharedGameManager] gameData] getDeadFigures];
        if ([deadFigures count] > 0) {
            for (Figure *figure in deadFigures) {
                figure.position = figure.tempPosition;
                [deadFiguresNode addChild:figure z:2000];
            }
        }
        
        [timer setupClock:gameTime];
        
        NSMutableArray *rows = [[[GameManager sharedGameManager] gameData] getRows];
        if ([rows count] > 0) {
            int dataRow;
            int dataPlaces;
            int dataColors;
            for (NSMutableDictionary *dict in rows) {
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
        [self jumpGamePlay];
        
        NSMutableArray *activeFigures = [[[GameManager sharedGameManager] gameData] getActiveFigures];
        CCLOG(@"active figures %i", [activeFigures count]);
        if ([activeFigures count] > 0) {
            for (NSMutableDictionary *dict in activeFigures) {
                Figure *figure = [[Figure alloc] initWithFigureType:[[dict objectForKey:@"color"] intValue]];
                figure.position = ccp([[dict objectForKey:@"posX"] floatValue], [[dict objectForKey:@"posY"] floatValue]);
                fid = [[dict objectForKey:@"fid"] intValue];
                figure.fid = [[dict objectForKey:@"fid"] intValue];
                figure.place = [[dict objectForKey:@"place"] intValue];
                figure.oldPlace = [[dict objectForKey:@"place"] intValue];
                figure.isOnActiveRow = YES;
                figure.tempPosition = ccp(figure.position.x, figure.position.y);
                figure.movePosition = ccp(figure.position.x, figure.position.y - jump);
                [figuresNode addChild:figure z:5000];//z - index§
                [movableFigures addObject:figure];
                [userCode addObject:figure];
            }
            if (activeFigures.count == currentDifficulty) {
                isEndRow = YES;
            }
        }
        
        if (score > 0) {
            [self drawScoreToLabel:score andArray:scoreLabelArray andStyle:YES andZero:NO];
        }
        
        [deadFigures release];
        deadFigures = nil;
        [rows release];
        rows = nil;
    }
    
    if ([GameManager sharedGameManager].isTutor) {
        [self setupTutor];
    }
}

- (void) skipTutorTapped:(CCMenuItem *)sender {
    [self tutorDisable];
    switch (sender.tag) {
        case kButtonSkipTutor:
            CCLOG(@"skip - play game");
            break;
        case kButtonNeverShow:
            CCLOG(@"never show");
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

- (void) setupTutor {
    tutorLayer.position = ccp(tutorLayer.position.x, tutorLayer.position.y + 480);
    tutorBlackout = [Blackout node];    
    tutorBlackout.position = ccp(tutorBlackout.position.x, tutorBlackout.position.y + 240);
    [tutorLayer addChild:tutorBlackout z:1];
    
    CCSprite *buttonSkipOff = [CCSprite spriteWithSpriteFrameName:@"end_off.png"];
    CCSprite *buttonSkipOn = [CCSprite spriteWithSpriteFrameName:@"end_on.png"];    
    CCMenuItem *skipItem = [CCMenuItemSprite itemFromNormalSprite:buttonSkipOff selectedSprite:buttonSkipOn target:self selector:@selector(skipTutorTapped:)];
    
    CCSprite *buttonTutorOff = [CCSprite spriteWithSpriteFrameName:@"end_off.png"];
    CCSprite *buttonTutorOn = [CCSprite spriteWithSpriteFrameName:@"end_on.png"];    
    CCMenuItem *tutorItem = [CCMenuItemSprite itemFromNormalSprite:buttonTutorOff selectedSprite:buttonTutorOn target:self selector:@selector(skipTutorTapped:)];
    
    skipItem.tag = kButtonSkipTutor;
    skipItem.position = ccp(33, 481.00 - skipItem.contentSize.height/2);        
    tutorItem.tag = kButtonNeverShow;
    tutorItem.position = ccp(287.00, 481.00 - tutorItem.contentSize.height/2);
    
    CCMenu *tutorMenu = [CCMenu menuWithItems:skipItem, tutorItem, nil];
    tutorMenu.position = CGPointZero;
    
    [tutorLayer addChild:tutorMenu z:2];
    
    CCLabelBMFont *skipTxt = [CCLabelBMFont labelWithString:@"skip" fntFile:@"Gloucester_levelBig.fnt"];
    skipTxt.scale = isRetina ? 1 : 0.5;
    skipTxt.position = ccp(240, skipItem.position.y);
    [tutorLayer addChild:skipTxt z:3];
    
    CCLabelBMFont *neverTxt = [CCLabelBMFont labelWithString:@"never show" fntFile:@"Gloucester_levelBig.fnt"];
    neverTxt.scale = isRetina ? 1 : 0.5;
    neverTxt.position = ccp(108, tutorItem.position.y);
    [tutorLayer addChild:neverTxt z:4];
    
    tutorTxt =  [CCLabelBMFont labelWithString:@"" fntFile:@"Gloucester_levelTutor.fnt"];
    tutorTxt.rotation = -1;
    tutorTxt.scale = isRetina ? 1 : 0.5;
    tutorTxt.position = ccp(150, 345);
    [tutorLayer addChild:tutorTxt z:5];
    
    tutorFinger = [CCSprite spriteWithSpriteFrameName:@"prst.png"];
    [tutorLayer addChild:tutorFinger z:6];
    tutorFinger.visible = NO;
    
    [self schedule:@selector(tutorEnable) interval:1];
}

- (void) tutorEnable {
    //CCLOG(@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nTUTOR UPDATE\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    [tutorBlackout setOpacity:128];

    id tutorIn = [CCMoveTo actionWithDuration:3 position:ccp(tutorLayer.position.x, tutorLayer.position.y - 480)];
    CCEaseIn *easeTutorIn = [CCEaseIn actionWithAction:tutorIn rate:5];
    id tutorInSeq = [CCSequence actions:easeTutorIn,[CCCallFunc actionWithTarget:self selector:@selector(tutorInCallback)], nil];
    
    [tutorLayer runAction:tutorInSeq];
    
    switch (tutorStep) {
        case kTutorFirst:
            CCLOG(@"TUTOR 1");
            [tutorTxt setString:@"Drag the pin \ninto the place"];
            
            break;
        case kTutorSecond:
            CCLOG(@"TUTOR 2");
            break;
        default:
            CCLOG(@"Logic debug: Unknown tutor ID, cannot run tutor");
            return;
            break;
    }
    [self unschedule:@selector(tutorEnable)];
    
    [self schedule:@selector(tutorDisable) interval:8];
}

- (void) tutorInCallback {
    PLAYSOUNDEFFECT(TUTOR1);
    tutorFinger.visible = YES;
    tutorFinger.position = ccp(120, -50);
    id moveFinger1 = [CCSequence actions:[CCMoveTo actionWithDuration:0.6 position:ccp(tutorFinger.position.x, 20)], nil];
    [tutorFinger runAction:moveFinger1];
    
}

- (void) tutorDisable {
    id tutorOut = [CCMoveTo actionWithDuration:1 position:ccp(tutorLayer.position.x, tutorLayer.position.y + 480)];
    //CCEaseOut *easeTutorOut = [CCEaseOut actionWithAction:tutorOut rate:5];
    //id sequence TODO -> callback [tutorBlackout setOpacity:255];
    
    [tutorLayer runAction:tutorOut];
    
    switch (tutorStep) {
        case kTutorFirst:
            CCLOG(@"TUTOR 1 OUT");
            tutorFinger.visible = NO;
            break;
        case kTutorSecond:
            CCLOG(@"TUTOR 2 OUT");
            break;
        default:
            CCLOG(@"Logic debug: Unknown tutor ID, cannot disable tutor");
            return;
            break;
    }
    
    tutorStep += 1;
    
    [self unschedule:@selector(tutorDisable)];
}

#pragma mark Build level
- (void) buildLevel {
    //init arrays
    greenLights = [[CCArray alloc] init];
    orangeLights = [[CCArray alloc] init];
    
    //init layers
    movableNode = [CCLayer node];
    figuresNode = [CCLayer node];
    clippingNode = [CCLayer node];
    deadFiguresNode = [CCLayer node];
    tutorLayer = [CCLayer node];
    //Mask *deadFiguresNodeMask = [Mask maskWithRect:CGRectMake(0, LEVEL_DEAD_FIGURES_MASK_HEIGHT, ADJUST_2(320), ADJUST_2(480 - LEVEL_DEAD_FIGURES_MASK_HEIGHT))];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLevelBgTexture];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLevelLevelTexture];    
    sphereNode = [CCSpriteBatchNode batchNodeWithFile:kLevelLevelPvr];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLevelAnimationsTexture];
    
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
    codeBase.position = kLevelCodeBasePosition;
    
    rotorLeftLayer = [CCSprite node];
    rotorRightLayer = [CCSprite node];
    rotorLeft = [CCSprite spriteWithSpriteFrameName:@"rotor_left.png"];
    rotorRight = [CCSprite spriteWithSpriteFrameName:@"rotor_right.png"];
    rotorLeftInside = [CCSprite spriteWithSpriteFrameName:@"rotor_left_inside.png"];
    rotorRightInside = [CCSprite spriteWithSpriteFrameName:@"rotor_right_inside.png"];
    rotorLeftLight = [CCSprite spriteWithSpriteFrameName:@"rotor_left_light.png"];
    rotorRightLight = [CCSprite spriteWithSpriteFrameName:@"rotor_right_light.png"];
    rotorLeftLayer.position = kLevelRotorLeftPosition;
    rotorRightLayer.position = kLevelRotorRightPosition;
    
    //KRYTKA
    mantle = [CCSprite spriteWithSpriteFrameName:@"logik_krytka.png"];
    mantle.position = kLevelMantlePosition;
    
    //LIGHT UNDER SPHERE
    sphereLight = [CCSprite spriteWithSpriteFrameName:@"lightSphere.png"];
    sphereLight.opacity = 155;
    sphereLight.position = kLevelSphereLightPosition;
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
    sphereNode.position = kLevelSpherePosition;
    
    base = [CCSprite spriteWithSpriteFrameName:@"pinchBase.png"];
    base.anchorPoint = CGPointMake(0, 0);
    base.position = kLevelBasePosition;
    
    //score, time
    scoreTime = [CCLayer node];
    CCSprite *scoreTimeSprite = [CCSprite spriteWithSpriteFrameName:@"logik_score_time.png"];
    scoreTimeSprite.anchorPoint = CGPointMake(0.5, 1);
    scoreTimeSprite.position = ADJUST_CCP_ABOVE(ccp(160.00, 480.50));
    
    //POZOR - HACK PRO IPAD
    //timerMask = [Mask maskWithRect:CGRectMake(ADJUST_X(279) + 3, ADJUST_Y(456.00) + 32, ADJUST_2(39.5), ADJUST_2(18))];
    timerMask = [Mask maskWithRect:CGRectMake(ADJUST_X(279), ADJUST_Y(456.00), ADJUST_2(39.5), ADJUST_2(18))];
    timer = [[ProgressTimer alloc] init];
    finalTimeLayer = [CCLayer node];
    
    CCSprite *scoreBlackBg = [CCSprite spriteWithSpriteFrameName:@"score_black_bg.png"];
    scoreBlackBg.position = ADJUST_CCP_ABOVE(ccp(36.00, 466.50));
    CCSprite *timeBlackBg = [CCSprite spriteWithSpriteFrameName:@"time_black_bg.png"];
    timeBlackBg.position = ADJUST_CCP_ABOVE(ccp(300.50, 466.00));
    
    scoreLayer = [CCLayer node];
    finalScoreLayer = [CCLayer node];
    final2ScoreLayer = [CCLayer node];
    final2TimeLayer = [CCLayer node];
    final3TimeLayer = [CCLayer node];
    
    
    //green & orange lights, places & colors status
    for(int i = 0; i < 10; ++i){
        CCSprite *greenLight = [CCSprite spriteWithSpriteFrameName:@"greenLight.png"];
        greenLight.position = ADJUST_CCP(ccp(288, 82 + i*44));
        greenLight.opacity = 0;
        [movableNode addChild:greenLight z:i tag:i];
        [greenLights addObject:greenLight];
        RowStaticScore *pss = [[RowStaticScore alloc] init];
        pss.position = ccp(greenLight.position.x - ADJUST_2(3), greenLight.position.y + ADJUST_2(8));
        [clippingNode addChild:pss z:1-i];
        [placeNumbers addObject:pss];
        
        
        CCSprite *orangeLight = [CCSprite spriteWithSpriteFrameName:@"orangeLight.png"];
        orangeLight.position = ADJUST_CCP(ccp(308, 82 + i*44));
        orangeLight.opacity = 0;
        [movableNode addChild:orangeLight z:i + 10 tag:i + 10];
        [orangeLights addObject:orangeLight];
        RowStaticScore *css = [[RowStaticScore alloc] init];
        css.position = ccp(orangeLight.position.x - ADJUST_2(5), orangeLight.position.y + ADJUST_2(8));
        [clippingNode addChild:css z:1-i];
        [colorNumbers addObject:css];
    }
    
    //Pause
    CCSprite *buttonPauseOff = [CCSprite spriteWithSpriteFrameName:@"logik_pauza_01.png"];
    CCSprite *buttonPauseOn = [CCSprite spriteWithSpriteFrameName:@"logik_pauza_02.png"];    
    CCMenuItem *pauseItem = [CCMenuItemSprite itemFromNormalSprite:buttonPauseOff selectedSprite:buttonPauseOn target:self selector:@selector(pauseTapped:)];

    pauseItem.tag = kButtonPause;
    pauseItem.anchorPoint = CGPointMake(0.5, 1);
    pauseItem.position = ADJUST_CCP_ABOVE(ccp(152.00, 481.00));    
    pauseMenu = [CCMenu menuWithItems:pauseItem, nil];
    pauseMenu.position = CGPointZero;
    
    //end game menu
    CCSprite *buttonEndOff = [CCSprite spriteWithSpriteFrameName:@"end_off.png"];
    CCSprite *buttonEndOn = [CCSprite spriteWithSpriteFrameName:@"end_on.png"];
    CCMenuItem *endGameItem = [CCMenuItemSprite itemFromNormalSprite:buttonEndOff selectedSprite:buttonEndOn target:self selector:nil];
    
    endGameItem.tag = kButtonEndGame;
    endGameItem.anchorPoint = CGPointMake(0.5, 1);
    endGameItem.position = ADJUST_CCP_ABOVE(ccp(152.00, 541.00));    
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
    
    //panels buttons/menus
    CCSprite *buttonReplayOff = [CCSprite spriteWithSpriteFrameName:@"logik_replay1.png"];
    CCSprite *buttonReplayOn = [CCSprite spriteWithSpriteFrameName:@"logik_replay2.png"];
    
    CCSprite *buttonGameMenuOff = [CCSprite spriteWithSpriteFrameName:@"logik_gmenu1.png"];
    CCSprite *buttonGameMenuOn = [CCSprite spriteWithSpriteFrameName:@"logik_gmenu2.png"];
    
    CCMenuItem *replayItem = [CCMenuItemSprite itemFromNormalSprite:buttonReplayOff selectedSprite:buttonReplayOn target:self selector:@selector(menuTapped:)];
    replayItem.tag = kButtonReplay;
    CCMenu *replayMenu = [CCMenu menuWithItems:replayItem, nil];
    replayMenu.position = ccp(66.00, 31.50);;
    [replayPanel addChild:replayMenu z:1];
    
    if (isCareer) {
        gameMenuRightPanel = [CCSprite spriteWithSpriteFrameName:@"rameno_right.png"];
        gameMenuRightPanel.scaleX = 5;
        gameMenuRightPanel.scaleY = 22;
        gameMenuRightPanel.visible = NO;
        [gameMenuRightPanel setPosition:ccp(1000.00, 367.00)];
        
        continuePanel = [CCSprite spriteWithSpriteFrameName:@"rameno_left.png"];
        continuePanel.scaleX = 5;
        continuePanel.scaleY = 22;
        continuePanel.visible = NO;
        [continuePanel setPosition:ccp(-700.00, 0.00)];
        
        CCSprite *buttonContinueOff = [CCSprite spriteWithSpriteFrameName:@"logik_continue1.png"];
        CCSprite *buttonContinueOn = [CCSprite spriteWithSpriteFrameName:@"logik_continue2.png"];
        
        CCMenuItem *gameMenuItemRight = [CCMenuItemSprite itemFromNormalSprite:buttonGameMenuOff selectedSprite:buttonGameMenuOn target:self selector:@selector(menuTapped:)];
        gameMenuItemRight.tag = kButtonGameMenu;
        CCMenu *gameMenuRight = [CCMenu menuWithItems:gameMenuItemRight, nil];
        gameMenuRight.position = ccp(66.00, 31.50);
        [gameMenuRightPanel addChild:gameMenuRight z:1];
        
        CCMenuItem *continueItem = [CCMenuItemSprite itemFromNormalSprite:buttonContinueOff selectedSprite:buttonContinueOn target:self selector:@selector(menuTapped:)];
        continueItem.tag = kButtonContinue;
        CCMenu *continueMenu = [CCMenu menuWithItems:continueItem, nil];
        continueMenu.position = ccp(195.50, 35.50);
        [continuePanel addChild:continueMenu z:1];
        
        [self addChild:gameMenuRightPanel z:32];
        [self addChild:continuePanel z:33];

    } else {
        gameMenuLeftPanel = [CCSprite spriteWithSpriteFrameName:@"rameno_left.png"];
        gameMenuLeftPanel.scaleX = 5;
        gameMenuLeftPanel.scaleY = 22;
        gameMenuLeftPanel.visible = NO;
        [gameMenuLeftPanel setPosition:ccp(-700.00, 0.00)];
        
        CCMenuItem *gameMenuItemLeft = [CCMenuItemSprite itemFromNormalSprite:buttonGameMenuOff selectedSprite:buttonGameMenuOn target:self selector:@selector(menuTapped:)];
        gameMenuItemLeft.tag = kButtonGameMenu;
        CCMenu *gameMenuLeft = [CCMenu menuWithItems:gameMenuItemLeft, nil];
        gameMenuLeft.position = ccp(195.50, 35.50);
        [gameMenuLeftPanel addChild:gameMenuLeft z:2];
        
        [self addChild:gameMenuLeftPanel z:32];
    }
    

    
    
    CCSprite *shadowBase = [CCSprite spriteWithSpriteFrameName:@"shadowBase.png"];
    shadowBase.anchorPoint = ccp(0,1);
    shadowBase.position = ccp(0, 115);
    
    
    //add nodes to display list
    [self addChild:movableNode z:1 tag:2];
        [movableNode addChild:bg z:-1 tag:-1];
        [movableNode addChild:highlightSprite z:200];
        //[movableNode addChild:deadFiguresNodeMask z:1];
        //[deadFiguresNodeMask addChild:deadFiguresNode z:1];
        [movableNode addChild:deadFiguresNode z:1];
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
        //[scoreTime addChild:timer z:4];//testing timeru - pak vyhodit
    //timer.position = ccp(150, 200);
        [scoreTime addChild:finalTimeLayer z:5];
        [scoreTime addChild:finalScoreLayer z:6];
        [scoreTime addChild:scoreTimeSprite z:7];
        [scoreTime addChild:final2ScoreLayer z:8];
        [scoreTime addChild:final2TimeLayer z:9];
        [scoreTime addChild:final3TimeLayer z:10];
    [self addChild:pauseMenu z:20];
    [self addChild:endGameMenu z:21];
    [self addChild:scorePanel z:22];
    [self addChild:replayPanel z:31];
    [self addChild:tutorLayer z:5000];
    
    dustSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"dust1.plist"];
    [self addChild:dustSystem z:1000];
}

#pragma mark 8 figures to base 
- (void) addFigures {    
    movableFigures = [[CCArray alloc] init];
    
    float pinchXpos[8] = {30.55, 69.11, 107.66, 145.22, 182.77, 220.33, 258.88, 296.44};
    
    for (int i = 0; i < 8; ++i) {
        Figure *figure = [[Figure alloc] initWithFigureType:i];
        figure.position = ccp(ADJUST_X_FIGURE_BASE(pinchXpos[i]), ADJUST_Y_FIGURE_BASE(29.0f));
        figure.originalPosition = ccp(figure.position.x, figure.position.y);
        [figuresNode addChild:figure z:i];
        [movableFigures addObject:figure];
    }    
}

#pragma mark Generate game code 
- (void) generateCode {
    currentCode = [[NSMutableArray alloc] init];
    NSMutableArray *code;
    CCArray *hiddenPattern = [[CCArray alloc] initWithCapacity:currentDifficulty];
    if ([[GameManager sharedGameManager] gameInProgress]) {
        code = [[[GameManager sharedGameManager] gameData] getCode];
    }
    for (int i = 0; i < currentDifficulty; ++i) {
        int gameCode;
        if ([[GameManager sharedGameManager] gameInProgress] && code.count == currentDifficulty) {
            gameCode = [[[code objectAtIndex:i] objectForKey:@"color"] intValue];
        } else {
            gameCode = [Utils randomNumberBetween:0 andMax:8];
            [[[GameManager sharedGameManager] gameData] insertCode:gameCode];
        }        
        //Figure *figure = [[Figure alloc] initWithFigureType:[Utils randomNumberBetween:0 andMax:8]];
        [hiddenPattern addObject:[NSNumber numberWithInt:gameCode]];
        Figure *figure = [[Figure alloc] initWithFigureType:gameCode];
        figure.place = i;
        figure.anchorPoint = CGPointMake(0, 0);
        figure.position = ADJUST_CCP_LEVEL_CODE(ccp(6 + difficultyPadding*i, 5.0f));
        
        Figure *cheatFigure = [[Figure alloc] initWithFigureType:gameCode];
        cheatFigure.anchorPoint = CGPointMake(0, 0);
        cheatFigure.position = ADJUST_CCP(ccp(100 + 20*i, 460));
        cheatFigure.scale = 0.5;
        cheatFigure.opacity = 255;
        
        [codeBase addChild:figure z:i];
        [currentCode addObject:figure];
        [self addChild:cheatFigure z:3000 + i];
    }
    scoreCalc.hiddenPattern = hiddenPattern;
}

#pragma mark Construct score Label
- (void) constructScoreLabelWithLayer:(CCLayer *)layer andArray:(CCArray *)array andLength:(int)length andRotation:(float)rotation andXpos:(float)xPos andYPos:(float)yPos {
    for (int i = 0; i<length; i++) {
        Mask *scoreMask = [Mask maskWithRect:CGRectMake(ADJUST_2(xPos) + 9*ADJUST_2(i), ADJUST_2(yPos), ADJUST_2(9), ADJUST_2(18))];
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
        sprite.position = ADJUST_CCP(ccp(32.0 + i*difficultyPadding, 81.0 + row*44));
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
    PLAYSOUNDEFFECT(BUTTON_LEVEL_CLICK);
    gameInfo infoData;
    infoData.difficulty = currentDifficulty;
    infoData.activeRow = activeRow;
    infoData.career = isCareer ? 1 : 0;
    infoData.score = score;
    infoData.gameTime = timer.gameTime;
    [[[GameManager sharedGameManager] gameData] insertGameData:infoData];
    
    [[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kSlideInR];
}

#pragma mark Final menu buttons
- (void) menuTapped:(CCMenuItem *)sender {
    PLAYSOUNDEFFECT(BUTTON_LEVEL_CLICK);
    switch (sender.tag) {
        case kButtonReplay:
            [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kNoTransition];
            break;
        case kButtonGameMenu:
            [[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kSlideInL];
            break;
        case kButtonContinue:
            [[GameManager sharedGameManager] runSceneWithID:kCareerScene andTransition:kSlideInL];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;    
    }
}


#pragma mark End game button
- (void) endGameTapped {
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_LEVEL];
    PLAYSOUNDEFFECT(GIP);
    finalMenu.visible = NO;
    float delay;
    if (isWinner) {
        finalScoreLabel.visible = NO;
        
        if (score < maxScore) {
            id wdBigOut = [CCFadeOut actionWithDuration:.2];
            [wdBig runAction:wdBigOut];
        } else {
            id superBigOut = [CCFadeOut actionWithDuration:.2];
            id superSmallOut = [CCFadeOut actionWithDuration:.2];
            [superBig runAction:superBigOut];
            [superSmall runAction:superSmallOut];
        }
        
        CCMoveTo *scoreMoveOut = [CCMoveTo actionWithDuration:0.4 position:ccp(-700.00, 0.00)];
        CCScaleTo *scoreScaleOutX = [CCScaleTo actionWithDuration:0.4 scaleX:5 scaleY:22];
        CCRotateTo *scoreRotationOut = [CCRotateTo actionWithDuration:1.0 angle:0];
        CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], scoreMoveOut, scoreScaleOutX, scoreRotationOut, nil];
        
        CCSequence *scoreTimeSeq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: 0.0f],
                                    [CCMoveTo actionWithDuration:.3 position:CGPointMake(scoreTime.position.x, scoreTime.position.y + 30)],
                                    [CCCallFunc actionWithTarget:self selector:@selector(labelsOutCallback)],
                                    nil];
        [final2ScoreLayer removeFromParentAndCleanup:YES];
        [final2TimeLayer removeFromParentAndCleanup:YES];
        [final3TimeLayer removeFromParentAndCleanup:YES];
        [self constructEndLabels:timer.gameTime andZero:YES];
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
    
    if (isCareer) {
        CCMoveTo *replayMoveIn = [CCMoveTo actionWithDuration:0.6 position:ccp(225.50, 285.00)];
        CCScaleTo *replayScaleInX = [CCScaleTo actionWithDuration:0.6 scaleX:1.0 scaleY:1.0];
        CCRotateTo *replayRotationIn = [CCRotateTo actionWithDuration:0.6 angle:1];        
        CCSpawn *replaySeq = [CCSpawn actions:[CCDelayTime actionWithDuration: delay], replayMoveIn, replayScaleInX, replayRotationIn, nil];
        
        CCMoveTo *continueMoveIn = [CCMoveTo actionWithDuration:.6 position:ccp(100.00, 220.00)];
        CCScaleTo *continueScaleInX = [CCScaleTo actionWithDuration:.6 scaleX:1.0 scaleY:1.0];
        CCRotateTo *continueRotationIn = [CCRotateTo actionWithDuration:.6 angle:-2];
        CCSpawn *continueSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: delay], continueMoveIn, continueScaleInX, continueRotationIn, nil];
        
        CCMoveTo *gmRightMoveIn = [CCMoveTo actionWithDuration:0.6 position:ccp(230.50, 170.00)];
        CCScaleTo *gmRightScaleInX = [CCScaleTo actionWithDuration:0.6 scaleX:1.0 scaleY:1.0];
        CCRotateTo *gmRightRotationIn = [CCRotateTo actionWithDuration:0.6 angle:1];        
        CCSpawn *gmRightSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: delay], gmRightMoveIn, gmRightScaleInX, gmRightRotationIn, nil];        
        
        replayPanel.visible = YES;
        continuePanel.visible = YES;
        gameMenuRightPanel.visible = YES;
        
        [replayPanel runAction:replaySeq];
        [continuePanel runAction:continueSeq];
        [gameMenuRightPanel runAction:gmRightSeq];
    } else {
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
    }
}

- (void) fbMailTapped {
    PLAYSOUNDEFFECT(BUTTON_LEVEL_CLICK);
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
    id actionDelay = [CCDelayTime actionWithDuration:0.2];
    [self runAction:[CCSequence actions:actionDelay, [CCCallFuncND actionWithTarget:self selector:@selector(results:data:) data:[NSNumber numberWithInt:activeRow]], nil]];    
    [[[GameManager sharedGameManager] gameData] gameDataCleanup];
    isMovable = NO;
    longPress.enabled = NO;
    isWinner = currentDifficulty == places ? YES : NO;
    if (isCareer) {
        [[[GameManager sharedGameManager] gameData] updateCareerData:isWinner andScore:score];//mazu posledni karierni hru pri neuspechu?
    } else {
        [[[GameManager sharedGameManager] gameData] writeScore:[Utils randomNumberBetween:1000 andMax:99999999] andDifficulty:currentDifficulty];
    }
    [self constructEndLabels:[timer stopTimer] andZero:NO];
    [[GameManager sharedGameManager] stopLoopSounds];
    [self openLock];
}


- (void) constructEndLabels:(int)time andZero:(BOOL)toZero {
    //time label
    if (!toZero) {
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
    } else {
        CCSprite *timePiece;
        int colonFlag = 0;
        for (int i = 0; i < 4; i++) {
            if (i == 2) {
                colonFlag = 4;
                CCSprite *colon = [CCSprite spriteWithSpriteFrameName:@"colon.png"];
                colon.anchorPoint = ccp(0,0);
                colon.position = ccp(279 + i*9, 456);
                [finalTimeLayer addChild:colon z:i + 5];
            }
            int piece = 0;
            timePiece = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", piece]];
            timePiece.anchorPoint = ccp(0,0);
            timePiece.position = ccp(279 + i*9 + colonFlag, 456);
            [finalTimeLayer addChild:timePiece z:i];
        }
    }
    //score label
    NSString *finalScore = [NSString stringWithFormat:@"%i", score];
    CCSprite *labelPiece;
    int piece;
    for (int i = 0; i < 8; i++) {
        if (i < 8 - finalScore.length) {
            labelPiece = [CCSprite spriteWithSpriteFrameName:@"empty.png"];
        } else {
            if (toZero)
                piece = 0;
            else
                piece = [[NSString stringWithFormat:@"%c", [finalScore characterAtIndex:i - (8 - finalScore.length)]] intValue];
            labelPiece = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", piece]];
        }
        labelPiece.anchorPoint = ccp(0,0);
        labelPiece.position = ccp(9*i, 456.00);
        [finalScoreLayer addChild:labelPiece z:i];        
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
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(movableNode.position.x, movableNode.position.y - ADJUST_2(47))],
                           nil];
    CCSequence *codeSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(codeBase.position.x, codeBase.position.y - ADJUST_2(47))],
                           nil];
    CCSequence *figSeq = [CCSequence actions:
                          [CCDelayTime actionWithDuration: delay + 1.3f],
                          [CCMoveTo actionWithDuration:.4 position:CGPointMake(figuresNode.position.x, figuresNode.position.y - ADJUST_2(51))],
                          nil];
    CCSequence *baseSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(base.position.x, base.position.y - ADJUST_2(49))],
                           nil];
    
    CCSequence *clippingSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: delay + 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(clippingNode.position.x, clippingNode.position.y - ADJUST_2(49))],
                           [CCCallFunc actionWithTarget:self selector:@selector(openLockEnded)],
                           nil];
    
    CCSequence *scoreSeq = [CCSequence actions:
                               [CCDelayTime actionWithDuration: delay + 0.0f],
                               [CCMoveTo actionWithDuration:.4 position:CGPointMake(base.position.x, base.position.y + 30)],
                            [CCMoveTo actionWithDuration:.4 position:CGPointMake(scoreTime.position.x, base.position.y + 30)],
                               nil];
    CCSequence *pauseSeq = [CCSequence actions:
                            [CCDelayTime actionWithDuration: delay + 0.0f],
                            [CCMoveTo actionWithDuration:.4 position:CGPointMake(pauseMenu.position.x, base.position.y + 60)],
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
    float delayStep2 = 3.00;
    float delayStep3 = delayStep2 + 1.00;

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
        final1TimeArray = [[CCArray alloc] init];
        final2TimeArray = [[CCArray alloc] init];
        finalScoreArray = [[CCArray alloc] init];
        finalScoreLabel = [CCLayer node];
        finalScoreLabel.visible = NO;
        finalScoreLabel.rotation = -2;
        [self addChild:finalScoreLabel z:40];
        [self constructScoreLabelWithLayer:finalScoreLabel andArray:finalScoreArray andLength:8 andRotation:-2 andXpos:155 andYPos:226];
        //score Panel
        scorePanel.visible = YES;
        CCMoveTo *spMoveIn = [CCMoveTo actionWithDuration:.5 position:ccp(102.00, 220.00)];
        CCScaleTo *spScaleInX = [CCScaleTo actionWithDuration:.5 scaleX:1.0 scaleY:1.0];
        CCRotateTo *spRotationIn = [CCRotateTo actionWithDuration:.5 angle:-2];
        CCSpawn *moveSpSeq = [CCSpawn actions:spMoveIn, spScaleInX, spRotationIn, nil];
        CCSequence *spSeqIn = [CCSequence actions:[CCDelayTime actionWithDuration: delayStep2], moveSpSeq, [CCCallFunc actionWithTarget:self selector:@selector(spInCallback)], nil];
        
        CCSequence *scoreTimeSeq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: delayStep2],
                                    [CCMoveTo actionWithDuration:.3 position:CGPointMake(scoreTime.position.x, scoreTime.position.y - 30)],
                                    [CCCallFunc actionWithTarget:self selector:@selector(scoreTimeCallback)],
                                    nil];
        
        movesLabelBig = [CCLabelBMFont labelWithString:@"MOVES:" fntFile:@"Gloucester_levelBig.fnt"];
        movesLabelBig.scale = isRetina ? 1 : 0.5;
        movesLabelBig.opacity = 0;
        movesLabelBig.rotation = -2;
        movesLabelBig.position = ccp(screenSize.width/2 - 15, screenSize.height/2 + 40);
        [self addChild:movesLabelBig z:21];
        CCSequence *movesTimeSeq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: delayStep3 - 0.5f],
                                    [CCFadeIn actionWithDuration:.3],
                                    nil];
        CCSequence *movesTimeOutSeq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: delayStep3 + 1.5f],
                                    [CCFadeOut actionWithDuration:.2],
                                    [CCCallFunc actionWithTarget:self selector:@selector(timeBonusCallback)],   
                                    nil];
        
        timeLabelBig = [CCLabelBMFont labelWithString:@"TIME BONUS:" fntFile:@"Gloucester_levelBig.fnt"];
        timeLabelBig.scale = isRetina ? 1 : 0.5;
        timeLabelBig.opacity = 0;
        timeLabelBig.rotation = -2;
        timeLabelBig.position = ccp(screenSize.width/2 - 15, screenSize.height/2 + 40);
        [self addChild:timeLabelBig z:21];
        CCSequence *movesTime2Seq = [CCSequence actions:
                                    [CCDelayTime actionWithDuration: delayStep3 + 2.0f],
                                    [CCFadeIn actionWithDuration:.3],
                                    nil];
        CCSequence *movesTimeOut2Seq = [CCSequence actions:
                                       [CCDelayTime actionWithDuration: delayStep3 + 3.0f],
                                       [CCFadeOut actionWithDuration:.2],
                                       nil];
        if (score <= maxScore) {
            wdBig = [CCLabelBMFont labelWithString:@"WELL DONE!" fntFile:@"Gloucester_levelBig.fnt"];
            wdBig.scale = isRetina ? 1 : 0.5;
            wdBig.opacity = 0;
            wdBig.rotation = -2;
            wdBig.position = ccp(screenSize.width/2 - 15, screenSize.height/2 + 40);
            [self addChild:wdBig z:21];
            CCSequence *wdSeq = [CCSequence actions:
                                         [CCDelayTime actionWithDuration: delayStep3 + 4.0f],
                                         [CCFadeIn actionWithDuration:.3],
                                            [CCCallFunc actionWithTarget:self selector:@selector(sharingCallback)],
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
                                 [CCDelayTime actionWithDuration: delayStep3 + 4.0f],
                                 [CCFadeIn actionWithDuration:.3],
                                 nil];
            CCSequence *super2Seq = [CCSequence actions:
                                     [CCDelayTime actionWithDuration: delayStep3 + 4.0f],
                                     [CCFadeIn actionWithDuration:.3],
                                     [CCCallFunc actionWithTarget:self selector:@selector(sharingCallback)],
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
    } else {
        singleTap.enabled = YES;
        failLabelSmall = [CCLabelBMFont labelWithString:@"THIS CODE WAS TOUGH" fntFile:@"Gloucester_levelSmall.fnt"];
        failLabelSmall.scale = isRetina ? 0.9 : 0.45;
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

- (void) sharingCallback {
    CCSprite *buttonFb = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb.png"];
    CCSprite *buttonMail = [CCSprite spriteWithSpriteFrameName:@"logik_iconmail.png"];
    buttonFb.opacity = 0;
    buttonMail.opacity = 0;
    
    CCMenuItem *fbItem = [CCMenuItemSprite itemFromNormalSprite:buttonFb selectedSprite:nil target:self selector:@selector(fbMailTapped)];
    fbItem.tag = kButtonFb;
    fbItem.position = ccp(70.00, 80.00);
    
    CCMenuItem *mailItem = [CCMenuItemSprite itemFromNormalSprite:buttonMail selectedSprite:nil target:self selector:@selector(fbMailTapped)];
    mailItem.tag = kButtonMail;
    mailItem.position = ccp(260.00, 80.00);
    
    finalMenu = [CCMenu menuWithItems:fbItem, mailItem, nil];
    finalMenu.position = CGPointZero;
    [self addChild:finalMenu z:60];
    
    id fbFadeIn = [CCSequence actions:[CCDelayTime actionWithDuration: 0.7], [CCFadeIn actionWithDuration:0.5], nil];
    id mailFadeIn = [CCSequence actions:[CCDelayTime actionWithDuration: 0.9], [CCFadeIn actionWithDuration:0.5], nil];
    
    [buttonFb runAction:fbFadeIn];
    [buttonMail runAction:mailFadeIn];
}

- (void) scoreTimeCallback {
    [self constructScoreLabelWithLayer:final2ScoreLayer andArray:scoreLabelArray andLength:8 andRotation:0 andXpos:0 andYPos:456.50];
    [self drawScoreToLabel:score andArray:scoreLabelArray andStyle:NO andZero:NO];
    
    [self constructScoreLabelWithLayer:final2TimeLayer andArray:final1TimeArray andLength:2 andRotation:0 andXpos:279 andYPos:456.00];
    [self drawTimeToLabel:(int)timer.gameTime/60 andArray:final1TimeArray andStyle:NO andZero:NO];

    [self constructScoreLabelWithLayer:final3TimeLayer andArray:final2TimeArray andLength:2 andRotation:0 andXpos:300.50 andYPos:456.00];
    [self drawTimeToLabel:(int)timer.gameTime%60 andArray:final2TimeArray andStyle:NO andZero:NO];
     PLAYSOUNDEFFECT(GIP);
}

- (void) spInCallback {
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_WINNER];
    
    //PLAYSOUNDEFFECT(WINNER);
    finalScoreLabel.visible = YES;
    singleTap.enabled = YES;
    [self drawScoreToLabel:score andArray:finalScoreArray andStyle:YES andZero:NO];
    [self drawScoreToLabel:score andArray:scoreLabelArray andStyle:YES andZero:YES];
}

- (void) timeBonusCallback {
    int fuckUp = 98654871;
    [self drawScoreToLabel:fuckUp andArray:finalScoreArray andStyle:YES andZero:NO];
    [self drawTimeToLabel:(int)timer.gameTime/60 andArray:final1TimeArray andStyle:YES andZero:YES];
    [self drawTimeToLabel:(int)timer.gameTime%60 andArray:final2TimeArray andStyle:YES andZero:YES];
}

- (void) skipFinalPresentation:(CCMenuItem *)sender {
    PLAYSOUNDEFFECT(BUTTON_LEVEL_CLICK);
    movesLabelBig.visible = NO;
    timeLabelBig.visible = NO;
    wdBig.visible = NO;
    superBig.visible = NO;
    superSmall.visible = NO;
    failLabelSmall.visible = NO;
    failLabelBig.visible = NO;
    finalScoreLabel.visible = NO;
    [self endGameTapped];    
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
    CCLOG(@"****/n****/n****/n****/n****/n****/n****/n****/n****/n****/n****/n****/nCALCULATE SCORE****/n****/n****/n****/n****/n****/n****/n****/n****/n****/n****/n****/n");
    lastTime = timer.gameTime - lastTime;
    CCArray *turn = [[CCArray alloc] initWithCapacity:currentDifficulty];
    for (int i = 0; i < currentDifficulty; i++) {
        for (Figure *userSprite in userCode) {
            if (userSprite.place == i) {
                [turn addObject:[NSNumber numberWithInt:userSprite.currentFigure]];
            }
        }
    }
    //score = [scoreCalc calculateScoreWithRow:activeRow andTurn:turn];
    score = [Utils randomNumberBetween:1000 andMax:2000];
    [self drawScoreToLabel:score andArray:scoreLabelArray andStyle:YES andZero:NO];    
}

- (void) drawScoreToLabel:(int)value andArray:(CCArray *)array andStyle:(BOOL)animated andZero:(BOOL)toZero {
    NSString *scoreString = [NSString stringWithFormat:@"%i", value];
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[scoreString length]];
    for (int i=0; i < [scoreString length]; i++) {
        NSString *ichar;
        if (toZero)
            ichar  = [NSString stringWithFormat:@"%i", 0];
        else
            ichar  = [NSString stringWithFormat:@"%c", [scoreString characterAtIndex:i]];
        [characters addObject:ichar];
    }
    ScoreNumber *tempScoreNumber;
    for (int i=0; i < [characters count]; i++) {
        tempScoreNumber = [array objectAtIndex:i];
        int pos = [[[[characters reverseObjectEnumerator] allObjects] objectAtIndex:i] intValue];
        if (animated)
            [tempScoreNumber moveToPosition:pos];
        else
            [tempScoreNumber jumpToPosition:pos];
    }
}

- (void) drawTimeToLabel:(int)value andArray:(CCArray *)array andStyle:(BOOL)animated andZero:(BOOL)toZero {
    NSString *scoreString = [NSString stringWithFormat:@"%02d", value];
    CCLOG(@"TIME STRING %@", scoreString);
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[scoreString length]];
    for (int i=0; i < [scoreString length]; i++) {
        NSString *ichar;
        if (toZero)
            ichar  = [NSString stringWithFormat:@"%i", 0];
        else
            ichar  = [NSString stringWithFormat:@"%c", [scoreString characterAtIndex:i]];
        [characters addObject:ichar];
    }
    ScoreNumber *tempScoreNumber;
    for (int i=0; i < [characters count]; i++) {
        tempScoreNumber = [array objectAtIndex:i];
        int pos = [[[[characters reverseObjectEnumerator] allObjects] objectAtIndex:i] intValue];
        if (animated)
            [tempScoreNumber moveToPosition:pos];
        else
            [tempScoreNumber jumpToPosition:pos];
    }
}

- (void) nextRow {
    [userCode removeAllObjects];
    
    id actionDelay = [CCDelayTime actionWithDuration:0.2];
	[self runAction:[CCSequence actions:actionDelay, [CCCallFuncND actionWithTarget:self selector:@selector(results:data:) data:[NSNumber numberWithInt:activeRow]], nil]];
    
    activeRow ++;
    
    gameInfo infoData;
    infoData.difficulty = currentDifficulty;
    infoData.activeRow = activeRow;
    infoData.career = isCareer ? 1 : 0;
    infoData.score = score;
    infoData.gameTime = timer.gameTime;
    [[[GameManager sharedGameManager] gameData] insertGameData:infoData];
    
    [[[GameManager sharedGameManager] gameData] deleteActiveFigures];
    
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
    
    fid = fid + 1;
    sprite.isOnActiveRow = YES;
    sprite.fid = fid;
    sprite.oldPlace = sprite.place;
    sprite.tempPosition = ccp(sprite.position.x, sprite.position.y);
    spriteEndPosition = sprite.position.y;
    sprite.movePosition = ccp(sprite.position.x, sprite.position.y - trans);
    
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
        
        [[[GameManager sharedGameManager] gameData] deleteActiveFigure:sprite.place];
    }
    
    [userCode addObject:sprite];
    
    [figuresNode reorderChild:selSprite z:sprite.zOrder - 100];
    
    activeFigure dbFigure;
    dbFigure.fid = fid;
    dbFigure.color = sprite.currentFigure;
    dbFigure.position = sprite.position;
    dbFigure.place = sprite.place;
    [[[GameManager sharedGameManager] gameData] insertActiveFigure:dbFigure];
    
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
        [[[GameManager sharedGameManager] gameData] updateActiveFigure:existSprite.fid withPlace:sprite.oldPlace andPosition:sprite.tempPosition];
        existSprite.place = sprite.oldPlace;
        existSprite.oldPlace = sprite.oldPlace;
        existSprite.position = sprite.tempPosition;
        existSprite.tempPosition = ccp(sprite.tempPosition.x, sprite.tempPosition.y);
    }
    [[[GameManager sharedGameManager] gameData] updateActiveFigure:sprite.fid withPlace:sprite.place andPosition:sprite.position];
    sprite.oldPlace = sprite.place;
}

- (void) figureSetCorrectPosition:(id)sender data:(Figure *)sprite {
    PLAYSOUNDEFFECT(FIGURE_MOVE);
    [[[GameManager sharedGameManager] gameData] updateActiveFigurePosition:sprite.fid andPosition:sprite.position];
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
            
            gameInfo infoData;
            infoData.difficulty = currentDifficulty;
            infoData.activeRow = activeRow;
            infoData.career = isCareer ? 1 : 0;
            infoData.score = score;
            infoData.gameTime = timer.gameTime;
            [[[GameManager sharedGameManager] gameData] insertGameData:infoData];
            
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
- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    singleTap.enabled = NO;
    [self skipFinalPresentation:nil];
}


- (CGPoint) boundMovePos:(CGPoint)translation withPosition:(CGPoint)position andNode:(CCNode *)node {
    CGPoint retval = ccp(node.position.x, node.position.y + translation.y);
    retval.y = MIN(retval.y, position.y);
    if (activeRow == 7) {
        retval.y = MAX(retval.y, position.y - 45);
    }
    if (activeRow > 7) {
        retval.y = MAX(retval.y, position.y - 90);
    }
    return retval;
}

#pragma mark Pan gestures handler
- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        if (abs(translation.x) > LEVEL_SWIPE && !selSprite) {
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
    
    [final1TimeArray release];
    [final2TimeArray release];
    final1TimeArray = nil;
    final2TimeArray = nil;
    
    [super dealloc];
}

@end