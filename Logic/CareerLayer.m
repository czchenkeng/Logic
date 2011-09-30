//
//  CareerLayer.m
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CareerLayer.h"
#import "CJSONDeserializer.h"

@interface CareerLayer (PrivateMethods)
- (void) setupTutor;
- (void) disableTutor;
- (void) buildCities;
- (void) buildWires;
- (void) buildCareer;
- (void) endCareer;
- (void) stopAnimationsAndSound;
- (void) showCityInProgress;
- (void) showLastCity;
- (void) activateWires:(BOOL)animation;
- (void) setProgress;
- (void) eraseCareer;
- (void) constructPercentLabel;
- (void) constructScoreLabel;
- (void) drawPercentToLabel;
- (void) blinkCity:(City *)city;
- (NSString *) jsonFromFile:(NSString *)file;
- (void) handleError:(NSError *)error;
@end

static const float MIN_SCALE = 0.8;
static const float MAX_SCALE = 1.667;
static const float POS_X = 175;
static const float POS_Y = 0;

@implementation CareerLayer

#pragma mark -
#pragma mark INIT
#pragma mark Designated initializer
- (id) init {
    self = [super init];
    if (self != nil) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Career.plist"];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CareerHq.plist"];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        citiesArray = [[CCArray alloc] init];
        wiresArray = [[CCArray alloc] init];
        percentLabelArray = [[CCArray alloc] init];
        scoreLabelArray = [[CCArray alloc] init];
        finalBlinkArray = [[CCArray alloc] init];
        
        endCareer = NO;
        
        currentCity = nil;
        
        blink = NO;
        
        score = 0;
        
        prog = 0;
        percent = 0;
        panelActive = NO;
        
        CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
        isRetina = screenSize.height == 960.0f ? YES : NO;
        
        zoomBase = [CCLayerColor layerWithColor:ccc4(0,0,0,0)];
		zoomBase.position = ccp(0, 0);
		[self addChild:zoomBase z:1];
        
        background = [CCSprite spriteWithSpriteFrameName:@"logik_levels.png"];
        background.anchorPoint = ccp(0, 0);
        background.position = ccp(-POS_X, POS_Y);
        background.scale = MIN_SCALE;
        [zoomBase addChild:background z:1];
        
        //Main bulbon, shadow
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_levels_bulbon_start.png"];
        sprite.anchorPoint = ccp(0, 0);
        sprite.position = ccp(359.5, 222);
        [background addChild:sprite z:100];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"shadow.png"];
        sprite.anchorPoint = ccp(0.00, 0.00);
        [self addChild:sprite z:2];
        
        //Back menu
        CCSprite *buttonBackOff = [CCSprite spriteWithSpriteFrameName:@"back_off.png"];
        CCSprite *buttonBackOn = [CCSprite spriteWithSpriteFrameName:@"back_on.png"];
        CCSprite *buttonInfoOff = [CCSprite spriteWithSpriteFrameName:@"i_off.png"];
        CCSprite *buttonInfoOn = [CCSprite spriteWithSpriteFrameName:@"i_on.png"];
        
        CCMenuItem *backItem = [CCMenuItemSprite itemFromNormalSprite:buttonBackOff selectedSprite:buttonBackOn target:self selector:@selector(buttonTapped:)];
        backItem.tag = kButtonBack;
        backItem.anchorPoint = CGPointMake(0.5, 1);
        backItem.position = ccp(LEFT_BUTTON_TOP_X, LEFT_BUTTON_TOP_Y);
        
        CCMenu *topMenu = [CCMenu menuWithItems:backItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:3];
        
        //Info toggle button
        infoOff = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:nil target:nil selector:nil];
        infoOn = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOn selectedSprite:nil target:nil selector:nil];
        
        toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(infoButtonTapped:) items:infoOff, infoOn, nil];
        CCMenu *toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = ccp(RIGHT_BUTTON_TOP_X, RIGHT_BUTTON_TOP_Y);
        toggleItem.anchorPoint = CGPointMake(0.5, 1);
        [self addChild:toggleMenu z:4];
        
        //Info panel
        infoPanel = [CCSprite spriteWithSpriteFrameName:@"infoPanel.png"];        
        infoPanel.scaleY = 22;
        infoPanel.scaleX = 5;
        [infoPanel setPosition:ccp(-850.00, 0.00)];
        [self addChild:infoPanel z:4];
        
        progressBar = [CCSprite spriteWithSpriteFrameName:@"progress.png"];
        progressBar.position = ccp(161 - progressBar.contentSize.width/2, 127);
        progressBar.anchorPoint = ccp(0, 0.5);
        total = progressBar.contentSize.width;
        [infoPanel addChild:progressBar z:1];
        
        CCSprite *buttonErase = [CCSprite spriteWithFile:@"2x2.png" rect:CGRectMake(0, 0, 111, 30)];
        CCSprite *diod = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        diod.anchorPoint = ccp(0, 0);
        diod.position = ccp(-4, 4);
        CCMenuItem *eraseCareer = [CCMenuItemSprite itemFromNormalSprite:buttonErase selectedSprite:diod target:self selector:@selector(buttonTapped:)];
        eraseCareer.tag = kButtonEraseCareer;
        eraseCareer.anchorPoint = CGPointMake(0, 0);
        eraseCareer.position = ccp(140, 23);
        
        CCMenu *eraseMenu = [CCMenu menuWithItems:eraseCareer, nil];
        eraseMenu.position = CGPointZero;
        [infoPanel addChild:eraseMenu z:2];
        
        dustSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"dust1.plist"];
        dustSystem.autoRemoveOnFinish = YES;
        [self addChild:dustSystem z:1000];
        
        [self constructPercentLabel];
        [self constructScoreLabel];
        [self buildCities];
        [self buildWires];
        [self buildCareer];
        [self showCityInProgress];
        [self showLastCity];
    }
    return self;
}

