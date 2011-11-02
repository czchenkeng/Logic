//
//  MainLayer.m
//  Logic
//
//  Created by Pavel Krusek on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainLayer.h"

@interface MainLayer (PrivateMethods)
- (void) runParticle;
- (void) animationIn;
- (void) animationThreeIn;
- (void) addHowTo;
- (void) removeHowTo;
- (void) logicTransition;
- (void) buttonsOut;
- (void) lampOut;
- (void) addBanner;
@end


@implementation MainLayer

#pragma mark -
#pragma mark INIT
#pragma mark Designated initializer
- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        flag = 30;
        flag2 = 0;
        lightOn = YES;
        isThree = NO;
        //CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kMainMainTexture];
        
        doors = [CCSprite spriteWithSpriteFrameName:@"doors.png"];
        doors.position = kMainDoorsPosition;
        
        background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        
        CCSprite *logoShadow = [CCSprite spriteWithSpriteFrameName:@"logo_shadow.png"];
        logoShadow.position = kMainLogoShadowPosition;
        
        CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"logo.png"];
        logo.position = kMainLogoPosition;
        
        CCSprite *grass = [CCSprite spriteWithSpriteFrameName:@"grass.png"];
        grass.position = kMainGrassPosition;
        
        rightGib = [CCSprite spriteWithSpriteFrameName:@"rameno_right.png"];
        rightGib.scaleY = 22;
        rightGib.scaleX = 5;
//        rightGib.scaleY = 5;
//        rightGib.scaleX = 5;
        rightGib.position = kMainRightGibOutPosition;
        
        leftGib = [CCSprite spriteWithSpriteFrameName:@"rameno_left.png"];
        leftGib.scaleY = 22;
        leftGib.scaleX = 5;
        //leftGib.scaleY = 5;
        //leftGib.scaleX = 5;
        leftGib.position = kMainLeftGibOutPosition;
        
        rightGib.opacity = 0;
        leftGib.opacity = 0;
        
        rightSingleGib = [CCSprite spriteWithSpriteFrameName:@"rameno_right.png"];
        rightSingleGib.scaleY = 22;
        rightSingleGib.scaleX = 5;
        rightSingleGib.position = kMainRightGibOutPosition;
        
        //INFO, SETTINGS
        CCSprite *buttonInfoOff = [CCSprite spriteWithSpriteFrameName:@"i_off.png"];
        CCSprite *buttonInfoOn = [CCSprite spriteWithSpriteFrameName:@"i_on.png"];
        CCSprite *buttonSettingsOff = [CCSprite spriteWithSpriteFrameName:@"settings_off.png"];
        CCSprite *buttonSettingsOn = [CCSprite spriteWithSpriteFrameName:@"settings_on.png"];
        
