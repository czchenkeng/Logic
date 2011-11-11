//
//  MainGameLayer.m
//  Logic
//
//  Created by Pavel Krusek on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainGameLayer.h"

@interface MainGameLayer (PrivateMethods)
- (void) runParticle;
- (void) addHowTo;
- (void) removeHowTo;
- (void) logicTransition;//callbacks nahoru?
- (void) buttonsOut;//callbacks nahoru?
//- (void) lampOut;
- (void) addBanner;
@end

@implementation MainGameLayer

- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        flag = 30;
        flag2 = 0;
        lightOn = YES;
        
        gameInProgress = NO;
        isCareer = NO;
        
        isFromLevel = NO;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kMainMainTexture];
        
        doors = [CCSprite spriteWithSpriteFrameName:@"doors.png"];
        doors.position = kMainDoorsPosition;
        
        background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(-1, -1);
        
        logoShadow = [CCSprite spriteWithSpriteFrameName:@"logo_shadow.png"];
        logoShadow.position = kMainLogoShadowPosition;
        
        logo = [CCSprite spriteWithSpriteFrameName:@"logo.png"];
        logo.position = kMainLogoPosition;
        
        CCSprite *grass = [CCSprite spriteWithSpriteFrameName:@"grass.png"];
        grass.position = kMainGrassPosition;
        
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

        
        
        //INFO, SETTINGS
        CCSprite *buttonInfoOff = [CCSprite spriteWithSpriteFrameName:@"i_off.png"];
        CCSprite *buttonInfoOn = [CCSprite spriteWithSpriteFrameName:@"i_on.png"];
        CCSprite *buttonSettingsOff = [CCSprite spriteWithSpriteFrameName:@"settings_off.png"];
        CCSprite *buttonSettingsOn = [CCSprite spriteWithSpriteFrameName:@"settings_on.png"];
        
        CCMenuItem *settingsItem = [CCMenuItemSprite itemFromNormalSprite:buttonSettingsOff selectedSprite:buttonSettingsOn target:self selector:@selector(buttonTapped:)];
        settingsItem.tag = kButtonSettings;
        settingsItem.anchorPoint = CGPointMake(0.5, 1);
        settingsItem.position = kLeftNavigationButtonPosition;
        
        topMenu = [CCMenu menuWithItems:settingsItem, nil];
        topMenu.position = CGPointZero;
        
        infoOff = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:nil target:nil selector:nil];
        infoOn = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOn selectedSprite:nil target:nil selector:nil];
        
        toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(infoButtonTapped:) items:infoOff, infoOn, nil];
        toggleItem.anchorPoint = CGPointMake(0.5, 1);
        toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = kRightNavigationButtonPosition;        
        
        [self addChild:doors z:1];
        [self addChild:background z:2];
        [self addChild:logoShadow z:3];
        [self addChild:logo z:4];
        [self addChild:grass z:5];
        [self addChild:lightOff z:15];
        [self addChild:light z:14];
        [self addChild:topMenu z:30];
        [self addChild:toggleMenu z:30];
        
        //Animations
        CCRotateTo *rotRight = [CCRotateBy actionWithDuration:1.1 angle:-8.0];
        CCRotateTo *rotLeft = [CCRotateBy actionWithDuration:1.1 angle:8.0];
        CCEaseInOut *easeRight = [CCEaseInOut actionWithAction:rotRight rate:3];
        CCEaseInOut *easeLeft = [CCEaseInOut actionWithAction:rotLeft rate:3];
        CCSequence *rotSeq = [CCSequence actions:easeLeft, easeRight, [CCCallFunc actionWithTarget:self selector:@selector(moveLampCallback)], nil];
        
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
        
        //packy
        rightGib = [CCSprite spriteWithSpriteFrameName:@"rameno_right.png"];
        rightGib.scaleY = 2.4;
        rightGib.scaleX = 2.4;
        rightGib.rotation = 1;
        rightGib.position = kMainRightGibOutPosition;
        
        leftGib = [CCSprite spriteWithSpriteFrameName:@"rameno_left.png"];
        leftGib.scaleY = 2.4;
        leftGib.scaleX = 2.4;
        leftGib.rotation = -2;
        leftGib.position = kMainLeftGibOutPosition;
        
        rightGib.opacity = 0;
        leftGib.opacity = 0;
        
        rightSingleGib = [CCSprite spriteWithSpriteFrameName:@"rameno_right.png"];
        rightSingleGib.scaleY = 1;
        rightSingleGib.scaleX = 1;
        rightSingleGib.rotation = 1;
        rightSingleGib.position = kMainRightSingleGibOutPosition;
        rightSingleGib.visible = NO;
        
        //packy buttons
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
        CCSprite *buttonContinueOff = [CCSprite spriteWithSpriteFrameName:@"logik_continue1.png"];
        CCSprite *buttonContinueOn = [CCSprite spriteWithSpriteFrameName:@"logik_continue2.png"];
        CCSprite *buttonNewGameOff = [CCSprite spriteWithSpriteFrameName:@"logik_new1.png"];
        CCSprite *buttonNewGameOn = [CCSprite spriteWithSpriteFrameName:@"logik_new2.png"];
        CCSprite *buttonGameMenuOff = [CCSprite spriteWithSpriteFrameName:@"logik_gmenu1.png"];
        CCSprite *buttonGameMenuOn = [CCSprite spriteWithSpriteFrameName:@"logik_gmenu2.png"];
        CCSprite *buttonQuitOff = [CCSprite spriteWithSpriteFrameName:@"logik_quit1.png"];
        CCSprite *buttonQuitOn = [CCSprite spriteWithSpriteFrameName:@"logik_quit2.png"];
        
        CCMenuItem *singlePlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonSingleOff selectedSprite:buttonSingleOn target:self selector:@selector(buttonTapped:)];
        singlePlayItem.tag = kButtonSinglePlay;
        singleMenu = [CCMenu menuWithItems:singlePlayItem, nil];
        singleMenu.position = kMainRightGibButtonPosition;
        [singleMenu setOpacity:0];        
        CCMenuItem *careerPlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonCareerOff selectedSprite:buttonCareerOn target:self selector:@selector(buttonTapped:)];
        careerPlayItem.tag = kButtonCareerPlay;
        careerMenu = [CCMenu menuWithItems:careerPlayItem, nil];
        careerMenu.position = kMainLeftGibButtonPosition;
        [careerMenu setOpacity:0];        
        CCMenuItem *continuePlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonContinueOff selectedSprite:buttonContinueOn target:self selector:@selector(buttonTapped:)];
        continuePlayItem.tag = kButtonContinuePlay;
        continueMenu = [CCMenu menuWithItems:continuePlayItem, nil];
        continueMenu.position = kMainRightGibButtonPosition;
        [continueMenu setOpacity:0];
        CCMenuItem *newGameItem = [CCMenuItemSprite itemFromNormalSprite:buttonNewGameOff selectedSprite:buttonNewGameOn target:self selector:@selector(buttonTapped:)];
        newGameItem.tag = kButtonNewGame;
        newGameMenu = [CCMenu menuWithItems:newGameItem, nil];
        newGameMenu.position = kMainLeftGibButtonPosition;
        [newGameMenu setOpacity:0];
        CCMenuItem *gameMenuItem = [CCMenuItemSprite itemFromNormalSprite:buttonGameMenuOff selectedSprite:buttonGameMenuOn target:self selector:@selector(buttonTapped:)];
        gameMenuItem.tag = kButtonGameMenu;
        gameMenu = [CCMenu menuWithItems:gameMenuItem, nil];
        gameMenu.position = kMainRightGibButtonPosition;
        [gameMenu setOpacity:0];
        CCMenuItem *quitItem = [CCMenuItemSprite itemFromNormalSprite:buttonQuitOff selectedSprite:buttonQuitOn target:self selector:@selector(buttonTapped:)];
        quitItem.tag = kButtonQuitCareer;
        quitMenu = [CCMenu menuWithItems:quitItem, nil];
        quitMenu.position = kMainLeftGibButtonPosition;
        [quitMenu setOpacity:0];
        
        
        [self addChild:rightGib z:10];
            [rightGib addChild:singleMenu z:1];
            [rightGib addChild:continueMenu z:2];
        [self addChild:leftGib z:11];
            [leftGib addChild:careerMenu z:1];
            [leftGib addChild:newGameMenu z:2];
            [leftGib addChild:quitMenu z:3];
        [self addChild:rightSingleGib z:12];
            [rightSingleGib addChild:gameMenu z:1];
        
        if ([GameManager sharedGameManager].oldScene == kGameScene) {
            doors.position = ccp(doors.position.x - 195, doors.position.y);
            id doorsIn = [CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCMoveTo actionWithDuration:0.3 position:ccp(doors.position.x + 195, doors.position.y)], nil];
            [doors runAction:doorsIn];
        }
