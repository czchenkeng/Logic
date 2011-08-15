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
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Main.plist"];
        
        doors = [CCSprite spriteWithSpriteFrameName:@"doors.png"];
        [doors setPosition:ccp(screenSize.width/2 + 5, screenSize.height/2 - 51)];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        
        CCSprite *logoShadow = [CCSprite spriteWithSpriteFrameName:@"logo_shadow.png"];
        [logoShadow setPosition:ccp(screenSize.width/2, screenSize.height/2 + 162)];
        
        CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"logo.png"];
        [logo setPosition:ccp(screenSize.width/2, screenSize.height/2 + 164)];
        
        CCSprite *grass = [CCSprite spriteWithSpriteFrameName:@"grass.png"];
        [grass setPosition:ccp(160, 16)];
        
        rightGib = [CCSprite spriteWithSpriteFrameName:@"rameno_right.png"];
        rightGib.scaleY = 22;
        rightGib.scaleX = 5;
        [rightGib setPosition:ccp(1000.00, 367.00)];
        
        leftGib = [CCSprite spriteWithSpriteFrameName:@"rameno_left.png"];
        leftGib.scaleY = 22;
        leftGib.scaleX = 5;
        [leftGib setPosition:ccp(-700.00, 0.00)];
        
        //SINGLE, CAREER
        CCSprite *buttonSingleOff = [CCSprite spriteWithSpriteFrameName:@"logik_single1.png"];
        CCSprite *buttonSingleOn = [CCSprite spriteWithSpriteFrameName:@"logik_single2.png"];
        
        CCSprite *buttonCareerOff = [CCSprite spriteWithSpriteFrameName:@"logik_career1.png"];
        CCSprite *buttonCareerOn = [CCSprite spriteWithSpriteFrameName:@"logik_career2.png"];
        
        CCMenuItem *singlePlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonSingleOff selectedSprite:buttonSingleOn target:self selector:@selector(buttonTapped:)];
        singlePlayItem.tag = kButtonSinglePlay;
        CCMenu *singleMenu = [CCMenu menuWithItems:singlePlayItem, nil];
        singleMenu.position = ccp(66.00, 31.50);
        
        CCMenuItem *careerPlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonCareerOff selectedSprite:buttonCareerOn target:self selector:@selector(buttonTapped:)];
        careerPlayItem.tag = kButtonCareerPlay;
        CCMenu *careerMenu = [CCMenu menuWithItems:careerPlayItem, nil];
        careerMenu.position = ccp(195.50, 35.50);
        
        //CONTINUE, NEW
        CCSprite *buttonContinueOff = [CCSprite spriteWithSpriteFrameName:@"logik_cont1.png"];
        CCSprite *buttonContinueOn = [CCSprite spriteWithSpriteFrameName:@"logik_cont2.png"];
        
        CCSprite *buttonNewGameOff = [CCSprite spriteWithSpriteFrameName:@"logik_new1.png"];
        CCSprite *buttonNewGameOn = [CCSprite spriteWithSpriteFrameName:@"logik_new2.png"];
        
        CCMenuItem *continuePlayItem = [CCMenuItemSprite itemFromNormalSprite:buttonContinueOff selectedSprite:buttonContinueOn target:self selector:@selector(buttonTapped:)];
        continuePlayItem.tag = kButtonContinuePlay;
        CCMenu *continueMenu = [CCMenu menuWithItems:continuePlayItem, nil];
        continueMenu.position = ccp(66.00, 31.50);;
        
        CCMenuItem *newGameItem = [CCMenuItemSprite itemFromNormalSprite:buttonNewGameOff selectedSprite:buttonNewGameOn target:self selector:@selector(buttonTapped:)];
        newGameItem.tag = kButtonNewGame;
        CCMenu *newGameMenu = [CCMenu menuWithItems:newGameItem, nil];
        newGameMenu.position = ccp(195.50, 35.50);
        
        //INFO, SETTINGS
        CCSprite *buttonInfoOff = [CCSprite spriteWithSpriteFrameName:@"i_off.png"];
        CCSprite *buttonInfoOn = [CCSprite spriteWithSpriteFrameName:@"i_on.png"];
        CCSprite *buttonSettingsOff = [CCSprite spriteWithSpriteFrameName:@"settings_off.png"];
        CCSprite *buttonSettingsOn = [CCSprite spriteWithSpriteFrameName:@"settings_on.png"];
        
        CCMenuItem *infoItem = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:buttonInfoOn target:self selector:@selector(buttonTapped:)];
        infoItem.tag = kButtonInfo;
        infoItem.anchorPoint = CGPointMake(0.5, 1);
        infoItem.position = ccp(RIGHT_BUTTON_TOP_X, RIGHT_BUTTON_TOP_Y);
        CCMenuItem *settingsItem = [CCMenuItemSprite itemFromNormalSprite:buttonSettingsOff selectedSprite:buttonSettingsOn target:self selector:@selector(buttonTapped:)];
        settingsItem.tag = kButtonSettings;
        settingsItem.anchorPoint = CGPointMake(0.5, 1);
        settingsItem.position = ccp(LEFT_BUTTON_TOP_X, LEFT_BUTTON_TOP_Y);
        
        topMenu = [CCMenu menuWithItems:infoItem, settingsItem, nil];
        topMenu.position = CGPointZero;
        
        lightOff = [CCSprite spriteWithSpriteFrameName:@"lightOff.png"];
        lightOff.anchorPoint = ccp(0.5,1);
        [lightOff setPosition:ccp(screenSize.width/2, 487)];
        lightOff.rotation = -4.0;
        lightOff.visible = NO;
        
        //HD sprites
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Hq.plist"];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        light = [CCSprite spriteWithSpriteFrameName:@"light.png"];
        light.anchorPoint = ccp(0.5,1);
        [light setPosition:ccp(screenSize.width/2, 487)];
        light.rotation = -4.0;
        
        //Animations
        CCRotateTo *rotRight = [CCRotateBy actionWithDuration:1.1 angle:-8.0];
        CCRotateTo *rotLeft = [CCRotateBy actionWithDuration:1.1 angle:8.0];
        CCEaseInOut *easeRight = [CCEaseInOut actionWithAction:rotRight rate:3];
        CCEaseInOut *easeLeft = [CCEaseInOut actionWithAction:rotLeft rate:3];
        CCSequence *rotSeq = [CCSequence actions:easeLeft, easeRight, nil];
        
        CCRotateTo *rotRight1 = [CCRotateBy actionWithDuration:1.1 angle:-8.0];
        CCRotateTo *rotLeft1 = [CCRotateBy actionWithDuration:1.1 angle:8.0];        
        CCEaseInOut *easeRight1 = [CCEaseInOut actionWithAction:rotRight1 rate:3];
        CCEaseInOut *easeLeft1 = [CCEaseInOut actionWithAction:rotLeft1 rate:3];        
        CCSequence *rotSeq1 = [CCSequence actions:easeLeft1, easeRight1, nil];
        
        CCMoveTo *moveLeft = [CCMoveTo actionWithDuration:1.1 position:ccp(screenSize.width/2 - 5, screenSize.height/2 + 162)];
        CCMoveTo *moveRight = [CCMoveTo actionWithDuration:1.1 position:ccp(screenSize.width/2 + 5, screenSize.height/2 + 162)];        
        CCEaseInOut *easeMoveLeft = [CCEaseInOut actionWithAction:moveRight rate:3];
        CCEaseInOut *easeMoveRight = [CCEaseInOut actionWithAction:moveLeft rate:3];
        CCSequence *moveSeq = [CCSequence actions:easeMoveLeft, easeMoveRight, nil];
        
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
        [self addChild:lightOff z:12];
        [self addChild:light z:11];
        [self addChild:topMenu z:30];
        
        [light runAction:[CCRepeatForever actionWithAction:rotSeq]];
        [lightOff runAction:[CCRepeatForever actionWithAction:rotSeq1]];
        [logoShadow runAction:[CCRepeatForever actionWithAction:moveSeq]];
        
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN];
        
        if ([[GameManager sharedGameManager] gameInProgress]) {
            singleMenu.visible = NO;
            careerMenu.visible = NO;
        } else {
            continueMenu.visible = NO;
            newGameMenu.visible = NO;
        }
        
        [self runParticle];
        [self scheduleUpdate];
        [self animationIn];
    }
    return self;
}

