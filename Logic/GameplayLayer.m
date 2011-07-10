//
//  GameplayLayer.m
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameplayLayer.h"


@implementation GameplayLayer


- (void) pauseTapped:(CCMenuItem *)sender { 
    //CCLOG(@"Logic debug: Pause");
    [self endGame];
}

#pragma mark Build level 
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
    deadFiguresNode = [CCLayer node];
    scoreLayer = [CCLayer node];
    Mask *deadFiguresNodeMask = [Mask maskWithRect:CGRectMake(0, LEVEL_DEAD_FIGURES_MASK_HEIGHT, 320, 480 - LEVEL_DEAD_FIGURES_MASK_HEIGHT)];
    
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
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Hq.plist"];
    sphereLight = [CCSprite spriteWithSpriteFrameName:@"lightSphere.png"];
    sphereLight.opacity = 155;
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    
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
    
    base = [CCSprite spriteWithSpriteFrameName:@"pinchBase.png"];
    base.anchorPoint = CGPointMake(0, 0);
    
    scoreTime = [CCLayer node];
    CCSprite *scoreTimeSprite = [CCSprite spriteWithSpriteFrameName:@"logik_score_time.png"];
    scoreTimeSprite.anchorPoint = CGPointMake(0.5, 1);
    
    //nodes position
    codeBase.position = ccp(133, 455);
    
    
    rotorRightMain.position = ccp(259.00, 434.00);
    rotorLeftMain.position = ccp(54.00, 430.00);
    sphereNode.position = ccp(152, 474);
    
    sphereLight.position = ccp(150.00, 411.00);
    krytka.position = ccp(160.00, 456.00);
    
    scoreTimeSprite.position = ccp(160.00, 480.50);
    
    Mask *timerMask = [Mask maskWithRect:CGRectMake(279, 456.00, 39.5, 18)];
    [scoreTime addChild:timerMask z:4];
    timer = [[ProgressTimer alloc] init];
    [timerMask addChild:timer z:1];
    //[self addChild:timer z:10001];
    //[timer setPosition:ccp(200, 200)];
    
    CCSprite *scoreBlackBg = [CCSprite spriteWithSpriteFrameName:@"score_black_bg.png"];
    scoreBlackBg.position = ccp(36.00, 466.50);
    CCSprite *timeBlackBg = [CCSprite spriteWithSpriteFrameName:@"time_black_bg.png"];
    timeBlackBg.position = ccp(300.50, 466.00);
    
    [scoreTime addChild:scoreTimeSprite z:5];
    [scoreTime addChild:scoreBlackBg z:1];
    [scoreTime addChild:timeBlackBg z:2];

    
    //add nodes to display list
    [self addChild:movableNode z:2 tag:2];
    //Mask *test = [Mask maskWithRect:CGRectMake(0, 150, 320, 150)];
    //[movableNode addChild:test z:-1 tag:-1];
    //[test addChild:bg];
    [movableNode addChild:bg z:-1 tag:-1];  
    [movableNode addChild:deadFiguresNodeMask z:1];
    [deadFiguresNodeMask addChild:deadFiguresNode];
    [self addChild:codeBase z:3 tag:3];
    [self addChild:clippingNode z:4 tag:1];
    [self addChild:krytka z:5];
    [self addChild:base z:6 tag:11];
    [self addChild:figuresNode z:7];
    [self addChild:sphereLight z:8];
    [self addChild:rotorLeftMain z:9];
    [self addChild:rotorRightMain z:10];
    [self addChild:sphereNode z:11 tag:9];
    [scoreTime addChild:scoreLayer z:3];
    [self addChild:scoreTime z:13];

    
    CCSprite *buttonPauseOff = [CCSprite spriteWithSpriteFrameName:@"logik_pauza_01.png"];
    CCSprite *buttonPauseOn = [CCSprite spriteWithSpriteFrameName:@"logik_pauza_02.png"];
    
    CCMenuItem *pauseItem = [CCMenuItemSprite itemFromNormalSprite:buttonPauseOff selectedSprite:buttonPauseOn target:self selector:@selector(pauseTapped:)];
    pauseItem.tag = kButtonPause;
    pauseItem.anchorPoint = CGPointMake(0.5, 1);
    pauseItem.position = ccp(152.00, 481.00);
    
    CCMenu *pauseMenu = [CCMenu menuWithItems:pauseItem, nil];
    pauseMenu.position = CGPointZero;
    [self addChild:pauseMenu z:20];
    
    
    
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
    
    //CCTimer *alphaTimer = [[CCTimer alloc] initWithTarget:self selector:@selector(alphaShadows:) interval:0.1f];
    //CCTimer *alphaTimer = [CCTimer timerWithTarget:self selector:@selector(alphaShadows:) interval:0.1f]; 
    [self schedule:@selector(alphaShadows:) interval:0.1];
    
    
    dustSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"dust.plist"];
    [self addChild:dustSystem z:1000];
    

    //release memory
    [hw release];
    [bgFrame release];
    [levelEndFrame release];