//        CCMenuItem *infoItem = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:buttonInfoOn target:self selector:@selector(buttonTapped:)];
//        infoItem.tag = kButtonInfo;
//        infoItem.anchorPoint = CGPointMake(0.5, 1);
//        infoItem.position = kRightNavigationButtonPosition;
        CCMenuItem *settingsItem = [CCMenuItemSprite itemFromNormalSprite:buttonSettingsOff selectedSprite:buttonSettingsOn target:self selector:@selector(buttonTapped:)];
        settingsItem.tag = kButtonSettings;
        settingsItem.anchorPoint = CGPointMake(0.5, 1);
        settingsItem.position = kLeftNavigationButtonPosition;
        
        topMenu = [CCMenu menuWithItems:settingsItem, nil];
        topMenu.position = CGPointZero;
        
        
        
        infoOff = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:nil target:nil selector:nil];
        infoOn = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOn selectedSprite:nil target:nil selector:nil];
        
        toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(infoButtonTapped:) items:infoOff, infoOn, nil];
        toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = kRightNavigationButtonPosition;
        toggleItem.anchorPoint = CGPointMake(0.5, 1);
        
        lightOff = [CCSprite spriteWithSpriteFrameName:@"lightOff.png"];
        lightOff.anchorPoint = ccp(0.5,1);
        lightOff.position = kMainLightPosition;
        lightOff.rotation = -4.0;
        lightOff.visible = NO;
        
        //HD sprites
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kMainHqTexture];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        light = [CCSprite spriteWithSpriteFrameName:@"light.png"];
        light.anchorPoint = ccp(0.5,1);
        light.position = kMainLightPosition;
        light.rotation = -4.0;
        
        //Animations
        CCRotateTo *rotRight = [CCRotateBy actionWithDuration:1.1 angle:-8.0];
        CCRotateTo *rotLeft = [CCRotateBy actionWithDuration:1.1 angle:8.0];
        CCEaseInOut *easeRight = [CCEaseInOut actionWithAction:rotRight rate:3];
        CCEaseInOut *easeLeft = [CCEaseInOut actionWithAction:rotLeft rate:3];
        CCSequence *rotSeq = [CCSequence actions:easeLeft, easeRight, [CCCallFunc actionWithTarget:self selector:@selector(moveLampCallback)], nil];
        //rotSeq.tag = 
        
        CCRotateTo *rotRight1 = [CCRotateBy actionWithDuration:1.1 angle:-8.0];
        CCRotateTo *rotLeft1 = [CCRotateBy actionWithDuration:1.1 angle:8.0];        
        CCEaseInOut *easeRight1 = [CCEaseInOut actionWithAction:rotRight1 rate:3];
        CCEaseInOut *easeLeft1 = [CCEaseInOut actionWithAction:rotLeft1 rate:3];        
        CCSequence *rotSeq1 = [CCSequence actions:easeLeft1, easeRight1, nil];
        
        CCMoveTo *moveLeft = [CCMoveTo actionWithDuration:1.1 position:kMainLogoShadowMoveLeft];
        CCMoveTo *moveRight = [CCMoveTo actionWithDuration:1.1 position:kMainLogoShadowMoveRight];
        CCEaseInOut *easeMoveLeft = [CCEaseInOut actionWithAction:moveRight rate:3];
        CCEaseInOut *easeMoveRight = [CCEaseInOut actionWithAction:moveLeft rate:3];
        CCSequence *moveSeq = [CCSequence actions:easeMoveLeft, easeMoveRight, nil];
                
        [light runAction:[CCRepeatForever actionWithAction:rotSeq]];
        [lightOff runAction:[CCRepeatForever actionWithAction:rotSeq1]];
        [logoShadow runAction:[CCRepeatForever actionWithAction:moveSeq]];
        
        //SINGLE, CAREER
        CCSprite *buttonSingleOff = [CCSprite spriteWithSpriteFrameName:@"logik_single1.png"];
        CCSprite *buttonSingleOn = [CCSprite spriteWithSpriteFrameName:@"logik_single2.png"];
        
        #ifdef LITE_VERSION
            CCSprite *buttonCareerOff = [CCSprite spriteWithSpriteFrameName:@"logik_full1.png"];
            CCSprite *buttonCareerOn = [CCSprite spriteWithSpriteFrameName:@"logik_full2.png"];
        #else
            CCSprite *buttonCareerOff = [CCSprite spriteWithSpriteFrameName:@"logik_career1.png"];
            CCSprite *buttonCareerOn = [CCSprite spriteWithSpriteFrameName:@"logik_career2.png"];
        #endif
        
        CCMenuItem *singlePlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonSingleOff selectedSprite:buttonSingleOn target:self selector:@selector(buttonTapped:)];
        singlePlayItem.tag = kButtonSinglePlay;
        singleMenu = [CCMenu menuWithItems:singlePlayItem, nil];
        //singleMenu.position = ccp(66.00, 31.50);
        singleMenu.position = kMainRightGibButtonPosition;
        //[singleMenu setOpacity:0];
        
        CCMenuItem *careerPlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonCareerOff selectedSprite:buttonCareerOn target:self selector:@selector(buttonTapped:)];
        careerPlayItem.tag = kButtonCareerPlay;
        careerMenu = [CCMenu menuWithItems:careerPlayItem, nil];
        //careerMenu.position = ccp(195.50, 35.50);
        careerMenu.position = kMainLeftGibButtonPosition;
        //[careerMenu setOpacity:0];
        
        //CONTINUE - SINGLE, CAREER, SAME POSITIONS
        CCSprite *buttonContinueOff = [CCSprite spriteWithSpriteFrameName:@"logik_continue1.png"];
        CCSprite *buttonContinueOn = [CCSprite spriteWithSpriteFrameName:@"logik_continue2.png"];
        
        CCMenuItem *continuePlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonContinueOff selectedSprite:buttonContinueOn target:self selector:@selector(buttonTapped:)];
        continuePlayItem.tag = kButtonContinuePlay;
        continueMenu = [CCMenu menuWithItems:continuePlayItem, nil];
        //continueMenu.position = ccp(66.00, 31.50);
        continueMenu.position = kMainRightGibButtonPosition;
        
        //QUIT CAREER - CAREER, SAME POSITION AS CAREER PLAY
        CCSprite *buttonQuitOff = [CCSprite spriteWithSpriteFrameName:@"logik_quit1.png"];
        CCSprite *buttonQuitOn = [CCSprite spriteWithSpriteFrameName:@"logik_quit2.png"];
        CCMenuItem *quitItem = [CCMenuItemSprite itemFromNormalSprite:buttonQuitOff selectedSprite:buttonQuitOn target:self selector:@selector(buttonTapped:)];
        quitItem.tag = kButtonQuitCareer;
        quitMenu = [CCMenu menuWithItems:quitItem, nil];
        //newGameMenu.position = ccp(195.50, 35.50);
        quitMenu.position = kMainLeftGibButtonPosition;
        
        //NEW, GAME MENU - SINGLE
        CCSprite *buttonNewGameOff = [CCSprite spriteWithSpriteFrameName:@"logik_new1.png"];
        CCSprite *buttonNewGameOn = [CCSprite spriteWithSpriteFrameName:@"logik_new2.png"];
        CCMenuItem *newGameItem = [CCMenuItemSprite itemFromNormalSprite:buttonNewGameOff selectedSprite:buttonNewGameOn target:self selector:@selector(buttonTapped:)];
        newGameItem.tag = kButtonNewGame;
        newGameMenu = [CCMenu menuWithItems:newGameItem, nil];
        //newGameMenu.position = ccp(195.50, 35.50);
        newGameMenu.position = kMainLeftGibButtonPosition;
        
        CCSprite *buttonGameMenuOff = [CCSprite spriteWithSpriteFrameName:@"logik_gmenu1.png"];
        CCSprite *buttonGameMenuOn = [CCSprite spriteWithSpriteFrameName:@"logik_gmenu2.png"];
        CCMenuItem *gameMenuItem = [CCMenuItemSprite itemFromNormalSprite:buttonGameMenuOff selectedSprite:buttonGameMenuOn target:self selector:@selector(buttonTapped:)];
        gameMenuItem.tag = kButtonGameMenu;
        gameMenu = [CCMenu menuWithItems:gameMenuItem, nil];
        //newGameMenu.position = ccp(195.50, 35.50);
        gameMenu.position = kMainRightGibButtonPosition;
        
        [self addChild:doors z:1];
        [self addChild:background z:2];
        [self addChild:logoShadow z:3];
        [self addChild:logo z:4];
        [self addChild:grass z:5];
        [self addChild:rightGib z:10];
            [rightGib addChild:singleMenu z:1];
            [rightGib addChild:continueMenu z:2];
        [self addChild:leftGib z:11];
            [leftGib addChild:careerMenu z:1];
            [leftGib addChild:newGameMenu z:2];
            [leftGib addChild:quitMenu z:3];
        [self addChild:rightSingleGib z:12];
            [rightSingleGib addChild:gameMenu z:1];
        [self addChild:lightOff z:15];
        [self addChild:light z:14];
        [self addChild:topMenu z:30];
        [self addChild:toggleMenu z:30];
        
        [self runParticle];
        [self scheduleUpdate];
        
        if ([GameManager sharedGameManager].oldScene == kGameScene) {
            doors.position = ccp(doors.position.x - 195, doors.position.y);
            id doorsIn = [CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCMoveTo actionWithDuration:0.4 position:ccp(doors.position.x + 195, doors.position.y)], nil];
            [doors runAction:doorsIn];
        }
        #ifdef LITE_VERSION
            [self addBanner];
        #endif        
    }
    return self;
}