#pragma mark -
#pragma mark ENTER & EXIT
- (void) onEnter {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void) onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

#pragma mark -
#pragma mark PARTICLES, ANIMATIONS
#pragma mark Particles
- (void) runParticle {    
    CCParticleSystem *system;
    system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"dest_test2.plist"];
    system.rotation = -5;

    [self addChild:system z:21 tag:1];
}

#pragma mark Animations in
- (void) animationIn {
    float debugSlow = -0.40;
    
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(225.50, 235.00)];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:1];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(100.00, 161.00)];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:-2];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    [rightGib runAction:moveRightGibSeq];
    [leftGib runAction:moveLeftGibSeq];
}

#pragma mark Animations out
- (void) animationOut {
    float debugSlow = -0.60;
    
    CCMoveTo *rightGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(1000.00, 367.00)];
    CCScaleTo *rightGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *rightGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];        
    CCSpawn *moveRightGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], rightGibMoveIn, rightGibScaleInX, rightGibRotationIn, nil];
    
    CCMoveTo *leftGibMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(-700.00, 0.00)];
    CCScaleTo *leftGibScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:0];
    CCSpawn *moveLeftGibSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.5f], leftGibMoveIn, leftGibScaleInX, leftGibRotationIn, nil];
    
    CCSequence *rightGibCallback = [CCSequence actions:moveRightGibSeq, [CCCallFunc actionWithTarget:self selector:@selector(endAnimation)], nil];
    [rightGib runAction:rightGibCallback];
    [leftGib runAction:moveLeftGibSeq];
}