#ifdef LITE_VERSION
        [self addBanner];
#endif 
        
        [self runParticle];
        [self scheduleUpdate];

    }
    return self;
}

- (void) addBanner {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    controller = [[RootViewController alloc] init];
    controller.view.frame = CGRectMake(0,0,size.width,size.height);
    
    bannerView = [[GADBannerView alloc]
                  initWithFrame:CGRectMake(size.width/2-160, size.height - GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    
    bannerView.adUnitID = @"a14dede8c073878";
    bannerView.rootViewController = controller;
    
    [bannerView loadRequest:[GADRequest request]];
    
    [controller.view addSubview:bannerView];
    [[[CCDirector sharedDirector] openGLView] addSubview:controller.view];
}

#pragma mark -
#pragma mark ENTER
- (void) onEnter {
    if ([[GameManager sharedGameManager] gameInProgress]) {
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_PAUSE];
        gameInProgress = YES;
        gameInfo infoData = [[[GameManager sharedGameManager] gameData] getGameData];
        if (infoData.career == 1)
            isCareer = YES;
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

#pragma mark Animations in
- (void) animationIn {
    float debugSlow = -0.80;
    PLAYSOUNDEFFECT(NAV_MAIN);
    
    CCMoveTo *rightGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibInPosition];
    CCScaleTo *rightGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1 scaleY:1];
    CCFadeIn *rightFadeOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    id singleOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    id continueOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    id quitOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveRightGibSeq = [CCSpawn actions: rightGibMoveOut, rightGibScaleOutX, rightFadeOut, nil];
    
    CCMoveTo *leftGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftGibInPosition];
    CCScaleTo *leftGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1 scaleY:1];
    CCFadeIn *leftFadeOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    id careerOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions: leftGibMoveOut, leftGibScaleOutX, leftFadeOut, nil];
    
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
    [singleMenu runAction:singleOut];
    [careerMenu runAction:careerOut];
    [continueMenu runAction:continueOut];
    [quitMenu runAction:quitOut];
}

