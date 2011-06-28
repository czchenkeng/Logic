//
//  GameplayLayer.m
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameplayLayer.h"


@implementation GameplayLayer

- (void) prepareAssets {
    NSString *hw = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        hw = @"Pad";
    }
    
    greenLights = [[CCArray alloc] init];
    orangeLights = [[CCArray alloc] init];
    
    clippingNode = [CCLayer node];
    movableNode = [CCLayer node];
    figuresNode = [CCLayer node];
    //figuresNode = [Mask maskWithRect:CGRectMake(0, 100, 320, 380)];
    
    assetsLevelBgNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"LevelBg%@.pvr.ccz", hw]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"LevelBg%@.plist", hw]];
    
    assetsLevelNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"Level%@.plist", hw]];
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
    cheat = [CCSprite spriteWithSpriteFrameName:levelEndFrame];
    
    rotorLeftMain = [[CCSprite alloc] init];
    rotorRightMain = [[CCSprite alloc] init];
    rotorLeft = [CCSprite spriteWithSpriteFrameName:@"rotor_left.png"];
    rotorRight = [CCSprite spriteWithSpriteFrameName:@"rotor_right.png"];
    rotorLeftInside = [CCSprite spriteWithSpriteFrameName:@"rotor_left_inside.png"];
    rotorRightInside = [CCSprite spriteWithSpriteFrameName:@"rotor_right_inside.png"];
    rotorLeftLight = [CCSprite spriteWithSpriteFrameName:@"rotor_left_light.png"];
    rotorRightLight = [CCSprite spriteWithSpriteFrameName:@"rotor_right_light.png"];
    
    sphereLight = [CCSprite spriteWithSpriteFrameName:@"lightSphere.png"];
    
    krytka = [CCSprite spriteWithSpriteFrameName:@"logik_krytka.png"];
    
    //    NSMutableArray *morphingSphereFrames = [NSMutableArray array];
    //NSMutableArray *morphingSphereFrames = [[NSMutableArray alloc] init];
    morphingSphereFrames = [NSMutableArray array];
    for(int i = 1; i <= 15; ++i){
        [morphingSphereFrames  addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"ball_anim%d.png", i]]];
    }
    
    sphereAnim = [CCAnimation animationWithFrames:morphingSphereFrames delay:0.1f];
    //CCAction *sphereAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:sphereAnim restoreOriginalFrame:YES]];
    //CCAction *sphereAction = [CCAnimate actionWithAnimation:sphereAnim restoreOriginalFrame:YES];
    
    sphereSeq = [CCSequence actions:
                           [CCAnimate actionWithAnimation:sphereAnim restoreOriginalFrame:YES],
                           [CCCallFunc actionWithTarget:self selector:@selector(sphereAnimEnded)],
                           nil];
    
    sphere = [CCSprite spriteWithSpriteFrameName:@"ball_anim1.png"];
    [sphereNode addChild:sphere];
    //[sphere runAction:sphereAction];
    [sphere runAction:sphereSeq];
    
    for(int i = 0; i < 10; ++i){
        CCSprite *greenLight = [CCSprite spriteWithSpriteFrameName:@"greenLight.png"];
        greenLight.position = ccp(288, 82 + i*44);
        greenLight.opacity = 0;
        [movableNode addChild:greenLight z:i tag:i];
        [greenLights addObject:greenLight];
        
        CCSprite *orangeLight = [CCSprite spriteWithSpriteFrameName:@"orangeLight.png"];
        orangeLight.position = ccp(308, 82 + i*44);
        orangeLight.opacity = 0;
        [movableNode addChild:orangeLight z:i + 10 tag:i + 10];
        [orangeLights addObject:orangeLight];
    }
    
    base = [CCSprite spriteWithSpriteFrameName:@"pinchBase.png"];
    base.anchorPoint = CGPointMake(0, 0);
    
    //nodes position
    codeBase.position = ccp(133, 455);
    