- (void) addBanner {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    controller = [[RootViewController alloc] init];
    controller.view.frame = CGRectMake(0,0,size.width,size.height);
    
//    if (iPad && !retina){
//        
//        bannerView = [[GADBannerView alloc]
//                      initWithFrame:CGRectMake(size.width/2-364,
//                                               size.height -
//                                               GAD_SIZE_728x90.height*3.5,
//                                               GAD_SIZE_728x90.width,
//                                               GAD_SIZE_728x90.height)];
//        
//    }
//    else { // It's an iPhone
        
        bannerView = [[GADBannerView alloc]
                      initWithFrame:CGRectMake(size.width/2-160,
                                               size.height -
                                               GAD_SIZE_320x50.height,
                                               GAD_SIZE_320x50.width,
                                               GAD_SIZE_320x50.height)];
        
    //}
    bannerView.adUnitID = @"a14dede8c073878";
    bannerView.rootViewController = controller;
    
    [bannerView loadRequest:[GADRequest request]];
    
    [controller.view addSubview:bannerView];
    [[[CCDirector sharedDirector] openGLView] addSubview:controller.view];
}

#pragma mark -
#pragma mark ENTER & EXIT
- (void) onEnter {
	//[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    if ([[GameManager sharedGameManager] gameInProgress]) {
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_PAUSE]; 
    } else {
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN];
    }
    [[GameManager sharedGameManager] playLoopSounds];
    
    
    if ([GameManager sharedGameManager].mainTutor) {
        [self schedule:@selector(tutorStart) interval:0.8];
    } else {
        [self schedule:@selector(animStart) interval:0.5];
    }
	[super onEnter];
}