#pragma mark Animations out
- (void) animationOut {
    PLAYSOUNDEFFECT(NAV_MAIN);
    float debugSlow = -0.80;
    CCMoveTo *rightGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
    CCScaleTo *rightGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:2.4 scaleY:2.4];
    CCFadeOut *rightFadeOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    id singleOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    id continueOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    id quitOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveRightGibSeq = [CCSpawn actions: rightGibMoveOut, rightGibScaleOutX, rightFadeOut, nil];
    
    CCMoveTo *leftGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftGibOutPosition];
    CCScaleTo *leftGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:2.4 scaleY:2.4];
    CCFadeOut *leftFadeOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    id careerOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions: leftGibMoveOut, leftGibScaleOutX, leftFadeOut, nil];
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
    [singleMenu runAction:singleOut];
    [careerMenu runAction:careerOut];
    [continueMenu runAction:continueOut];
    [quitMenu runAction:quitOut];
}

- (void) animationThreeIn {
    float debugSlow = -0.80;
    PLAYSOUNDEFFECT(NAV_MAIN);
    
    CCMoveTo *rightGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibInPosition];
    CCScaleTo *rightGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1 scaleY:1];
    CCFadeIn *rightFadeOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    id singleOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveRightGibSeq = [CCSpawn actions: rightGibMoveOut, rightGibScaleOutX, rightFadeOut, nil];
    
    CCMoveTo *leftGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftSingleGibInPosition];
    CCScaleTo *leftGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1 scaleY:1];
    CCFadeIn *leftFadeOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    id careerOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions: leftGibMoveOut, leftGibScaleOutX, leftFadeOut, nil];
    
    CCMoveTo *rightSingleGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightSingleGibInPosition];
    CCScaleTo *rightSingleGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1 scaleY:1];
    CCFadeIn *rightSingleFadeOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    id careerSingleOut = [CCFadeIn actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveSingleRightGibSeq = [CCSpawn actions: rightSingleGibMoveOut, rightSingleGibScaleOutX, rightSingleFadeOut, nil];
    
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
    [rightSingleGib runAction:moveSingleRightGibSeq];

    [continueMenu runAction:singleOut];
    [newGameMenu runAction:careerOut];
    [gameMenu runAction:careerSingleOut];
}