//    rotorLeft.position = ccp(54.00, 430.00);
//    rotorRight.position = ccp(259.00, 434.00);
//    sphereNode.position = ccp(152, 474);
//    rotorRightInside.position = ccp(259.00, 434.00);
//    rotorLeftInside.position = ccp(54.00, 430.00);
//    rotorRightLight.position = ccp(259.00, 434.00);
//    rotorLeftLight.position = ccp(54.00, 430.00);
    
    rotorRightMain.position = ccp(259.00, 434.00);
    rotorLeftMain.position = ccp(54.00, 430.00);
    sphereNode.position = ccp(152, 474);
    
    sphereLight.position = ccp(150.00, 411.00);
    krytka.position = ccp(160.00, 456.00);

    
    //add nodes to display list
    [self addChild:clippingNode z:1 tag:1];
    [self addChild:movableNode z:2 tag:2];
    //Mask *test = [Mask maskWithRect:CGRectMake(0, 150, 320, 150)];
    //[movableNode addChild:test z:-1 tag:-1];
    //[test addChild:bg];
    [movableNode addChild:bg z:-1 tag:-1];
    //bg.opacity = 80;
    
    [self addChild:codeBase z:3 tag:3];
    [self addChild:krytka z:4];
    [self addChild:sphereLight z:5];
    [self addChild:rotorLeftMain z:6];
    [self addChild:rotorRightMain z:7];
    [self addChild:sphereNode z:6 tag:8];
    [self addChild:base z:7 tag:9];
    [self addChild:figuresNode z:10];
    
    
    
    cheat.position = ccp(133, 60);
    cheat.opacity = 0;
    [self addChild:cheat z:100];
    
    [rotorLeftMain addChild:rotorLeft z:1];
    [rotorLeftMain addChild:rotorLeftLight z:2];
    [rotorLeftMain addChild:rotorLeftInside z:3];
    
    [rotorRightMain addChild:rotorRight z:1];
    [rotorRightMain addChild:rotorRightLight z:2];
    [rotorRightMain addChild:rotorRightInside z:3];
    
    
//    RowScore *rs = [[RowScore alloc] init];
//    rs.position = ccp(200, 150);
//    [self addChild:rs z:8];
    
    [movableNode addChild:highlightSprite z:200];
    
    ProgressTimer *timer = [[ProgressTimer alloc] init];
    [self addChild:timer z:10000];
    
//    CCMoveTo *moveDown = [CCMoveTo actionWithDuration:.3 position:CGPointMake(movableNode.position.x, movableNode.position.y - 64)];
//    [movableNode runAction:moveDown];
    //release memory
    [hw release];
    [bgFrame release];
    [levelEndFrame release];
//    [morphingSphereFrames release];
//    morphingSphereFrames = nil;
}

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

- (void) generateCode {
    //currentCode = [[CCArray alloc] init];
    currentCode = [[NSMutableArray alloc] init];
    for (int i = 0; i < currentDifficulty; ++i) {
        int cheatCode = [Utils randomNumberBetween:0 andMax:8];
        //Figure *figure = [[Figure alloc] initWithFigureType:[Utils randomNumberBetween:0 andMax:8]];
        Figure *figure = [[Figure alloc] initWithFigureType:cheatCode];
        figure.place = i;
        figure.anchorPoint = CGPointMake(0, 0);
        figure.position = ccp(6 + difficultyPadding*i, 10.0f);
        
        Figure *cheatFigure = [[Figure alloc] initWithFigureType:cheatCode];
        cheatFigure.anchorPoint = CGPointMake(0, 0);
        cheatFigure.position = ccp(6 + difficultyPadding*i, 10.0f);
        cheatFigure.opacity = 150;
        
        //CCLOG(@"retain before is %d", [figure retainCount]);
        [codeBase addChild:figure z:i];
        [cheat addChild:cheatFigure z:i];
        [currentCode addObject:figure];
        //CCLOG(@"retain is %d", [figure retainCount]);
    }
}

- (void) addFigures {    
    movableFigures = [[CCArray alloc] init];
    
    float pinchXpos[8] = {27.55, 66.11, 104.66, 143.22, 180.77, 218.33, 256.88, 294.44};
    
    for (int i = 0; i < 8; ++i) {
        Figure *figure = [[Figure alloc] initWithFigureType:i];
        //figure.anchorPoint = CGPointMake(0.5, 0);
        figure.position = ccp(pinchXpos[i], 32.0f);
        figure.originalPosition = ccp(figure.position.x, figure.position.y);
        [figuresNode addChild:figure z:i];
        [movableFigures addObject:figure];
        //[figure destroy];
    }    
}

