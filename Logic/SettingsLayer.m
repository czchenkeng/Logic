//
//  SettingsLayer.m
//  Logic
//
//  Created by Pavel Krusek on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsLayer.h"

enum soundTags
{
	kMusicSliderTag,
	kSoundSliderTag
};

@implementation SettingsLayer

- (void) buttonTapped:(CCMenuItem *)sender { 
    PLAYSOUNDEFFECT(BUTTON_SETTINGS_CLICK);
    CCLOG(@"BUTTON_SETTINGS_CLICK");
    switch (sender.tag) {
        case kButtonScore: 
            [[GameManager sharedGameManager] runSceneWithID:kScoreScene andTransition:kSlideInR];
            break;
        case kButtonBack:
            [[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kFadeTrans];
            break;
        case kButtonCareerPlay:
            [self unschedule:@selector(update:)];
            redLight.visible = NO;
            [[GameManager sharedGameManager] runSceneWithID:kCareerScene andTransition:kSlideInR];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

- (void) diffTapped:(CCMenuItem *)sender {
    if (isSingleGame) {
        isSingleGame = NO;
        lastSender = sender;
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"ERASE GAME" message:@"Do you really want to change settings and delete your current game?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
        [alert addButtonWithTitle:@"Yes"];
        [alert setTag:1];
        [alert show];
    } else {
        PLAYSOUNDEFFECT(JOYSTICK_SETTINGS_CLICK);
        int flag;
        switch (sender.tag) {
            case kEasy: 
                CCLOG(@"TAP ON EASY");
                joyStick.position = ADJUST_CCP(ccp(92.00, 135.00));
                flag = 0;
                break;
            case kMedium:
                CCLOG(@"TAP ON MEDIUM");
                joyStick.position = ADJUST_CCP(ccp(92.00, 92.00));
                flag = 1;
                break;
            case kHard:
                CCLOG(@"TAP ON HARD");
                joyStick.position = ADJUST_CCP(ccp(92.00, 49.00));
                flag = 2;
                break;
            default:
                CCLOG(@"Logic debug: Unknown ID, cannot tap button");
                return;
                break;
        }
        for (CCSprite *diffButton in difficulty) {
            diffButton.visible = NO; 
        }
        CCSprite *currentButton = [difficulty objectAtIndex:flag];
        currentButton.visible = YES;
        
        for (CCSprite *joy in joysticks) {
            joy.visible = NO; 
        }
        CCSprite *currentJoy = [joysticks objectAtIndex:flag];
        currentJoy.visible = YES;
        
        [GameManager sharedGameManager].currentDifficulty = sender.tag;
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 1) {
            [[[GameManager sharedGameManager] gameData] gameDataCleanup];
            [self diffTapped:lastSender];
        } else {
            isSingleGame = YES;
        }
    }
}

- (void) muteTapped:(CCMenuItem *)sender {
    if (musicSlider.value == 0 && soundSlider.value == 0) {
        musicSlider.value = previousMusic;
        soundSlider.value = previousSound;
    } else {
        previousMusic = musicSlider.value;
        previousSound = soundSlider.value;
        musicSlider.value = 0;
        soundSlider.value = 0;
    }
 
}

- (void)onEnter {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        dustSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:kDustParticle];
        dustSystem.autoRemoveOnFinish = YES;
        [self addChild:dustSystem z:1000];
        
        difficulty = [[CCArray alloc] init];
        joysticks = [[CCArray alloc] init];
        
        previousMusic = SETTINGS_MUSIC_VOLUME;
        previousSound = SETTINGS_SOUND_VOLUME;
        
        isSingleGame = NO;
        lastSender = nil;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kSettingsTexture];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background z:1];
        
        CCSprite *buttonBackOff = [CCSprite spriteWithSpriteFrameName:@"back_off.png"];
        CCSprite *buttonBackOn = [CCSprite spriteWithSpriteFrameName:@"back_on.png"];
        CCSprite *buttonScoreOff = [CCSprite spriteWithSpriteFrameName:@"score-off.png"];
        CCSprite *buttonScoreOn = [CCSprite spriteWithSpriteFrameName:@"score-on.png"];
        CCSprite *buttonCareerOff = [CCSprite spriteWithSpriteFrameName:@"career-off.png"];
        CCSprite *buttonCareerOn = [CCSprite spriteWithSpriteFrameName:@"career-on.png"];
        
        CCMenuItem *backItem = [CCMenuItemSprite itemFromNormalSprite:buttonBackOff selectedSprite:buttonBackOn target:self selector:@selector(buttonTapped:)];
        backItem.tag = kButtonBack;
        backItem.anchorPoint = CGPointMake(0.5, 1);
        backItem.position = kLeftNavigationButtonPosition;
        
        CCMenuItem *scoreItem = [CCMenuItemSprite itemFromNormalSprite:buttonScoreOff selectedSprite:buttonScoreOn target:self selector:@selector(buttonTapped:)];
        scoreItem.tag = kButtonScore;
        scoreItem.anchorPoint = ccp(0.00, 0.50);
        //scoreItem.position = ccp(56.50, 377.50);
        scoreItem.position = kSettingsScoreItemPosition;
        
        CCMenuItem *careerItem = [CCMenuItemSprite itemFromNormalSprite:buttonCareerOff selectedSprite:buttonCareerOn target:self selector:@selector(buttonTapped:)];
        careerItem.tag = kButtonCareerPlay;
        careerItem.anchorPoint = ccp(0.00, 0.50);
        //careerItem.position = ccp(56.50, 323.50);
        careerItem.position = kSettingsCareerItemPosition;
        
        CCMenu *topMenu = [CCMenu menuWithItems:scoreItem, backItem, careerItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:2];
        
        redLight = [CCSprite spriteWithSpriteFrameName:@"red_light.png"];
        redLight.position = kSettingsRedLightPosition;
        redLight.anchorPoint = ccp(0.00, 0.50);
        [self addChild:redLight z:100];
        redLight.visible = NO;
        
        CCSprite *thumbMusicButtonOff = [CCSprite spriteWithSpriteFrameName:@"thumb.png"];
        CCSprite *thumbMusicButtonOn = [CCSprite spriteWithSpriteFrameName:@"thumb.png"];
        
        CCSprite *thumbSoundButtonOff = [CCSprite spriteWithSpriteFrameName:@"thumb.png"];
        CCSprite *thumbSoundButtonOn = [CCSprite spriteWithSpriteFrameName:@"thumb.png"];
        
        CCMenuItemSprite *thumbMusic = [CCMenuItemSprite itemFromNormalSprite:thumbMusicButtonOff selectedSprite:thumbMusicButtonOn];
        CCMenuItemSprite *soundMusic = [CCMenuItemSprite itemFromNormalSprite:thumbSoundButtonOff selectedSprite:thumbSoundButtonOn];
        
        musicSlider = [CCSlider sliderWithBackgroundSprite: [CCSprite spriteWithSpriteFrameName:@"slider1Bg.png"] thumbMenuItem: thumbMusic];
        musicSlider.position = kSettingsMusicSliderPosition;
        musicSlider.tag = kMusicSliderTag;
        musicSlider.value = [[GameManager sharedGameManager] musicVolume];
        [self addChild:musicSlider z:3];
		musicSlider.delegate = self;
        
        soundSlider = [CCSlider sliderWithBackgroundSprite: [CCSprite spriteWithSpriteFrameName:@"slider1Bg.png"] thumbMenuItem: soundMusic];
        soundSlider.position = kSettingsSoundSliderPosition;
        soundSlider.tag = kSoundSliderTag;
        soundSlider.value = [[GameManager sharedGameManager] soundVolume];;
        [self addChild:soundSlider z:4];
		soundSlider.delegate = self;
        
        joyStick = [CCSprite spriteWithSpriteFrameName:@"paka_empty.png"];
        CCSprite *joyEasy = [CCSprite spriteWithSpriteFrameName:@"paka_1.png"];
        CCSprite *joyNormal = [CCSprite spriteWithSpriteFrameName:@"paka_2.png"];
        CCSprite *joyHard = [CCSprite spriteWithSpriteFrameName:@"paka_3.png"];
        joyEasy.anchorPoint = ccp(0, 0);
        joyNormal.anchorPoint = ccp(0, 0);
        joyHard.anchorPoint = ccp(0, 0);
        [joyStick addChild:joyEasy z:1];
        [joyStick addChild:joyNormal z:2];
        [joyStick addChild:joyHard z:3];
        [self addChild:joyStick z:5];
        [joysticks addObject:joyEasy];
        [joysticks addObject:joyNormal];
        [joysticks addObject:joyHard];
        
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_easy1.png"];
        sprite.position = ADJUST_CCP(ccp(210.50, 138.50));
        [self addChild:sprite z:6 tag:6];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_hard1.png"];
        sprite.position = ADJUST_CCP(ccp(210.50, 52.00));
        [self addChild:sprite z:7 tag:7];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_normal1.png"];
        sprite.position = ADJUST_CCP(ccp(210.50, 95.00));
        [self addChild:sprite z:8 tag:8];
        
        easy = [[[CCSprite alloc] init] autorelease];
        normal = [[[CCSprite alloc] init] autorelease];
        hard = [[[CCSprite alloc] init] autorelease];
        [self addChild:easy z:9];
        [self addChild:normal z:10];
        [self addChild:hard z:11];
        easy.visible = NO;
        normal.visible = NO;
        hard.visible = NO;
        [difficulty addObject:easy];
        [difficulty addObject:normal];
        [difficulty addObject:hard];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_easy2.png"];
        sprite.position = ADJUST_CCP(ccp(210.50, 138.50));
        [easy addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ADJUST_CCP(ccp(166.00, 141.00));
        [easy addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_normal2.png"];
        sprite.position = ADJUST_CCP(ccp(210.50, 95.00));
        [normal addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ADJUST_CCP(ccp(166.00, 97.50));
        [normal addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_hard2.png"];
        sprite.position = ADJUST_CCP(ccp(210.50, 52.00));
        [hard addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ADJUST_CCP(ccp(165.50, 53.50));
        [hard addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi3.png"];
        sprite.position = ADJUST_CCP_RIGHT(ccp(289, 362.00));
        [self addChild:sprite z:100];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi2.png"];
        sprite.position = ADJUST_CCP_RIGHT(ccp(281.00, 31.50));
        [self addChild:sprite z:101];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi1.png"];
        sprite.position = ADJUST_CCP_RIGHT(ccp(287, 406.00));
        [self addChild:sprite z:102];
        
        CCSprite *muteOff = [CCSprite spriteWithSpriteFrameName:@"mute.png"];
        
        CCMenuItem *mute = [CCMenuItemSprite itemFromNormalSprite:muteOff selectedSprite:nil target:self selector:@selector(muteTapped:)];
        mute.position = ADJUST_CCP(ccp(74.50, 233.00));
        
        CCSprite *buttonEasyOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonEasyOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonNormalOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonNormalOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonHardOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonHardOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        
        easyItem = [CCMenuItemSprite itemFromNormalSprite:buttonEasyOff selectedSprite:buttonEasyOn target:self selector:@selector(diffTapped:)];
        easyItem.tag = kEasy;
        easyItem.position = ADJUST_CCP(ccp(205.00, 139.00));
        
        normalItem = [CCMenuItemSprite itemFromNormalSprite:buttonNormalOff selectedSprite:buttonNormalOn target:self selector:@selector(diffTapped:)];
        normalItem.tag = kMedium;
        normalItem.position = ADJUST_CCP(ccp(205.00, 95.50));
        
        hardItem = [CCMenuItemSprite itemFromNormalSprite:buttonHardOff selectedSprite:buttonHardOn target:self selector:@selector(diffTapped:)];
        hardItem.tag = kHard;
        hardItem.position = ADJUST_CCP(ccp(205.00, 53.00));
        
        PressMenu *difficultyMenu = [PressMenu menuWithItems:easyItem, normalItem, hardItem, mute, nil];
        difficultyMenu.position = CGPointZero;
        [self addChild:difficultyMenu z:20];
        
        switch ([[GameManager sharedGameManager] currentDifficulty]) {
            case kEasy: 
                [easyItem activate];
                break;
            case kMedium:
                [normalItem activate];
                break;
            case kHard:
                [hardItem activate];
                break; 
        }
        
        if ([[GameManager sharedGameManager] gameInProgress]) {
            gameInfo infoData = [[[GameManager sharedGameManager] gameData] getGameData];
            if (infoData.career == 1) {
                [self schedule:@selector(update:) interval:0.3];
            } else {
                isSingleGame = YES;
            }
        }
        
        [self schedule:@selector(smokeSchedule) interval:3];
    }
    return self;
}

- (void) smokeSchedule {
    [self unschedule:@selector(smokeSchedule)];
    [self schedule:@selector(smokeSchedule) interval:12];
    
    smokeSmallSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:kSmokeSmallParticle];
    smokeSmallSystem.autoRemoveOnFinish = YES;
    smokeSmallSystem.position = kSettingsSmokeParticlePosition;
    [self addChild:smokeSmallSystem z:1001];
    
    PLAYSOUNDEFFECT(SETTINGS_STEAM);
    
    [self schedule:@selector(smokeScheduleOut) interval:4];
}

- (void) smokeScheduleOut {
    [self unschedule:@selector(smokeScheduleOut)];
    [smokeSmallSystem stopSystem];
}

- (void) update:(ccTime)dt {
    redLight.visible = blink;
    blink = !blink;
}

- (void) valueChanged:(float)value tag:(int)tag {
    value = MIN(value, 1.0f);
    value = MAX(value, 0.0f);
    switch (tag) {
        case kMusicSliderTag:
            [GameManager sharedGameManager].musicVolume = value;
            break;
        case kSoundSliderTag:
            [GameManager sharedGameManager].soundVolume = value;
            break;
        default:
            break;
    }
}

- (void) valueEnded:(float)value tag:(int)tag {    
    if (tag == kSoundSliderTag) 
        PLAYSOUNDEFFECT(BUTTON_SETTINGS_CLICK);    
    [[GameManager sharedGameManager] updateSettings];
}

- (void) selectJoystick:(CGPoint)touchLocation {
    CCSprite *newSprite = nil;

    if (CGRectContainsPoint(joyStick.boundingBox, touchLocation)) {            
        newSprite = joyStick;
    }
    selJoystick = newSprite;
    CCLOG(@"joystick %@", selJoystick);
}


- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectJoystick:touchLocation];
    
    touchOrigin = [touch locationInView:[touch view]];
	touchOrigin = [[CCDirector sharedDirector] convertToGL:touchOrigin];
    return YES;
}

- (void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
    if (selJoystick) {
        touchStop = [touch locationInView:[touch view]];
        touchStop = [[CCDirector sharedDirector] convertToGL:touchStop];
        float deltaY = touchStop.y - touchOrigin.y;
        
        if (fabs(deltaY) > 20) {
            if(deltaY < 0) {
                if ([[GameManager sharedGameManager] currentDifficulty] < 6) {
                    [GameManager sharedGameManager].currentDifficulty += 1;
                } 
            }//down
            else if (deltaY > 0){
                if ([[GameManager sharedGameManager] currentDifficulty] > 4) {
                    [GameManager sharedGameManager].currentDifficulty -= 1;
                }
            }
        }
        
        switch ([[GameManager sharedGameManager] currentDifficulty]) {
            case kEasy: 
                [easyItem activate];
                break;
            case kMedium:
                [normalItem activate];
                break;
            case kHard:
                [hardItem activate];
                break; 
        }
    }
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [joysticks release];
    joysticks = nil;
    [difficulty release];
    difficulty = nil;
    
    [super dealloc];
}

@end