#pragma mark Animations out
- (void) animationThreeOut {
    PLAYSOUNDEFFECT(NAV_MAIN);
    float debugSlow = -0.80;
    CCMoveTo *rightGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightGibOutPosition];
    CCScaleTo *rightGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:2.4 scaleY:2.4];
    CCFadeOut *rightFadeOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    id singleOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveRightGibSeq = [CCSpawn actions: rightGibMoveOut, rightGibScaleOutX, rightFadeOut, nil];
    
    CCMoveTo *leftGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainLeftGibOutPosition];
    CCScaleTo *leftGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:2.4 scaleY:2.4];
    CCFadeOut *leftFadeOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    id careerOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions: leftGibMoveOut, leftGibScaleOutX, leftFadeOut, nil];
    
    CCMoveTo *rightSingleGibMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:kMainRightSingleGibOutPosition];
    CCScaleTo *rightSingleGibScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:2.4 scaleY:2.4];
    CCFadeOut *rightSingleFadeOut = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    id single2Out = [CCFadeOut actionWithDuration:debugSlow + 1.0];
    CCSpawn *moveRightSingleGibSeq = [CCSpawn actions: rightSingleGibMoveOut, rightSingleGibScaleOutX, rightSingleFadeOut, nil];
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
    [rightSingleGib runAction:moveRightSingleGibSeq];
    
    [continueMenu runAction:singleOut];
    [newGameMenu runAction:careerOut];
    [gameMenu runAction:single2Out];
}


- (void) animStart {
    [self unschedule:@selector(animStart)];
    if (gameInProgress) {
        singleMenu.visible = NO;
        careerMenu.visible = NO;
        continueMenu.visible = YES;
        if (isCareer) {
            quitMenu.visible = YES;
            newGameMenu.visible = NO;
            gameMenu.visible = NO;
            [self animationIn];
        } else {
            rightSingleGib.visible = YES;
            newGameMenu.visible = YES;
            gameMenu.visible = YES;
            quitMenu.visible = NO;
            [self animationThreeIn];
        }
    } else {
        continueMenu.visible = NO;
        newGameMenu.visible = NO;
        gameMenu.visible = NO;
        quitMenu.visible = NO;
        [self animationIn];
    } 
}


#pragma mark -
#pragma mark CALLBACKS
#pragma mark Doors out
- (void) doorsOut {
    PLAYSOUNDEFFECT(DOORSLIDE);
    CCMoveTo *doorsOut = [CCMoveTo actionWithDuration:0.3 position:kMainDoorsOutPosition];
    CCSequence *moveDoorsOutSeq = [CCSequence actions:[CCDelayTime actionWithDuration: 0.2f], doorsOut, nil];
    
    [doors runAction:moveDoorsOutSeq];
}

- (void) removeHowToCallback {
    [howToLayer removeFromParentAndCleanup:YES];
    howToLayer = nil;
    [self scheduleUpdate];
    lightOff.visible = NO;
    light.visible = YES;
    [self animStart];
}

#pragma mark -
#pragma mark INFO BUTTON CALLBACK
- (void) infoButtonTapped:(id)sender {  
    if (toggleItem.selectedItem == infoOff) {
        [self removeHowTo];
    } else if (toggleItem.selectedItem == infoOn) {
        [self addHowTo];
    }  
}