- (void) generateTargets {
    targets = [[CCArray alloc] init];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Level.plist"];
    for (int i = 0; i < currentDifficulty; ++i) {
        CCSprite *targetPoint = [CCSprite spriteWithSpriteFrameName:@"debug_center.png"];
        targetPoint.opacity = 0;
        [movableNode addChild:targetPoint z:100 + i];
        [targets addObject:targetPoint];
    }
}

- (void) constructRowWithIndex:(int)row {
    int i = 0;
    for (CCSprite *sprite in targets) {
        sprite.position = ccp(32.0 + i*difficultyPadding, 81.0 + row*44);
        i++; 
    }
}

- (void) createLevel {
    [self prepareAssets];
    [self generateCode];
    [self addFigures];
    [self generateTargets];
    [self constructRowWithIndex:activeRow];
}

- (void) createEditableCopyOfDatabaseIfNeeded {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"LogicDatabase.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    CCLOG(@"success %i", success);
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LogicDatabase.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        
        
        
        [self createEditableCopyOfDatabaseIfNeeded];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; 
        NSString *DBPath = [documentsDirectory stringByAppendingPathComponent:@"LogicDatabase.sqlite"];
        
        db = [[FMDatabase databaseWithPath:DBPath] retain];
        if (![db open]) {
            CCLOG(@"Could not open db.");
            [db setLogsErrors:TRUE];
            [db setTraceExecution:TRUE];
        } else {
            CCLOG(@"Db is here!");
        }

        
        
        
        
        
        dislocation = 0.0;
        activeRow = 0;
        lastPlace = -1;
        currentDifficulty = [[GameManager sharedGameManager] currentDifficulty];
        targetSprite = nil;
        isEndRow = NO;
        isMovable = NO;
        //userCode = [[CCArray alloc] init];
        userCode = [[NSMutableArray alloc] init];
        placeNumbers = [[CCArray alloc] init];
        colorNumbers = [[CCArray alloc] init];
        deadFigures = [[CCArray alloc] init];
        touchArray = [[NSMutableArray alloc] init];
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        [self createLevel];
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
    selSprite.startTime = [NSDate date]; 
    [selSprite stopAllActions];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:.3 scale:1.4];
    [newSprite runAction:scale];          
//        if (selSprite) {
//            [figuresNode reorderChild:selSprite z:selSprite.zOrder - 100];
//        }
    selSprite = newSprite;
    //selSprite.position = ccp(selSprite.position.x, selSprite.position.y + 20.00);
    //CCMoveTo *figureForward = [CCMoveTo actionWithDuration:0.3 position:ccp(selSprite.position.x, selSprite.position.y + 20.00)];
    //[selSprite runAction:figureForward];
    if (selSprite) {
        [figuresNode reorderChild:selSprite z:selSprite.zOrder + 100];
    }   
}

- (void) panForTranslation:(CGPoint)translation {    
    //CCLOG(@"Sel Sprite %@", selSprite);
    if (selSprite) {
        selSprite.endTime = [NSDate date];
        //CCLOG(@"TIME %i", selSprite.endTime.  - selSprite.startTime);
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        if (newPos.y < 380)
            selSprite.position = newPos;
    }  
}

- (void) activateTargetWithTarget:(CCSprite *)sprite andPlace:(int)place {
    if (targetSprite != sprite) {
        //CCLOG(@"Logic debug: Target sprite %@", sprite);
        targetSprite = sprite;
        highlightSprite.visible = YES;
        highlightSprite.position = ccp(targetSprite.position.x, targetSprite.position.y);
        selSprite.place = place;
        //currentPlace = place;
    }
}

- (void) detectTarget {
    if (selSprite) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        int i = 0;
        for (CCSprite *sprite in targets) {
            //CGRect rect = CGRectMake(sprite.position.x, sprite.position.y, sprite.boundingBox.size.width, 80 - sprite.position.y);
            CGRect rect = CGRectMake(sprite.position.x, screenSize.height, sprite.boundingBox.size.width, 80 - screenSize.height);
            if (CGRectIntersectsRect(selSprite.boundingBox, rect)) {
                [self activateTargetWithTarget:sprite andPlace:i];
                //CCLOG(@"rects from detect %@", NSStringFromCGRect(rect));
            }
            i++;
        } 
    }
}