#pragma mark -
#pragma mark ENTER & EXIT
- (void) onEnter {
    panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)] autorelease];
    //pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)] autorelease];
    
    singleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)] autorelease];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTapGestureRecognizer];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panGestureRecognizer];
    //[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pinchGestureRecognizer];
    
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    
    pinchGestureRecognizer.delegate = self;
    
    settings startSettings = [[[GameManager sharedGameManager] gameData] getSettings];
    
    //if ([GameManager sharedGameManager].isTutor && startSettings.careerTutor == 1) {
    if (startSettings.careerTutor == 1) {
        [self setupTutor];
    }
    
    [super onEnter];
}

- (void) onExit {
    [[GameManager sharedGameManager] duckling:[GameManager sharedGameManager].musicVolume];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:singleTapGestureRecognizer];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:panGestureRecognizer];
    //[[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pinchGestureRecognizer];
    [super onExit];
}

#pragma mark -
#pragma mark GESTURES DELEGATE METHODS
#pragma mark Simultaneous
- (BOOL) gestureRecognizer:pinchGestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:panGestureRecognizer {
    return NO;
}

#pragma mark -
#pragma mark TUTORIAL
- (void) fingerOutCallback {
    City *city = [citiesArray objectAtIndex:2];
    if (!city.isActive) {
        city.visible = NO;
    }
}