- (void) endAnimation {
    leftGib.visible = NO;
    rightGib.visible = NO;
}



- (void) buttonsOut {
    id buttonsOut = [CCMoveTo actionWithDuration:.4 position:ccp(topMenu.position.x, topMenu.position.y + 60)];
    id seq = [CCSequence actions: buttonsOut, [CCCallFunc actionWithTarget:self selector:@selector(startTransition)], nil];
    [topMenu runAction:seq];
}

- (void) doorsOut {
    CCMoveTo *doorsOut = [CCMoveTo actionWithDuration:0.4 position:ccp(doors.position.x - 195, doors.position.y)];
    CCSequence *moveDoorsOutSeq = [CCSequence actions:[CCDelayTime actionWithDuration: 0.2f], doorsOut, nil];
    
    [doors runAction:moveDoorsOutSeq];
}

- (void) startTransition {
    [self doorsOut];
    [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kLogicTrans];
}



- (void) addHowTo {
    howToLayer = [HowToLayer node];
    [self addChild:howToLayer z:0];
}

- (void) howTo {
    [self addHowTo];
    [self animationOut];
    //[self doorsOut];
//    [self unscheduleUpdate];
//    lightOff.visible = YES;
//    light.visible = NO;
}

- (void) logicTransition {
    [self animationOut];
    [self buttonsOut];
}

#pragma mark -
#pragma mark MENU CALLBACK
- (void) buttonTapped:(CCMenuItem *)sender {
    PLAYSOUNDEFFECT(BUTTON_MAIN_CLICK);
    switch (sender.tag) {
        case kButtonInfo:
            [self howTo];
            break;
        case kButtonSettings:            
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kSlideInR];
            break;
        case kButtonSinglePlay:
            [self logicTransition];
            break;
        case kButtonCareerPlay:
            CCLOG(@"TAP ON CAREER");
            break;
        case kButtonContinuePlay:
            [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kLogicTrans];
            break;
        case kButtonNewGame:
            [[[GameManager sharedGameManager] gameData] gameDataCleanup];
            [GameManager sharedGameManager].gameInProgress = NO;
            [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kLogicTrans];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

#pragma mark -
#pragma mark UPDATE CALLBACK / LAMP BLINKING
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
        }else{
            flag = [Utils randomNumberBetween:1 andMax:4];
            lightOff.visible = lightOn;
            light.visible = !lightOn;
            lightOn = !lightOn;
        }
        flag2++;
    }
}

//- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
//    return YES;
//}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);    
    [super dealloc];
}


@end