#pragma mark -
#pragma mark Touches
//- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event  {       
//    UITouch *touch = [touches anyObject];
//    CGPoint new_location = [touch locationInView: [touch view]];
//    new_location = [[CCDirector sharedDirector] convertToGL:new_location];
//    
//    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
//    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
//    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
//
//    [touchArray addObject:NSStringFromCGPoint(new_location)];
//    [touchArray addObject:NSStringFromCGPoint(oldTouchLocation)];
//    CCLOG(@"touches moved");
//}
//
//
//- (void) draw {
//    glEnable(GL_LINE_SMOOTH);
//    
//    for(int i = 0; i < [touchArray count]; i+=2) {
//        CGPoint start = CGPointFromString([touchArray objectAtIndex:i]);
//        CGPoint end = CGPointFromString([touchArray objectAtIndex:i+1]);
//        
//        ccDrawLine(start, end);
//        CCLOG(@"paint %@", NSStringFromCGPoint(start));
//    }
//}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {       
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    //CCLOG(@"Translation %f %f", translation.x, translation.y);
    
    
    [self panForTranslation:translation];
    [self detectTarget];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];

    touchOrigin = [touch locationInView:[touch view]];
	touchOrigin = [[CCDirector sharedDirector] convertToGL:touchOrigin];
    
    return YES;
}

