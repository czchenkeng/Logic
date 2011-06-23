//
//  ScoreLayer.m
//  Logic
//
//  Created by Pavel Krusek on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreLayer.h"


@implementation ScoreLayer


- (void)onEnter {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (void) buttonTapped:(CCMenuItem *)sender { 
    switch (sender.tag) {
        case kButtonBack:
            CCLOG(@"TAP ON BACK");
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

- (void) diffTapped:(CCMenuItem *)sender {
    int flag;
    switch (sender.tag) {
        case kEasy: 
            CCLOG(@"TAP ON EASY");
            joyStick.position = ccp(92.00, 135.00);
            flag = 0;
            break;
        case kMedium:
            CCLOG(@"TAP ON MEDIUM");
            joyStick.position = ccp(92.00, 92.00);
            flag = 1;
            break;
        case kHard:
            CCLOG(@"TAP ON HARD");
            joyStick.position = ccp(92.00, 49.00);
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
    
    //[GameManager sharedGameManager].currentDifficulty = sender.tag;
}


- (id) init {
    self = [super init];
    if (self != nil) {

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; 
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"LogicDatabase.sqlite"];
        CCLOG(@"dir %@", documentsDirectory);
        db = [FMDatabase databaseWithPath:writableDBPath];
        if (![db open])
            CCLOG(@"Could not open db.");
        else
            CCLOG(@"Db is here!");
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM scores", @"main"];
        if ([db hadError]) {
            NSLog(@"DB Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }

        CCLOG(@"co result set? %@", rs);
        while ([rs next]) {
            NSString *a = [rs stringForColumnIndex:1];
            CCLOG(@"dbase result %@", a);
        }
        
        [db close];
        
        difficulty = [[CCArray alloc] init];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"score.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background z:1];
        
        
        CCSprite *buttonBackOff = [CCSprite spriteWithSpriteFrameName:@"back_off.png"];
        CCSprite *buttonBackOn = [CCSprite spriteWithSpriteFrameName:@"back_on.png"];
        
        CCMenuItem *backItem = [CCMenuItemSprite itemFromNormalSprite:buttonBackOff selectedSprite:buttonBackOn target:self selector:@selector(buttonTapped:)];
        backItem.tag = kButtonBack;
        backItem.position = ccp(29.50, 453.50);
        
        CCMenu *topMenu = [CCMenu menuWithItems:backItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:2];
        
        joyStick = [CCSprite spriteWithSpriteFrameName:@"logik_settpaka.png"];
        [self addChild:joyStick z:5];
        
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_easy1.png"];
        sprite.position = ccp(210.50, 138.50);
        [self addChild:sprite z:6 tag:6];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_hard1.png"];
        sprite.position = ccp(210.50, 52.00);
        [self addChild:sprite z:7 tag:7];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_normal1.png"];
        sprite.position = ccp(210.50, 95.00);
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
        sprite.position = ccp(210.50, 138.50);
        [easy addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ccp(166.00, 141.00);
        [easy addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_normal2.png"];
        sprite.position = ccp(210.50, 95.00);
        [normal addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ccp(166.00, 97.50);
        [normal addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_hard2.png"];
        sprite.position = ccp(210.50, 52.00);
        [hard addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ccp(165.50, 53.50);
        [hard addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi3.png"];
        sprite.position = ccp(316.00, 243.50);
        sprite.rotation = -5;
        [self addChild:sprite z:100];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi2.png"];
        sprite.position = ccp(23.50, 346.00);
        [self addChild:sprite z:101];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi1.png"];
        sprite.position = ccp(306.50, 17.00);
        [self addChild:sprite z:102];
        
        CCSprite *buttonEasyOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonEasyOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonNormalOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonNormalOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonHardOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonHardOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        
        easyItem = [CCMenuItemSprite itemFromNormalSprite:buttonEasyOff selectedSprite:buttonEasyOn target:self selector:@selector(diffTapped:)];
        easyItem.tag = kEasy;
        easyItem.position = ccp(205.00, 139.00);
        
        normalItem = [CCMenuItemSprite itemFromNormalSprite:buttonNormalOff selectedSprite:buttonNormalOn target:self selector:@selector(diffTapped:)];
        normalItem.tag = kMedium;
        normalItem.position = ccp(205.00, 95.50);
        
        hardItem = [CCMenuItemSprite itemFromNormalSprite:buttonHardOff selectedSprite:buttonHardOn target:self selector:@selector(diffTapped:)];
        hardItem.tag = kHard;
        hardItem.position = ccp(205.00, 53.00);
        
        PressMenu *difficultyMenu = [PressMenu menuWithItems:easyItem, normalItem, hardItem, nil];
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
    }
    return self;
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

@end