- (void) animStart {
    [self unschedule:@selector(animStart)];
    if ([[GameManager sharedGameManager] gameInProgress]) {
        singleMenu.visible = NO;
        careerMenu.visible = NO;
        gameInfo infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        continueMenu.visible = YES;
        if (infoData.career == 1) {
            quitMenu.visible = YES;
            newGameMenu.visible = NO;
            [self animationIn];
        } else {
            newGameMenu.visible = YES;
            gameMenu.visible = YES;
            quitMenu.visible = NO;
            [self animationThreeIn];
        }
    } else {
        continueMenu.visible = NO;
        newGameMenu.visible = NO;
        quitMenu.visible = NO;
        gameMenu.visible = NO;
        [self animationIn];
    } 
}

- (void) tutorStart {
    [self unschedule:@selector(tutorStart)];
    [GameManager sharedGameManager].mainTutor = NO;
    [toggleItem activate];
}

- (void) onExit {
	//[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    #ifdef LITE_VERSION
        [bannerView release];
        [controller.view removeFromSuperview];
        [controller release];
    #endif
	[super onExit];
}


#pragma mark -
#pragma mark PARTICLES, ANIMATIONS
#pragma mark Particles
- (void) runParticle {    
    system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:kMainRainParticle];
    system.autoRemoveOnFinish = YES;
    system.rotation = 0;
    [self addChild:system z:21 tag:1];
}

#pragma mark Animations in
- (void) animationIn {
    //float debugSlow = -0.40;
    //float debugSlow = 5;
    float debugSlow = 0;
    PLAYSOUNDEFFECT(NAV_MAIN);
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibInPosition];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:1];
    id rightGibOpacity = [CCSequence actions:[CCDelayTime actionWithDuration:0.75], [CCFadeIn actionWithDuration:debugSlow + 0.25], nil];
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, rightGibOpacity, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftGibInPosition];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:-2];
    id leftGibOpacity = [CCSequence actions:[CCDelayTime actionWithDuration:0.75], [CCFadeIn actionWithDuration:debugSlow + 0.25], nil];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, leftGibOpacity, nil];
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
}