- (void) skipTutorTapped:(CCMenuItem *)sender {
    PLAYSOUNDEFFECT(BUTTON_CAREER_CLICK);
    STOPSOUNDEFFECT(tutorSound);
    [self fingerOutCallback];
    [[GameManager sharedGameManager] duckling:[GameManager sharedGameManager].musicVolume];
    [self disableTutor];
    switch (sender.tag) {
        case kButtonSkipTutor:
            CCLOG(@"skip - play game");
            break;
        case kButtonNeverShow:
            CCLOG(@"never show");
            //[GameManager sharedGameManager].isTutor = NO;
            [[[GameManager sharedGameManager] gameData] writeCareerTutor];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

- (void) disableTutor {
    [[GameManager sharedGameManager] duckling:[GameManager sharedGameManager].musicVolume];
    [self unschedule:@selector(disableTutor)];
    id tutorOut = [CCMoveTo actionWithDuration:1 position:ccp(tutorLayer.position.x, tutorLayer.position.y + 480)];    
    [tutorLayer runAction:tutorOut];
    tutorFinger.visible = NO;
}

- (void) setupTutor {
    tutorLayer = [CCLayer node];
    [self addChild:tutorLayer z:1000];
    tutorLayer.position = ccp(tutorLayer.position.x, tutorLayer.position.y + 480);
    tutorBlackout = [Blackout node];
    [tutorBlackout setOpacity:128];
    tutorBlackout.position = ccp(tutorBlackout.position.x, tutorBlackout.position.y + 270);
    [tutorLayer addChild:tutorBlackout z:1];
    
    CCSprite *buttonSkipOff = [CCSprite spriteWithSpriteFrameName:@"end_off.png"];
    CCSprite *buttonSkipOn = [CCSprite spriteWithSpriteFrameName:@"end_on.png"];    
    CCMenuItem *skipItem = [CCMenuItemSprite itemFromNormalSprite:buttonSkipOff selectedSprite:buttonSkipOn target:self selector:@selector(skipTutorTapped:)];
    
    CCSprite *buttonTutorOff = [CCSprite spriteWithSpriteFrameName:@"logik_x_01.png"];
    CCSprite *buttonTutorOn = [CCSprite spriteWithSpriteFrameName:@"logik_x_02.png"];    
    CCMenuItem *tutorItem = [CCMenuItemSprite itemFromNormalSprite:buttonTutorOff selectedSprite:buttonTutorOn target:self selector:@selector(skipTutorTapped:)];
    
    skipItem.tag = kButtonSkipTutor;
    skipItem.position = ccp(287.00, 481.00 - tutorItem.contentSize.height/2);        
    tutorItem.tag = kButtonNeverShow;
    tutorItem.position = ccp(33, 481.00 - skipItem.contentSize.height/2);
    
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
    [tutorTxt setString:@"Tap the bulb to light\nup next city"];
    
    tutorFinger = [CCSprite spriteWithSpriteFrameName:@"prst.png"];
    [tutorLayer addChild:tutorFinger z:6];
    tutorFinger.position = ccp(310, 150);
    tutorFinger.rotation = -20;
    tutorFinger.visible = YES;
    tutorFinger.opacity = 0;
    
    id moveFinger = [CCSequence actions:[CCDelayTime actionWithDuration:1], [CCFadeIn actionWithDuration:0.1], [CCMoveTo actionWithDuration:1 position:ccp(290, 190)],[CCCallFunc actionWithTarget:self selector:@selector(fingerCallback)] ,nil];
    [tutorFinger runAction:moveFinger];
    [self schedule:@selector(disableTutor) interval:6];
    //tutorSound = PLAYSOUNDEFFECT(TUTOR7);
    
    id tutorIn = [CCMoveTo actionWithDuration:1 position:ccp(tutorLayer.position.x, tutorLayer.position.y - 480)];
    id tutorInSeq = [CCSequence actions:tutorIn,[CCCallFunc actionWithTarget:self selector:@selector(tutorInCallback)], nil];
    
    [tutorLayer runAction:tutorInSeq];
}

- (void) tutorInCallback {
    [[GameManager sharedGameManager] duckling:0.2];
    tutorSound =  PLAYSOUNDEFFECT(TUTOR7);
}

- (void) fingerCallback {
    City *city = [citiesArray objectAtIndex:2];
    city.visible = YES;
    PLAYSOUNDEFFECT(BUTTON_CAREER_CLICK);
    id outFinger = [CCSequence actions:[CCDelayTime actionWithDuration:1],[CCFadeOut actionWithDuration:0.5],[CCDelayTime actionWithDuration:2],[CCCallFunc actionWithTarget:self selector:@selector(fingerOutCallback)] ,nil];
    [tutorFinger runAction:outFinger];    
}

#pragma mark -
#pragma mark INFO PANEL
#pragma mark Panel in
- (void) infoPanelIn {
    PLAYSOUNDEFFECT(NAV_CAREER);
    //singleTapGestureRecognizer.enabled = NO;
    
    float debugSlow = -0.40;
    
    CCMoveTo *infoPanelMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(125.00, 98.00)];
    CCScaleTo *infoPanelScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    CCSpawn *infoPanelSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.0f], infoPanelMoveIn, infoPanelScaleInX, nil];
    CCSequence *inSeq = [CCSequence actions:infoPanelSeq, [CCCallFunc actionWithTarget:self selector:@selector(endAnimation)], nil];
    
    [infoPanel runAction:inSeq];
}

#pragma mark Panel in callback
- (void) endAnimation {
    PercentNumber *tempPercentNumber;
    PercentNumber *tempScoreNumber;
    for (int i=0; i < 3; i++) {
        tempPercentNumber = [percentLabelArray objectAtIndex:i];
        tempPercentNumber.visible = panelActive;
    }
    for (int i=0; i < 8; i++) {
        tempScoreNumber = [scoreLabelArray objectAtIndex:i];
        tempScoreNumber.visible = panelActive;
    }
    if (panelActive) {
        [self setProgress];
    }     
}

#pragma mark Panel out
- (void) infoPanelOut {
    PLAYSOUNDEFFECT(NAV_CAREER);
    singleTapGestureRecognizer.enabled = YES;
    
    float debugSlow = -0.60;
    
    CCMoveTo *infoPanelMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(-850.00, 0.00)];
    CCScaleTo *infoPanelScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCSpawn *infoPanelSeqOut = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.0f], infoPanelScaleOutX, infoPanelMoveOut, nil];
    
    [infoPanel runAction:infoPanelSeqOut];
}

#pragma mark -
#pragma mark BUTTONS CALLBACK METHODS
#pragma mark Button back & erase career
- (void) buttonTapped:(CCMenuItem *)sender {
    PLAYSOUNDEFFECT(BUTTON_CAREER_CLICK);
    switch (sender.tag) {
        case kButtonBack:
            if ([GameManager sharedGameManager].oldScene == kMainScene || [GameManager sharedGameManager].oldScene == kGameScene) {
                [[GameManager sharedGameManager] runSceneWithID:kMainScene andTransition:kFadeTrans];
            } else if ([GameManager sharedGameManager].oldScene == kSettingsScene) {
                [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kSlideInL];
            }
            break;
        case kButtonEraseCareer:
            CCLOG(@"UIAlertView");
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"ERASE CAREER" message:@"Do you really want to erase your career?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
            [alert addButtonWithTitle:@"Yes"];
            [alert setTag:1];
            [alert show];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

#pragma mark Info button callback
- (void) infoButtonTapped:(id)sender {  
    //CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == infoOff) {
        panelActive = NO;
        [self endAnimation];//visible NO
        [self infoPanelOut];
    } else if (toggleItem.selectedItem == infoOn) {
        panelActive = YES;
        [self infoPanelIn];
    }  
}

#pragma mark Alert view
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 1) {
            [self eraseCareer];
        }
    }
}