#pragma mark -
#pragma mark MENU BUTTON CALLBACK
- (void) buttonTapped:(CCMenuItem *)sender {
#ifdef LITE_VERSION
    if (sender.tag != kButtonGameMenu) {
        [bannerView release];
        [controller.view removeFromSuperview];
        [controller release];
    }
#endif
    PLAYSOUNDEFFECT(BUTTON_MAIN_CLICK);
    switch (sender.tag) {
        case kButtonSettings:
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kFadeTrans];
            break;
        case kButtonSinglePlay:
            [self logicTransition];
            break;
        case kButtonCareerPlay:
#ifdef LITE_VERSION
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/power-of-logic/id452804654"]];
#else
            [[GameManager sharedGameManager] runSceneWithID:kCareerScene andTransition:kFadeTrans];
#endif
            break;
        case kButtonContinuePlay:
            [self logicTransition];
            break;
        case kButtonNewGame:
            [[[GameManager sharedGameManager] gameData] gameDataCleanup];
            [self logicTransition];
            break;
        case kButtonQuitCareer:
            [[[GameManager sharedGameManager] gameData] gameDataCleanup];
            [[[GameManager sharedGameManager] gameData] updateCareerData:NO andScore:0];
            [self animationOut];
            [self schedule:@selector(twoRibsCallback) interval:0.3];
            break;
        case kButtonGameMenu:
            [[[GameManager sharedGameManager] gameData] gameDataCleanup];
            [self animationThreeOut];
            [self schedule:@selector(twoRibsCallback) interval:0.3];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

- (void) twoRibsCallback {
    [self unschedule:@selector(twoRibsCallback)];
    gameInProgress = NO;
    isCareer = NO;
    singleMenu.visible = YES;
    careerMenu.visible = YES;
    continueMenu.visible = NO;
    newGameMenu.visible = NO;
    gameMenu.visible = NO;
    quitMenu.visible = NO;
    [self animationIn];
}

#pragma mark -
#pragma mark GAMEPLAY CUSTOM TRANSITION
- (void) logicTransition {
    [system stopSystem];
    if (gameInProgress) {
        if (isCareer) 
            [self animationOut];
        else
            [self animationThreeOut];
    }else{
       [self animationOut];  
    }
    [self buttonsOut];
}

#pragma mark Top menu buttons out
- (void) buttonsOut {
    id buttonsOut = [CCMoveTo actionWithDuration:.4 position:ccp(topMenu.position.x, topMenu.position.y + ADJUST_2(60))];
    id buttonsOut1 = [CCMoveTo actionWithDuration:.4 position:ccp(toggleMenu.position.x, toggleMenu.position.y + ADJUST_2(60))];
    id seq = [CCSequence actions: buttonsOut, [CCCallFunc actionWithTarget:self selector:@selector(startTransition)], nil];
    id seq1 = [CCSequence actions: buttonsOut1, nil];
    [topMenu runAction:seq];
    [toggleMenu runAction:seq1];
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
    id bgFadeOut = [CCFadeOut actionWithDuration:0.35];
    id doorsFadeOut = [CCFadeOut actionWithDuration:0.35];
    id logoShadowFadeOut = [CCFadeOut actionWithDuration:0.35];
    id logoFadeOut = [CCFadeOut actionWithDuration:0.35];
    [background runAction:bgFadeOut];
    [doors runAction:doorsFadeOut];
    [logoShadow runAction:logoShadowFadeOut];
    [logo runAction:logoFadeOut];
    [CDXPropertyModifierAction fadeBackgroundMusic:1.0f finalVolume:0.0f curveType:kIT_Exponential shouldStop:NO];
    [self doorsOut];
    [self lampOut];
    [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kLogicTrans];
}

- (void) tutorStart {
    [self unschedule:@selector(tutorStart)];
    [GameManager sharedGameManager].mainTutor = NO;
    isFromLevel = YES;
    [toggleItem activate];
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
    
    if (!isFromLevel) {
        if (gameInProgress) {
            if (isCareer) 
                [self animationOut];
            else
                [self animationThreeOut];
        }else{
            [self animationOut];  
        }
    }
    isFromLevel = NO;
}

#pragma mark REMOVE HOW TO LAYER
- (void) removeHowTo {
    PLAYSOUNDEFFECT(DOORSLIDE);
    id doorsIn = [CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCMoveTo actionWithDuration:0.4 position:kMainDoorsPosition], 
                  [CCCallFunc actionWithTarget:self selector:@selector(removeHowToCallback)], nil];
    [doors runAction:doorsIn];
}

#pragma mark -
#pragma mark PARTICLES, ANIMATIONS
#pragma mark Particles
- (void) runParticle {    
    system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:kMainRainParticle];
    system.autoRemoveOnFinish = YES;
    system.rotation = -3;
    [self addChild:system z:21 tag:1];
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

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [super dealloc];
}

@end