- (void) animationThreeIn {
    float debugSlow = -0.40;
    PLAYSOUNDEFFECT(NAV_MAIN);
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibInPosition];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:1];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftSingleGibInPosition];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:-2];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    CCMoveTo *rightSingleGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightSingleGibInPosition];
    CCScaleTo *rightSingleGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *rightSingleGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:1];        
    CCSpawn *moveSingleRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightSingleGibMoveIn, rightSingleGibScaleInX, rightSingleGibRotationIn, nil];
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
    [rightSingleGib runAction:moveSingleRightGibSeq];
}

#pragma mark Animations out
- (void) animationOut {
    float debugSlow = -0.60;
    PLAYSOUNDEFFECT(NAV_MAIN);
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftGibOutPosition];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    CCSequence *rightGibCallback = [CCSequence actions:moveRightGibSeq, [CCCallFunc actionWithTarget:self selector:@selector(endAnimation)], nil];
    
    if ([[GameManager sharedGameManager] gameInProgress]) {
        gameInfo infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        if (infoData.career == 1) {
            CCMoveTo *rightSingleGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
            CCScaleTo *rightSingleGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
            CCRotateTo *rightSingleGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:1];        
            CCSpawn *moveSingleRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightSingleGibMoveIn, rightSingleGibScaleInX, rightSingleGibRotationIn, nil];
            [rightSingleGib runAction:moveSingleRightGibSeq];
        }
    }
    [rightGib runAction:rightGibCallback];
    [leftGib runAction:moveLeftGibSeq];
}

- (void) animationTwoOut {
    float debugSlow = -0.80;
    PLAYSOUNDEFFECT(NAV_MAIN);
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftGibOutPosition];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    CCSequence *rightGibCallback = [CCSequence actions:moveRightGibSeq, [CCCallFunc actionWithTarget:self selector:@selector(endAnimationSpec)], nil];
    [rightGib runAction:rightGibCallback];
    [leftGib runAction:moveLeftGibSeq];
}

- (void) animationThreeOut {
    float debugSlow = -0.80;
    PLAYSOUNDEFFECT(NAV_MAIN);
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftGibOutPosition];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    CCMoveTo *rightSingleGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
    CCScaleTo *rightSingleGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *rightSingleGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:1];        
    CCSpawn *moveSingleRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightSingleGibMoveIn, rightSingleGibScaleInX, rightSingleGibRotationIn, nil];
    
    CCSequence *rightGibCallback;
    if ([[GameManager sharedGameManager] gameInProgress] || isThree) {
        rightGibCallback = [CCSequence actions:moveRightGibSeq, nil];
    } else {
        rightGibCallback = [CCSequence actions:moveRightGibSeq, [CCCallFunc actionWithTarget:self selector:@selector(endAnimationSpec)], nil];
    }
    
    [rightGib runAction:rightGibCallback];
    [leftGib runAction:moveLeftGibSeq];
    [rightSingleGib runAction:moveSingleRightGibSeq];
}

- (void) animationThreeOutHowTo {
    float debugSlow = -0.80;
    PLAYSOUNDEFFECT(NAV_MAIN);
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftGibOutPosition];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    CCMoveTo *rightSingleGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
    CCScaleTo *rightSingleGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *rightSingleGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:1];        
    CCSpawn *moveSingleRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightSingleGibMoveIn, rightSingleGibScaleInX, rightSingleGibRotationIn, nil];
    
//    CCSequence *rightGibCallback;
//    if ([[GameManager sharedGameManager] gameInProgress] || isThree) {
//        rightGibCallback = [CCSequence actions:moveRightGibSeq, nil];
//    } else {
//        rightGibCallback = [CCSequence actions:moveRightGibSeq, [CCCallFunc actionWithTarget:self selector:@selector(endAnimationSpec)], nil];
//    }
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
    [rightSingleGib runAction:moveSingleRightGibSeq];
}