#pragma mark -
#pragma mark CONSTRUCT SCORE & PERCENT LABELS
#pragma mark Construct percent Label
- (void) constructPercentLabel {
    for (int i = 0; i<3; i++) {
        Mask *percentMask = [Mask maskWithRect:CGRectMake(208 + 9*i, 135, 9, 18)];
        [self addChild:percentMask z:100+i];
        PercentNumber *percentNumber = [[PercentNumber alloc] init];
        [percentMask addChild:percentNumber];
        [percentLabelArray addObject:percentNumber];
        percentNumber.visible = NO;
    }
    [percentLabelArray reverseObjects];
}

- (void) constructScoreLabel {
    for (int i = 0; i<8; i++) {
        Mask *percentMask = [Mask maskWithRect:CGRectMake(170 + 9*i, 90, 9, 18)];
        [self addChild:percentMask z:200+i];
        PercentNumber *percentNumber = [[PercentNumber alloc] init];
        [percentMask addChild:percentNumber];
        [scoreLabelArray addObject:percentNumber];
        percentNumber.visible = NO;
    }
    [scoreLabelArray reverseObjects];
}

#pragma mark Draw to label
- (void) drawPercentToLabel {
    NSString *percentString = [NSString stringWithFormat:@"%i", percent];
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[percentString length]];
    for (int i=0; i < [percentString length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [percentString characterAtIndex:i]];
        [characters addObject:ichar];
    }
    PercentNumber *tempPercentNumber;
    for (int i=0; i < [characters count]; i++) {
        tempPercentNumber = [percentLabelArray objectAtIndex:i];
        [tempPercentNumber moveToPosition:[[[[characters reverseObjectEnumerator] allObjects] objectAtIndex:i] intValue]];
    }
}

- (void) drawScoreToLabel {
    NSString *percentString = [NSString stringWithFormat:@"%i", score];
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[percentString length]];
    for (int i=0; i < [percentString length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [percentString characterAtIndex:i]];
        [characters addObject:ichar];
    }
    PercentNumber *tempPercentNumber;
    for (int i=0; i < [characters count]; i++) {
        tempPercentNumber = [scoreLabelArray objectAtIndex:i];
        [tempPercentNumber moveToPosition:[[[[characters reverseObjectEnumerator] allObjects] objectAtIndex:i] intValue]];
    }
}

#pragma mark -
#pragma mark BUILD/ERASE CAREER BOARD
#pragma mark Build cities
- (void) buildCities {
    NSString *jsonString = [self jsonFromFile:@"Cities"];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    CJSONDeserializer *jsonDeserializer = [CJSONDeserializer deserializer];
    NSError *error = nil;
    NSDictionary *resultsDictionary = [jsonDeserializer deserializeAsDictionary:jsonData error:&error];
    [self handleError:error];
    NSArray *dataArray = [resultsDictionary objectForKey:@"cities"];
    City *city;
    for (NSDictionary *cDictionary in dataArray) {
        NSArray *lightsArray = [cDictionary objectForKey:@"light"];//convenient?
        NSArray *buttonsArray = [cDictionary objectForKey:@"button"];//convenient?
        buttonWidth = [[cDictionary objectForKey:@"button_width"] intValue];
        buttonHeight = [[cDictionary objectForKey:@"button_height"] intValue];
        city = [City spriteWithSpriteFrameName:@"logik_levels_bulbon_small.png"];
        city.anchorPoint = ccp(0, 0);
        city.position = ccp([[lightsArray objectAtIndex:0] floatValue], [[lightsArray objectAtIndex:1] floatValue]);
        city.buttonX = [[buttonsArray objectAtIndex:0] floatValue];
        city.buttonY = [[buttonsArray objectAtIndex:1] floatValue];
        city.belongs = [cDictionary objectForKey:@"belongs"];
        city.difficulty = [cDictionary objectForKey:@"difficulty"];
        city.idCity = [[cDictionary objectForKey:@"id"] intValue];
        [background addChild:city z:100];
        [citiesArray addObject:city];
    }
}