//    [morphingSphereFrames release];
//    morphingSphereFrames = nil;
}

#pragma mark Callback methods sphere & shadows
/* callback sphere animation */
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

/* timer for rotor blue shadows */
- (void) alphaShadows:(ccTime)dt {
    int ranAlpha = [Utils randomNumberBetween:50 andMax:155];
    rotorLeftLight.opacity = ranAlpha;
    rotorRightLight.opacity = ranAlpha;
    sphereLight.opacity = ranAlpha;
}

#pragma mark Generate game code 
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
        //[cheat addChild:cheatFigure z:i];
        [currentCode addObject:figure];
        //CCLOG(@"retain is %d", [figure retainCount]);
    }
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

#pragma mark Targets for figures
- (void) generateTargets {
    targets = [[CCArray alloc] init];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Level.plist"];
    for (int i = 0; i < currentDifficulty; ++i) {
        CCSprite *targetPoint = [CCSprite spriteWithSpriteFrameName:@"debug_center.png"];
        targetPoint.opacity = 255;
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

#pragma mark Composite method for starting level
- (void) createLevel {
    [self prepareAssets];
    [self generateCode];
    [self addFigures];
    [self generateTargets];
    [self constructRowWithIndex:activeRow];
    [self constructScoreLabel];
}

#pragma mark Init
- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        lastTime = 0;
        score = 0;
        currAreaPos = 0;
        dislocation = 0.0;
        activeRow = 0;
        lastPlace = -1;
        currentDifficulty = [[GameManager sharedGameManager] currentDifficulty];
        targetSprite = nil;
        isEndRow = NO;
        isMovable = NO;
        userCode = [[NSMutableArray alloc] init];
        placeNumbers = [[CCArray alloc] init];
        colorNumbers = [[CCArray alloc] init];
        deadFigures = [[CCArray alloc] init];
        touchArray = [[NSMutableArray alloc] init];
        scoreLabelArray = [[CCArray alloc] init];
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
    if (selSprite) {
        //selSprite.endTime = [NSDate date];
        //CCLOG(@"TIME %i", selSprite.endTime.  - selSprite.startTime);
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        if (newPos.y < LEVEL_FIGURE_MAX_Y_MOVE)
            selSprite.position = newPos;
    }  
}

#pragma mark Detect target
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
#pragma mark Touches
- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {       
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    
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

}

- (void) swipeArea:(int)direction {
    dir = direction;
    dir > 0 ? currAreaPos++ : currAreaPos--;
    //dislocation = LEVEL_DISLOCATION * currAreaPos;
    CCLOG(@"dislocation %f", dislocation);
    CCLOG(@"area position %i", currAreaPos);
    CCSequence *moveSeq = [CCSequence actions:
                   [CCMoveTo actionWithDuration:.3 position:CGPointMake(movableNode.position.x, movableNode.position.y - dislocation * direction)],
                   [CCCallFunc actionWithTarget:self selector:@selector(swipeEnd)],
                   nil];
    CCSequence *moveNumbersSeq = [CCSequence actions:
                           [CCMoveTo actionWithDuration:.3 position:CGPointMake(clippingNode.position.x, clippingNode.position.y - dislocation * direction)],
                           nil];
//    CCSpawn *moveSpawn = [CCSpawn actions: [CCMoveTo actionWithDuration:.3 position:CGPointMake(movableNode.position.x, movableNode.position.y - dislocation * direction)],
//                          [CCMoveTo actionWithDuration:.3 position:CGPointMake(clippingNode.position.x, clippingNode.position.y - dislocation * direction)],
//                          nil];
    [movableNode runAction:moveSeq];
    [clippingNode runAction:moveNumbersSeq];
    //movableFlag = !movableFlag;
}

- (void) nextRow {
    [userCode removeAllObjects];
    activeRow ++;
    [self constructRowWithIndex:activeRow];
    if (currAreaPos == 1) {
        [self swipeArea:1];
    }
    if (activeRow == LEVEL_SWIPE_AFTER_ROW) {
        isMovable = YES;
        //movableFlag = YES;
        dislocation = LEVEL_DISLOCATION;
        //currAreaPos ++;
        [self swipeArea:1];
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
    Mask *holderPlace = [Mask maskWithRect:CGRectMake(greenLight.position.x - 3, greenLight.position.y + 8 - dislocation, 9, 18)];
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
    Mask *holderColors = [Mask maskWithRect:CGRectMake(orangeLight.position.x - 5, orangeLight.position.y + 8 - dislocation, 9, 18)];
    [clippingNode addChild:holderColors z:21 + activeRow];
    RowScore *rc = [[RowScore alloc] init];
    [holderColors addChild:rc z:1];
    [rc moveToPosition:colors andMask:holderColors];
}

- (void) fbTapped:(CCMenuItem *)sender { 
    switch (sender.tag) {
        case kButtonFb: 
            CCLOG(@"TAP ON FB");
            [sender removeFromParentAndCleanup:YES];
            
            CGRect frame = CGRectMake(40, 100, 240, 180);
            FacebookViewController *controller = [[GameManager sharedGameManager] facebookController:frame];
            
//            UIView *tableContainer = [[UIView alloc] initWithFrame:frame];
//            [tableContainer addSubview:controller.view];
            
            CCUIViewWrapper *fbWrapper = [CCUIViewWrapper wrapperForUIView:controller.view];
            [self addChild:fbWrapper z:120];
            
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

- (void) endGame {
    CCLOG(@"Logic debug: END GAME");
    
    [[[GameManager sharedGameManager] gameData] writeScore:[Utils randomNumberBetween:1000 andMax:99999999] andDifficulty:currentDifficulty];
    
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
    
    
    //temporary end screen
    CCSprite *buttonFbOff = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb1.png"];
    CCSprite *buttonFbOn = [CCSprite spriteWithSpriteFrameName:@"logik_iconfcb2.png"];
    
    CCMenuItem *fbItem = [CCMenuItemSprite itemFromNormalSprite:buttonFbOff selectedSprite:buttonFbOn target:self selector:@selector(fbTapped:)];
    fbItem.tag = kButtonFb;
    fbItem.position = ccp(100.00, 300.00);
    
    CCMenu *finalMenu = [CCMenu menuWithItems:fbItem, nil];
    finalMenu.position = CGPointZero;
    //[self addChild:finalMenu z:20];
    
    //end temp screen
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

- (void) calculateScore {
    lastTime = timer.gameTime - lastTime;
    //CCLOG(@"ACTIVE ROW %i", activeRow + 1);
    //CCLOG(@"GAME TIME %i", lastTime);
    float sc = 264000 * ( (10 / (activeRow + 1)) + ( 25 / lastTime ) - 1 );
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


- (void) didEndOfRow {
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

- (void) generateDeadRow {
    for (Figure *userSprite in userCode) {
        Figure *deadFigure = [[Figure alloc] initWithFigureType:userSprite.currentFigure];
        //deadFigure.place = userSprite.place;
        deadFigure.isActive = NO;//neni treba? neni v movable figures
        CGPoint newPos = ccp(userSprite.position.x, userSprite.position.y + dislocation - LEVEL_DEAD_FIGURES_MASK_HEIGHT);
        deadFigure.position = newPos;
        //[movableNode addChild:deadFigure z:2000];//mrknout na z-index
        [deadFiguresNode addChild:deadFigure z:2000];//mrknout na z-index
        [movableFigures removeObject:userSprite];
        [userSprite destroy];
        //deadFigure; dFigure;
        
        //[[[GameManager sharedGameManager] gameData] insertDeadFigure:
    }
}

- (void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
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
            //if(deltaY < 0 && movableFlag)//down
            if(deltaY < 0 && currAreaPos < 2)//down    
                [self swipeArea:1];
            //else if (deltaY > 0 && !movableFlag)
            else if (deltaY > 0 && currAreaPos > 0)
                [self swipeArea:-1];
        }
    }
}

- (void) dealloc {
    CCLOG(@"Logic debug: DEALLOC GAME LAYER %@", self);
    [scoreLabelArray release];
    scoreLabelArray = nil;
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