#pragma mark Animations out callback
- (void) endAnimation {
    leftGib.visible = NO;
    rightGib.visible = NO;
}

- (void) endAnimationSpec {
    if ([[GameManager sharedGameManager] gameInProgress]) {
        gameInfo infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        if (infoData.career == 1) {
            rightSingleGib.visible = NO;
        }
    }
    gameMenu.visible = NO;
    newGameMenu.visible = NO;
    quitMenu.visible = NO;
    continueMenu.visible = NO;
    careerMenu.visible = YES;
    singleMenu.visible = YES;
    [self animationIn];
}

- (void) infoButtonTapped:(id)sender {  
    //CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == infoOff) {
        [self removeHowTo];
    } else if (toggleItem.selectedItem == infoOn) {
        [self addHowTo];
    }  
}

#pragma mark -
#pragma mark MENU CALLBACK
- (void) buttonTapped:(CCMenuItem *)sender {
    PLAYSOUNDEFFECT(BUTTON_MAIN_CLICK);
//    Lightning *lightning = [Lightning lightningWithStrikePoint:ccp(160,380) strikePoint2:ccp(80, 20)];
    //int xPos = [Utils randomNumberBetween:140 andMax:180];
    //int yPos = [Utils randomNumberBetween:360 andMax:50];
    switch (sender.tag) {
//        case kButtonInfo:
//            [self addHowTo];
////            lightning.position = ccp(160, 220);
////            [self addChild:lightning z:5000];
////            [lightning strikeRandom];
//            break;
        case kButtonSettings:
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kFadeTrans];
            break;
        //packy
        case kButtonSinglePlay:
            [self logicTransition];
            break;
        case kButtonCareerPlay:
            [[GameManager sharedGameManager] runSceneWithID:kCareerScene andTransition:kFadeTrans];
            break;
        case kButtonContinuePlay:
            [self logicTransition];
            break;
        case kButtonNewGame:
            isThree = YES;
            [[[GameManager sharedGameManager] gameData] gameDataCleanup];
            [self logicTransition];
            break;
        case kButtonQuitCareer:
            CCLOG(@"QUIT CAREER");
            [[[GameManager sharedGameManager] gameData] gameDataCleanup];
            [[[GameManager sharedGameManager] gameData] updateCareerData:NO andScore:0];
            [self animationTwoOut];
            break;
        case kButtonGameMenu:
            [[[GameManager sharedGameManager] gameData] gameDataCleanup];
            [self animationThreeOut];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

#pragma mark -
#pragma mark GAMEPLAY CUSTOM TRANSITION
- (void) logicTransition {
    [system stopSystem];
    if ([[GameManager sharedGameManager] gameInProgress] || isThree) {
        gameInfo infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        if (infoData.career != 1) {
            [self animationThreeOut];
        } else {
            [self animationOut];
        }
    }else{
        [self animationOut]; 
    }
    [self buttonsOut];
}

#pragma mark Top menu buttons out
- (void) buttonsOut {
    id buttonsOut = [CCMoveTo actionWithDuration:.4 position:ccp(topMenu.position.x, topMenu.position.y + 60)];
    id buttonsOut1 = [CCMoveTo actionWithDuration:.4 position:ccp(toggleMenu.position.x, toggleMenu.position.y + 60)];
    id seq = [CCSequence actions: buttonsOut, [CCCallFunc actionWithTarget:self selector:@selector(startTransition)], nil];
    id seq1 = [CCSequence actions: buttonsOut1, nil];
    [topMenu runAction:seq];
    [toggleMenu runAction:seq1];
}

#pragma mark Doors out
- (void) doorsOut {
    PLAYSOUNDEFFECT(DOORSLIDE);
    CCMoveTo *doorsOut = [CCMoveTo actionWithDuration:0.4 position:kMainDoorsOutPosition];
    CCSequence *moveDoorsOutSeq = [CCSequence actions:[CCDelayTime actionWithDuration: 0.2f], doorsOut, nil];
    
    [doors runAction:moveDoorsOutSeq];
}

- (void) lampOut {
    [self unscheduleUpdate];
    id lightOut = [CCMoveTo actionWithDuration:0.35 position:ccp(light.position.x, light.position.y + 362)];
    id lightScale = [CCScaleTo actionWithDuration:0.35 scale:2.8];
    id lightFade = [CCSequence actions:[CCDelayTime actionWithDuration:0.12],[CCFadeOut actionWithDuration:0.22], nil];
    id lightSpawn = [CCSpawn actions:lightOut, lightScale, lightFade, nil];
    [light runAction:lightSpawn];
}

#pragma mark Game transition
- (void) startTransition {    
    [self doorsOut];
    [self lampOut];
    [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kLogicTrans];
}


#pragma mark -
#pragma mark ADD HOW TO LAYER
- (void) addHowTo {
    [self doorsOut];
    howToLayer = [HowToLayer node];
    [self addChild:howToLayer z:0];
    [self unscheduleUpdate];
    lightOff.visible = YES;
    light.visible = NO;
    
    if ([[GameManager sharedGameManager] gameInProgress] || isThree) {
        gameInfo infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        if (infoData.career != 1) {
            [self animationThreeOutHowTo];
        } else {
            [self animationOut];
        }
    }else{
        [self animationOut]; 
    }
    
}

- (void) removeHowTo {
    PLAYSOUNDEFFECT(DOORSLIDE);
    id doorsIn = [CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCMoveTo actionWithDuration:0.4 position:kMainDoorsPosition], 
                  [CCCallFunc actionWithTarget:self selector:@selector(removeHowToCallback)], nil];
    [doors runAction:doorsIn];
}