#pragma mark Build wires
- (void) buildWires {
    NSString *jsonString = [self jsonFromFile:@"Wires"];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    CJSONDeserializer *jsonDeserializer = [CJSONDeserializer deserializer];
    NSError *error = nil;
    NSDictionary *resultsDictionary = [jsonDeserializer deserializeAsDictionary:jsonData error:&error];
    [self handleError:error];
    NSArray *dataArray = [resultsDictionary objectForKey:@"wires"];
    Wire *wire;
    int i = 0;
    for (NSDictionary *wDictionary in dataArray) {
        NSArray *posArray = [wDictionary objectForKey:@"position"];//convenient?
        wire = [Wire spriteWithSpriteFrameName:[NSString stringWithFormat:@"wire%i.png", i]];
        wire.anchorPoint = ccp(0, 0);
        wire.position = ccp([[posArray objectAtIndex:0] floatValue]/2, [[posArray objectAtIndex:1] floatValue]/2);
        wire.lights = [wDictionary objectForKey:@"lights"];
        [background addChild:wire z:50];
        [wiresArray addObject:wire];
        i++;
    }
}

#pragma mark Build career from data
- (void) buildCareer {
    NSMutableArray *citiesDone = [[[GameManager sharedGameManager] gameData] getCareerData];
    citiesFull = citiesDone.count;
    for (NSMutableDictionary *dict in citiesDone) {
       for (City *city in citiesArray) {
           if (city.idCity == [[dict objectForKey:@"city"] intValue]) {
               city.visible = YES;
               city.isActive = YES;
               score += [[dict objectForKey:@"score"] intValue];
               prog += 1;
               if (city.idCity == 7 || city.idCity == 12)
                   percent += 6;
               else
                   percent += 4;
           }
        }
    }
    [self activateWires:NO];
    //[self endCareer];
}

#pragma mark -
#pragma mark END CAREER
#pragma mark Check end career
- (void) endCareer {
    endCareer = YES;
    
    tutorLayer = [CCLayer node];
    [self addChild:tutorLayer z:1000];
    tutorLayer.position = ccp(tutorLayer.position.x, tutorLayer.position.y + 480);
    tutorBlackout = [Blackout node];
    [tutorBlackout setOpacity:128];
    tutorBlackout.position = ccp(tutorBlackout.position.x, tutorBlackout.position.y + 270);
    [tutorLayer addChild:tutorBlackout z:1];
    
    CCSprite *buttonFb = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb.png"];
    CCSprite *buttonFbOver = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb_active.png"];
    CCSprite *buttonMail = [CCSprite spriteWithSpriteFrameName:@"logik_iconmail.png"];
    CCSprite *buttonMailOver = [CCSprite spriteWithSpriteFrameName:@"logik_iconmail_active.png"];
    
    CCMenuItem *fbItem = [CCMenuItemSprite itemFromNormalSprite:buttonFb selectedSprite:buttonFbOver target:self selector:@selector(fbMailTapped:)];
    fbItem.tag = kButtonFb;
    fbItem.position = ccp(70.00, 300.00);
    
    CCMenuItem *mailItem = [CCMenuItemSprite itemFromNormalSprite:buttonMail selectedSprite:buttonMailOver target:self selector:@selector(fbMailTapped:)];
    mailItem.tag = kButtonMail;
    mailItem.position = ccp(260.00, 300.00);
    
    CCMenu *finalMenu = [CCMenu menuWithItems:fbItem, mailItem, nil];
    finalMenu.position = CGPointZero;
    [tutorLayer addChild:finalMenu z:60];
    
    CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
    
    CCLabelBMFont *superBig = [CCLabelBMFont labelWithString:@"CONGRATULATIONS!" fntFile:@"Gloucester_levelBig.fnt"];
    superBig.scale = isRetina ? 1 : 0.5;
    superBig.rotation = -2;
    superBig.position = ccp(screenSize.width/2 - 15, screenSize.height - 80);
    [tutorLayer addChild:superBig z:21];
    
    CCLabelBMFont *superSmall = [CCLabelBMFont labelWithString:@"You have finished CAREER PLAY" fntFile:@"Gloucester_levelSmall.fnt"];
    superSmall.scale = isRetina ? 1 : 0.5;
    superSmall.rotation = -2;
    superSmall.position = ccp(screenSize.width/2 - 15, screenSize.height - 105);
    [tutorLayer addChild:superSmall z:21];
    
    
    id tutorIn = [CCMoveTo actionWithDuration:1 position:ccp(tutorLayer.position.x, tutorLayer.position.y - 480)];
    id tutorInSeq = [CCSequence actions:tutorIn,[CCCallFunc actionWithTarget:self selector:@selector(endInCallback)], nil];
    
    [tutorLayer runAction:tutorInSeq];
}

- (void) endInCallback {
    //[self schedule:@selector(startFanfare) interval:0.1];
    [self schedule:@selector(endFanfare) interval:17];
    fanfareSound = PLAYSOUNDEFFECT(FANFARE);
    [[GameManager sharedGameManager] duckling:0.05];
    [toggleItem activate];
    
    
    for (City *city in citiesArray) {
        id blinkk = [CCBlink actionWithDuration:480 blinks:1000];
        float delay = (float)[Utils randomNumberBetween:3 andMax:9]/10;
        id seq = [CCSequence actions:[CCDelayTime actionWithDuration:delay], blinkk, nil];
        //[finalBlinkArray addObject:seq];
        [city runAction:seq];
    } 
}