//callback method
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
    sprite.tempPosition = ccp(sprite.position.x, sprite.position.y + dislocation);
        
    Figure *tempSprite = nil;
    for (Figure *userSprite in userCode) {
        if (userSprite.place == sprite.place) {
            tempSprite = userSprite;
        }
    }
    if (tempSprite) {
        CCLOG(@"temp sprite je %@", tempSprite);
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

//callback method
- (void) swapFigure:(Figure *)sprite {
    highlightSprite.visible = NO;
    Figure *existSprite = nil;
    for (Figure *userSprite in userCode) {
        if (userSprite.oldPlace == sprite.place) {
            existSprite = userSprite;
        }
    }
    CCLOG(@"exist sprite je %@ pos %i", existSprite, existSprite.oldPlace);
    if (existSprite) {
        existSprite.place = sprite.oldPlace;
        existSprite.oldPlace = sprite.oldPlace;
        existSprite.position = sprite.tempPosition;
        //CCMoveTo *moveExist = [CCMoveTo actionWithDuration:.3 position:CGPointMake(sprite.tempPosition.x, sprite.tempPosition.y)];
        //[existSprite runAction:moveExist];
        existSprite.tempPosition = ccp(sprite.tempPosition.x, sprite.tempPosition.y + dislocation);
    }
    sprite.oldPlace = sprite.place;
}

- (void) figureSetCorrectPosition:(id)sender data:(Figure *)sprite {
    sprite.tempPosition = ccp(sprite.position.x, sprite.position.y + dislocation);
    [figuresNode reorderChild:selSprite z:sprite.zOrder - 100];
}

- (void) swipeEnd {
    for (Mask *mask in placeNumbers) {
        [mask redrawRect:CGRectMake(mask.position.x - 50, mask.position.y - dislocation * dir, 12, 18)];
    }
    for (Mask *mask in colorNumbers) {
        [mask redrawRect:CGRectMake(mask.position.x - 50, mask.position.y - dislocation * dir, 12, 18)];
    }
}

- (void) swipeArea:(int)direction {
    //CCMoveTo *move = [CCMoveTo actionWithDuration:.3 position:CGPointMake(movableNode.position.x, movableNode.position.y - dislocation * direction)];
    //[movableNode runAction:move];
    dir = direction;
    CCSequence *moveSeq = [CCSequence actions:
                   [CCMoveTo actionWithDuration:.3 position:CGPointMake(movableNode.position.x, movableNode.position.y - dislocation * direction)],
                   [CCCallFunc actionWithTarget:self selector:@selector(swipeEnd)],
                   nil];
    [movableNode runAction:moveSeq];
    for (Mask *mask in placeNumbers) {
        [mask redrawRect:CGRectMake(mask.position.x + 50, mask.position.y, 12, 18)];
    }
    for (Mask *mask in colorNumbers) {
        [mask redrawRect:CGRectMake(mask.position.x + 50, mask.position.y, 12, 18)];
    }
    movableFlag = !movableFlag;
}

- (void) nextRow {
    [userCode removeAllObjects];
    activeRow ++;
    [self constructRowWithIndex:activeRow];
    if (activeRow == LEVEL_SWIPE_AFTER_ROW) {
        isMovable = YES;
        movableFlag = YES;
        dislocation = LEVEL_DISLOCATION;
        [self swipeArea:1];
    }
}

- (void) showResult {
    if (places > 0) {
        CCSprite *greenLight = [greenLights objectAtIndex:activeRow];
        //CCFadeTo *fadeTo = [CCFadeTo actionWithDuration:0.5f opacity:255];
        id fadeToGreen = [CCFadeTo actionWithDuration:0.5f opacity:255];
        [greenLight runAction:fadeToGreen];
        
        Mask *holderPlace = [Mask maskWithRect:CGRectMake(greenLight.position.x - 3, greenLight.position.y + 8 - dislocation, 12, 18)];
        //holderPlace.anchorPoint = CGPointMake(0.5, 0);
        [clippingNode addChild:holderPlace z:activeRow - 10000];
        [placeNumbers addObject:holderPlace];
        
        RowScore *rs = [[RowScore alloc] init];
        //rs.position = ccp(greenLight.position.x + 2, greenLight.position.y + 26);
        //[movableNode addChild:rs z:activeRow - 10000];
        [holderPlace addChild:rs z:1 tag:1];
        [rs moveToPosition:places];
        
    }
    if (colors > 0) {
        CCSprite *orangeLight = [orangeLights objectAtIndex:activeRow];
        id fadeToOrange = [CCFadeTo actionWithDuration:0.5f opacity:255];
        [orangeLight runAction:fadeToOrange];
        
        Mask *holderColors = [Mask maskWithRect:CGRectMake(orangeLight.position.x - 5, orangeLight.position.y + 8 - dislocation, 12, 18)];
        [clippingNode addChild:holderColors z:activeRow - 10000];
        [colorNumbers addObject:holderColors];
        
        RowScore *rc = [[RowScore alloc] init];
        [holderColors addChild:rc z:1 tag:1];
        [rc moveToPosition:colors];
    }
}

- (void) endGame {
    CCLOG(@"Logic debug: END GAME");
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/M/yy"];
        
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"h:ma"];
    NSDate *now = [[NSDate alloc] init];       
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    [db beginTransaction];         
    [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:[Utils randomNumberBetween:1000 andMax:99999999]], [NSNumber numberWithInt:currentDifficulty], theDate, theTime];
    [db commit];
            
    [dateFormat release];
    [timeFormat release];
    [now release];
    
    
    //faze 1
    CCMoveTo *rightRotorOut = [CCMoveTo actionWithDuration:0.1 position:ccp(rotorRightMain.position.x + 15, rotorRightMain.position.y)];
    CCMoveTo *leftRotorOut = [CCMoveTo actionWithDuration:0.1 position:ccp(rotorLeftMain.position.x - 15, rotorLeftMain.position.y)];
    CCSequence *rotorRightSeq1 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.2f], rightRotorOut, nil];
    CCSequence *rotorLeftSeq1 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.2f], leftRotorOut, nil];
    
    //faze 2
    CCScaleTo *rightRotorScale = [CCScaleTo actionWithDuration:0.4 scale:1.4];
    CCScaleTo *leftRotorScale = [CCScaleTo actionWithDuration:0.4 scale:1.4];
    CCScaleTo *sphereScale = [CCScaleTo actionWithDuration:0.4 scale:1.4];
    CCMoveTo *sphereMoveBack = [CCMoveTo actionWithDuration:0.4 position:ccp(sphereNode.position.x, sphereNode.position.y + 15)];
    CCScaleTo *lightScale = [CCScaleTo actionWithDuration:0.4 scale:1.4];
    CCMoveTo *lightMoveBack = [CCMoveTo actionWithDuration:0.4 position:ccp(sphereLight.position.x, sphereLight.position.y + 15)];
    CCFadeTo *lightFade = [CCFadeTo actionWithDuration:0.4 opacity:120];
    CCMoveTo *rightRotorToRightAndBack = [CCMoveTo actionWithDuration:0.4 position:ccp(rotorRightMain.position.x + 50, rotorRightMain.position.y - 15)];
    CCMoveTo *leftRotorToLeftAndBack = [CCMoveTo actionWithDuration:0.4 position:ccp(rotorLeftMain.position.x - 50, rotorLeftMain.position.y - 15)];
    CCSpawn *rightRotorSpawn = [CCSpawn actions: rightRotorScale, rightRotorToRightAndBack, nil];
    CCSpawn *leftRotorSpawn = [CCSpawn actions: leftRotorScale, leftRotorToLeftAndBack, nil];
    CCSpawn *sphereSpawn = [CCSpawn actions: sphereScale, sphereMoveBack, nil];
    CCSpawn *lightSpawn = [CCSpawn actions: lightScale, lightMoveBack, lightFade, nil];
    CCSequence *rotorRightSeq2 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.5f], rightRotorSpawn, nil];
    CCSequence *rotorLeftSeq2 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.5f], leftRotorSpawn, nil];
    CCSequence *sphereScaleSeq2 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.5f], sphereSpawn, nil];
    CCSequence *lightSeq2 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.5f], lightSpawn, nil];
    
    //faze 3
    CCScaleTo *rightRotorScale2 = [CCScaleTo actionWithDuration:0.2 scale:1.5];
    CCScaleTo *leftRotorScale2 = [CCScaleTo actionWithDuration:0.2 scale:1.5];
    CCMoveTo *rightRotorToRightAndBack2 = [CCMoveTo actionWithDuration:0.4 position:ccp(rotorRightMain.position.x + 60, rotorRightMain.position.y + 8)];
    CCMoveTo *leftRotorToLeftAndBack2 = [CCMoveTo actionWithDuration:0.4 position:ccp(rotorLeftMain.position.x - 60, rotorLeftMain.position.y + 8)];
    CCScaleTo *sphereScale2 = [CCScaleTo actionWithDuration:0.4 scale:1.5];
    CCMoveTo *sphereMoveBack2 = [CCMoveTo actionWithDuration:0.4 position:ccp(sphereNode.position.x, sphereNode.position.y + 30)];
    CCSpawn *rightRotorSpawn2 = [CCSpawn actions: rightRotorScale2, rightRotorToRightAndBack2, nil];
    CCSpawn *leftRotorSpawn2 = [CCSpawn actions: leftRotorScale2, leftRotorToLeftAndBack2, nil];
    CCSpawn *sphereSpawn2 = [CCSpawn actions: sphereScale2, sphereMoveBack2, nil];
    CCSequence *rotorRightSeq3 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.9f], rightRotorSpawn2, nil];
    CCSequence *rotorLeftSeq3 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.9f], leftRotorSpawn2, nil];
    CCSequence *sphereScaleSeq3 = [CCSequence actions:[CCDelayTime actionWithDuration: 0.9f], sphereSpawn2, nil];
    CCMoveTo *krytkaBack = [CCMoveTo actionWithDuration:0.8 position:ccp(krytka.position.x, krytka.position.y + 60)];
    CCSequence *krytkaSeq = [CCSequence actions:[CCDelayTime actionWithDuration: 0.9f], krytkaBack, nil];
    
    CCSequence *moveSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(movableNode.position.x, movableNode.position.y - 47)],
                           nil];
    CCSequence *codeSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(codeBase.position.x, codeBase.position.y - 47)],
                           nil];
    CCSequence *figSeq = [CCSequence actions:
                           [CCDelayTime actionWithDuration: 1.3f],
                           [CCMoveTo actionWithDuration:.4 position:CGPointMake(figuresNode.position.x, figuresNode.position.y - 49)],
                           nil];
    CCSequence *baseSeq = [CCSequence actions:
                          [CCDelayTime actionWithDuration: 1.3f],
                          [CCMoveTo actionWithDuration:.4 position:CGPointMake(base.position.x, base.position.y - 49)],
                          nil];
    
    
    [rotorRightMain runAction:rotorRightSeq1];
    [rotorLeftMain runAction:rotorLeftSeq1];
    [rotorRightMain runAction:rotorRightSeq2];
    [rotorLeftMain runAction:rotorLeftSeq2];
    [sphereNode runAction:sphereScaleSeq2];
    [sphereLight runAction:lightSeq2];
    [rotorRightMain runAction:rotorRightSeq3];
    [rotorLeftMain runAction:rotorLeftSeq3];
    [sphereNode runAction:sphereScaleSeq3];
    [krytka runAction:krytkaSeq];
    [movableNode runAction:moveSeq];
    [codeBase runAction:codeSeq];
    [figuresNode runAction:figSeq];
    [base runAction:baseSeq];
}