- (void) removeHowToCallback {
    [howToLayer removeFromParentAndCleanup:YES];
    howToLayer = nil;
    [self scheduleUpdate];
    lightOff.visible = NO;
    light.visible = YES;
    
    if ([[GameManager sharedGameManager] gameInProgress]) {
        singleMenu.visible = NO;
        careerMenu.visible = NO;
        gameInfo infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        continueMenu.visible = YES;
        if (infoData.career == 1) {
            quitMenu.visible = YES;
            newGameMenu.visible = NO;
            [self animationIn];
        } else {
            newGameMenu.visible = YES;
            gameMenu.visible = YES;
            quitMenu.visible = NO;
            [self animationThreeIn];
        }
    } else {
        singleMenu.visible = YES;
        careerMenu.visible = YES;
        leftGib.visible = YES;
        rightGib.visible = YES;
        continueMenu.visible = NO;
        newGameMenu.visible = NO;
        quitMenu.visible = NO;
        gameMenu.visible = NO;
        [self animationIn];
    }
}

#pragma mark -
#pragma mark UPDATE & LAMP MOVE CALLBACKS / LAMP BLINKING
- (void) update:(ccTime)deltaTime {
    counter++;
    if (counter == flag) {
        counter = 0;
        if (flag2 == 7) {
            PLAYSOUNDEFFECT(LAMP_BLINK);
            flag2 = 0;
            flag = [Utils randomNumberBetween:140 andMax:240];
            lightOff.visible = NO;
            light.visible = YES;
            background.opacity = 255;
        }else{
            flag = [Utils randomNumberBetween:1 andMax:4];
            lightOff.visible = lightOn;
            light.visible = !lightOn;
            if (lightOn) {
                background.opacity = 255;
                doors.opacity = 255;
            } else {
                background.opacity = 255;
                doors.opacity = 255;
            }
            lightOn = !lightOn;
        }
        flag2++;
    }
}

#pragma mark Lamp move callback
- (void) moveLampCallback {
    id lampSound = [CCSequence actions:[CCDelayTime actionWithDuration: 0.1f], [CCCallFunc actionWithTarget:self selector:@selector(lampCallback)], nil];
    [self runAction:lampSound];

}

- (void) lampCallback {
    PLAYSOUNDEFFECT(LAMP);
}

//- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
//    return YES;
//}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);    
    [super dealloc];
}


@end