//- (void) startFanfare {
//    fanfareSound = PLAYSOUNDEFFECT(FANFARE);
//    if (fanfareSound != 0) {
//        [self unschedule:@selector(startFanfare)];
//    }
//}

- (void) endFanfare {
    [self unschedule:@selector(endFanfare)];
    if (endCareer) {
        [self stopAnimationsAndSound];
    }
}

- (void) stopAnimationsAndSound {
    endCareer = NO;
    [[GameManager sharedGameManager] duckling:[GameManager sharedGameManager].musicVolume];
    STOPSOUNDEFFECT(fanfareSound);
    for (City *city in citiesArray) {
        [city stopAllActions];
        city.visible = YES;
    }
    //id tutorOut = [CCMoveTo actionWithDuration:1 position:ccp(tutorLayer.position.x, tutorLayer.position.y + 480)];
    //[tutorLayer runAction:tutorOut];
    singleTapGestureRecognizer.enabled = NO;
}

- (void) fbMailTapped:(CCMenuItem *)sender {
    PLAYSOUNDEFFECT(BUTTON_CAREER_CLICK);
    switch (sender.tag) {
        case kButtonFb: 
            CCLOG(@"TAP ON FB");
            FacebookViewController *controller = [[GameManager sharedGameManager] facebookController];
            [controller login:1000];
            break;
        case kButtonMail:
            CCLOG(@"TAP ON MAIL");
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;           
            [picker setSubject:[NSString stringWithFormat:@"Are you smarter then me?"]];
            NSArray *toRecipients = [NSArray arrayWithObject:@""];
            [picker setToRecipients:toRecipients];
            NSString *emailBody = [NSString stringWithFormat:@"Hi, I wonder if you are smarter then me? If you think so, try to beat my new high score %i in the iPhone&iPod game The Power of Logic! Check it on <a href=\"http://itunes.apple.com/us/app/power-of-logic/id452804654\">iTunes App Store</a>.  \n\n\n\n", 1000];
            [picker setMessageBody:emailBody isHTML:YES];
            
            mailController = [[UIViewController alloc] init];
            [mailController setView:[[CCDirector sharedDirector] openGLView]]; 
            [mailController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            
            NSString *iconpath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LogicLogo.jpg"];
            NSData *icondata = [NSData dataWithContentsOfFile:iconpath];
            [picker addAttachmentData:icondata mimeType:@"image/jpeg" fileName:@"Logic.jpg"];
            
            [mailController presentModalViewController:picker animated: YES];
            [picker release];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {   
    switch (result)
    {
        case MFMailComposeResultCancelled:
            CCLOG(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            CCLOG(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            CCLOG(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            CCLOG(@"Result: failed");
            break;
        default:
            CCLOG(@"Result: not sent");
            break;
    }
    [mailController dismissModalViewControllerAnimated:YES];
    [mailController release];
}

#pragma mark -
#pragma mark CHECKING CITIES
#pragma mark Show city currently in progress
- (void) showCityInProgress {
    city city = [[[GameManager sharedGameManager] gameData] getCityInProgress];
    if (city.idCity > 0) {
        PLAYSOUNDEFFECT(BULB_BLINK);
        zoomBase.position = ccp(city.position.x, city.position.y);
        zbLastPos = zoomBase.position;
        for (City *c in citiesArray) {
            if (c.idCity == city.idCity) {
                currentCity = c;
            }
        }
        [self schedule:@selector(currentCityUpdate:) interval:0.3];
    }
}

- (void) showLastCity {
    city lcity = [[[GameManager sharedGameManager] gameData] getLastCity];
    if (lcity.idCity > 0) {
        zoomBase.position = ccp(lcity.position.x, lcity.position.y);
        zbLastPos = zoomBase.position;
        score = lcity.score;
        prog += 1;
        if (lcity.idCity == 7 || lcity.idCity == 12)
            percent += 6;
        else
            percent += 4;
        for (City *c in citiesArray) {
            if (c.idCity == lcity.idCity) {
                c.visible = YES;
                c.opacity = 0;
                id lastCitySeq = [CCSequence actions:[CCDelayTime actionWithDuration: 0.1f], 
                                  [CCCallFuncND actionWithTarget:self selector:@selector(lastCity:data:) data:c], nil];
                [self runAction:lastCitySeq];
            }
        }
        [[[GameManager sharedGameManager] gameData] updateCarrerLastCity];
    }
}

- (void) currentCityUpdate:(ccTime)dt {
    currentCity.visible = blink;
    blink = !blink;
}

#pragma mark Last city callback
- (void) lastCity:(id)sender data:(City *)city {
    CCLOG(@"tak kolik je kurva tech mest? %i", citiesFull);
    PLAYSOUNDEFFECT(BULB_BLINK);
    city.isActive = YES;
    [self activateWires:YES];
    id fadeCitySeq = [CCSequence actions:[CCDelayTime actionWithDuration: 0.4f], [CCFadeIn actionWithDuration:0.3f],
                      [CCCallFunc actionWithTarget:self selector:@selector(checkEnd)], nil];
    [city runAction:fadeCitySeq];
}

#pragma mark Check end game
- (void) checkEnd {
    //if (citiesFull == citiesArray.count) {
    CCLOG(@"CITIES - END CAREER %i", citiesFull);
    if (citiesFull == 1) {
        [self endCareer];
    }
}

#pragma mark Activate wires
- (void) activateWires:(BOOL)animation {
    for (Wire *wire in wiresArray) {
        int counter = 0;
        City *city;
        for (int i = 0; i < [wire.lights count]; i++) {
            city = [citiesArray objectAtIndex:[[wire.lights objectAtIndex:i] intValue] - 1];
            if (city.isActive) {
                counter ++;
            }
        }
        if (counter == [wire.lights count]) {
            if (animation) {
                if (!wire.visible) {
                    wire.visible = YES;
                    wire.opacity = 0;
                    id wireFadeIn = [CCSequence actions:[CCDelayTime actionWithDuration: 0.3f], [CCFadeIn actionWithDuration:0.2f], nil];
                    [wire runAction:wireFadeIn];
                }
            } else {
                wire.visible = YES;
            }
        }
    }
}

#pragma mark Erase career
- (void) eraseCareer {
    [[[GameManager sharedGameManager] gameData] resetCareer];
    [[[GameManager sharedGameManager] gameData] gameDataCleanup];
    for (City *city in citiesArray) {
        city.visible = NO;
        city.isActive = NO;
    }
    for (Wire *wire in wiresArray) {
        wire.visible = NO;
    }
    if (currentCity) {
        [self unschedule:@selector(currentCityUpdate:)];
        currentCity.visible = NO;
        currentCity = nil;
    }
    percent = 0;
    score = 0;
    prog = 0;
    [self setProgress];
    PercentNumber *tempPercentNumber;
    for (int i=1; i < 3; i++) {
        tempPercentNumber = [percentLabelArray objectAtIndex:i];
        [tempPercentNumber moveToPosition:-1];
    }
    for (int i=1; i < 8; i++) {
        tempPercentNumber = [scoreLabelArray objectAtIndex:i];
        [tempPercentNumber moveToPosition:-1];
    }
    scoreSoundErase = PLAYSOUNDEFFECT(CAREER_SCORE);
    [self schedule:@selector(stopSoundEraseCallback) interval:1.0];
    [self drawPercentToLabel];
    [self drawScoreToLabel];
}

#pragma mark Show progress on panel
- (void) setProgress {
    if (panelActive) {
        CGRect barRect = [progressBar textureRect];
        //barRect.size.width = total / 24 * prog;
        barRect.size.width = 137 / 24 * prog;
        [progressBar setTextureRect: barRect];
        [self drawPercentToLabel];
        [self drawScoreToLabel];
        scoreSound = PLAYSOUNDEFFECT(CAREER_SCORE);
        [self schedule:@selector(stopSoundCallback) interval:1.0];
    }
}

- (void) stopSoundCallback {
    STOPSOUNDEFFECT(scoreSound);
    [self unschedule:@selector(stopSoundCallback)];
}

- (void) stopSoundEraseCallback {
    STOPSOUNDEFFECT(scoreSoundErase);
    [self unschedule:@selector(stopSoundEraseCallback)];
}

#pragma mark -
#pragma mark ANALYSE CITY, RUN GAME
#pragma mark Analyse city
- (void) analyseCity {
    if (selSprite.isActive)
        return;
    BOOL active = NO;
    diff = 6;
    City *city;
    if ([selSprite.belongs count] == 0) {//cities with zero belongs (typically cities at start level)
        active = YES;
        diff = [[selSprite.difficulty objectAtIndex:0] intValue];//start city has only one difficulty
    } else {
        for (int i = 0; i < [selSprite.belongs count]; i++) {
            int index = [[selSprite.belongs objectAtIndex:i] intValue];
            city = [citiesArray objectAtIndex:index - 1];
            if (city.isActive) {
                active = YES;
                if ([[selSprite.difficulty objectAtIndex:i] intValue] < diff) {
                    diff = [[selSprite.difficulty objectAtIndex:i] intValue];//set diff to lowest possible value
                }
            }
        }
    }
    if (active) {
        if (currentCity) {
            [self unschedule:@selector(currentCityUpdate:)];
            currentCity.visible = NO;
            currentCity = nil;
        }
        [self blinkCity:selSprite];
        PLAYSOUNDEFFECT(BULB_BLINK);
        singleTapGestureRecognizer.enabled = NO;
        //TESTING
//        selSprite.visible = YES;
//        selSprite.isActive = YES;
//        prog += 1;
//        if (selSprite.idCity == 7 || selSprite.idCity == 12)
//            percent += 6;
//        else
//            percent += 4;
//        [self activateWires];
        //TESTING
    } 
}

#pragma mark Blink city
- (void) blinkCity:(City *)city {
    id blinkk = [CCBlink actionWithDuration:0.3 blinks:3];
    id seq = [CCSequence actions:blinkk, [CCCallFunc actionWithTarget:self selector:@selector(runGame)], nil];
    [city runAction: seq];
}

#pragma mark Run career game
- (void) runGame {
    CCLOG(@"RUN GAME");
    //delete career game eventually in progress
    [[[GameManager sharedGameManager] gameData] updateCareerData:NO andScore:0];
    [[[GameManager sharedGameManager] gameData] gameDataCleanup];
    [[[GameManager sharedGameManager] gameData] writeCareerTutor];
    gameInfo infoData;
    infoData.difficulty = diff;
    infoData.activeRow = 0;
    infoData.career = 1;
    infoData.score = 0;
    infoData.gameTime = 0;
    infoData.tutor = 0;
    [[[GameManager sharedGameManager] gameData] insertGameData:infoData];
    [[[GameManager sharedGameManager] gameData] insertCareerData:selSprite.idCity xPos:zbLastPos.x yPos:zbLastPos.y];
    [[GameManager sharedGameManager] runSceneWithID:kGameScene andTransition:kFadeTrans];    
}

#pragma mark -
#pragma mark PAN & PINCH METHODS
#pragma mark Adjust position for pan & pinch
- (CGPoint) boundLayerPos:(CGPoint)newPos {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, POS_X);
    retval.x = MAX(retval.x, -background.contentSize.width*0.8 + POS_X + winSize.width);
    retval.y = MIN(retval.y, -POS_Y);
    retval.y = MAX(retval.y, -background.contentSize.height*0.8 - POS_Y + winSize.height);
    return retval;
}

#pragma mark Zooming layer - pinch callback
- (void) zoomLayer:(float)zoomScale {
	if ((zoomBase.scale*zoomScale) <= MIN_SCALE) {
		zoomScale = MIN_SCALE/zoomBase.scale;
	}
	if ((zoomBase.scale*zoomScale) >= MAX_SCALE) {
		zoomScale =	MAX_SCALE/zoomBase.scale;
	}
	zoomBase.scale = zoomBase.scale*zoomScale;
}

#pragma mark Moving layer - pan callback
- (void) moveBoard:(CGPoint)translation from:(CGPoint)lastLocation {
	CGPoint target_position = ccpAdd(translation, lastLocation);
    zoomBase.position = [self boundLayerPos:target_position];
}

#pragma mark Single tap callback
- (void) selectSpriteForTouch:(CGPoint)touchLocation {
    City *newSprite = nil;
    for (City *sprite in citiesArray) {
        if (CGRectContainsPoint(CGRectMake(sprite.buttonX, sprite.buttonY, 46, 56), touchLocation)) {            
            newSprite = sprite;
            break;
        }
    }
    selSprite = newSprite;
    if (selSprite) {
        [self analyseCity]; 
    }
}

#pragma mark -
#pragma mark UIGesture recognizer handlers
#pragma mark Single tap handler
- (void) handleSingleTapFrom:(UITapGestureRecognizer *)recognizer {
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [background convertToNodeSpace:touchLocation];               
    [self selectSpriteForTouch:touchLocation];
    if (endCareer) {
        [self stopAnimationsAndSound];
    }
}

#pragma mark Pan handler
- (void) handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint translation = [recognizer translationInView:recognizer.view];
		translation.y = -1 * translation.y;
		[self moveBoard:translation from:zbLastPos];
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
        zbLastPos = zoomBase.position;
    }
}

#pragma mark Pinch handler
- (void) handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
	if ((recognizer.state == UIGestureRecognizerStateBegan) || (recognizer.state == UIGestureRecognizerStateChanged)) {
        float zoomScale = [recognizer scale];
		[self zoomLayer:zoomScale];        
		recognizer.scale = 1;
	}
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		zbLastPos = zoomBase.position;
	}
}

#pragma mark -
#pragma mark Data from file - helper method
- (NSString *) jsonFromFile:(NSString *)file {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];  
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    NSString *s = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];    
    return s;
}

#pragma mark -
#pragma mark Error handlers
- (void) handleError:(NSError *)error {
    if (error != nil) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [errorAlertView show];
        [errorAlertView release];
    }
}

#pragma mark -
#pragma mark Dealloc memory
- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [citiesArray release];
    citiesArray = nil;
    [wiresArray release];
    wiresArray = nil;
    [percentLabelArray release];
    percentLabelArray = nil;
    [scoreLabelArray release];
    scoreLabelArray = nil;
    [finalBlinkArray release];
    finalBlinkArray = nil;
    [super dealloc];
}

@end