- (void) didEndOfRow {
    CCLOG(@"Logic debug: END ROW");
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
    //if (places == currentDifficulty || activeRow == 9) {
    if (places == currentDifficulty || activeRow == 9) {
        [self endGame];
    } else {
        [self nextRow];
    }
}

- (void) generateDeadRow {
    for (Figure *userSprite in userCode) {
        Figure *deadFigure = [[Figure alloc] initWithFigureType:userSprite.currentFigure];
        //deadFigure.place = userSprite.place;
        deadFigure.isActive = NO;//neni treba? neni v movable figures
        CGPoint newPos = ccp(userSprite.position.x, userSprite.position.y + dislocation);
        deadFigure.position = newPos;
        [movableNode addChild:deadFigure z:2000];//mrknout na z-index
        [movableFigures removeObject:userSprite];
        [userSprite destroy];
    }
}

- (void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
    //CCLOG(@"Logic debug: Touch end");
    if (selSprite) {
        //[movableFigures removeObject:selSprite];
        //[selSprite destroy];
        CCScaleTo *scale = [CCScaleTo actionWithDuration:.5 scale:1.0];
        [selSprite runAction:scale];
        
        if (targetSprite != nil) {//animation to target
            //CCLOG(@"sprite selSprite je %@", selSprite);
            CCSequence *moveSeq;
            if (selSprite.isOnActiveRow) {
                [self swapFigure:selSprite];
                moveSeq = [CCSequence actions:
                           [CCMoveTo actionWithDuration:.03*activeRow position:CGPointMake(targetSprite.position.x + 1, targetSprite.position.y + 5 - dislocation)],
                           [CCCallFuncND actionWithTarget:self selector:@selector(figureSetCorrectPosition:data:) data:selSprite],
                           nil];
            } else {
                moveSeq = [CCSequence actions:
                          [CCMoveTo actionWithDuration:.03*activeRow position:CGPointMake(targetSprite.position.x + 1, targetSprite.position.y + 5 - dislocation)],
                          [CCCallFuncND actionWithTarget:self selector:@selector(figureMoveEnded:data:) data:selSprite],//najit v zalozkach modernejsi zpusob jak volat callback
                          nil];
            }
            [selSprite runAction:moveSeq];
            //????release action?
        } else {//animation back to base
            CCMoveTo *moveBack = [CCMoveTo actionWithDuration:.3 position:CGPointMake(selSprite.originalPosition.x, selSprite.originalPosition.y)];
            [selSprite runAction:moveBack];
            [figuresNode reorderChild:selSprite z:selSprite.zOrder - 100];
        }
        targetSprite = nil;
    } else {
        touchStop = [touch locationInView:[touch view]];
        touchStop = [[CCDirector sharedDirector] convertToGL:touchStop];
        
        float deltaX = touchStop.x - touchOrigin.x;
        float deltaY = touchStop.y - touchOrigin.y;
        
        if (fabs(deltaX) > MIN_DISTANCE_SWIPE_X && isEndRow) {
            isEndRow = NO;
            [self generateDeadRow];
            [self didEndOfRow];
        }
        
        if (fabs(deltaY) > MIN_DISTANCE_SWIPE_Y && isMovable) {
            if(deltaY < 0 && movableFlag)//down
                [self swipeArea:1];
            else if (deltaY > 0 && !movableFlag)
                [self swipeArea:-1];
        }
    }
}

- (void) dealloc {
    CCLOG(@"Logic debug: DEALLOC GAME LAYER %@", self);
    [rotorLeftMain release];
    [rotorRightMain release];
    [orangeLights release];
    orangeLights = nil;
    [greenLights release];
    greenLights = nil;
    [userCode release];
    userCode = nil;
    [movableFigures release];
    movableFigures = nil;
    [currentCode release];
    currentCode = nil;
    [targets release];
    targets = nil;
    [super dealloc];
}

@end