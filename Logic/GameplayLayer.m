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
            break;
        case kMedium:
            bgFrame = @"5Lines.png";
            levelEndFrame = @"logik_levelend_5line.png";
            break;
        case kHard:
            bgFrame = @"6Lines.png";
            levelEndFrame = @"logik_levelend_6line.png";
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
    
    rotor = [CCSprite spriteWithSpriteFrameName:@"rotors.png"];
    
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
    
    CCSprite *base = [CCSprite spriteWithSpriteFrameName:@"pinchBase.png"];
    base.anchorPoint = CGPointMake(0, 0);
    
    //nodes position
    codeBase.position = ccp(133, 455);
    //rotor.position = ccp(160, 430);
    //sphereNode.position = ccp(152, 474);
    rotor.position = ccp(160, 412);
    sphereNode.position = ccp(152, 456);

    
    //add nodes to display list
    [self addChild:clippingNode z:1 tag:1];
    [self addChild:movableNode z:2 tag:2];
    //Mask *test = [Mask maskWithRect:CGRectMake(0, 150, 320, 150)];
    //[movableNode addChild:test z:-1 tag:-1];
    //[test addChild:bg];
    [movableNode addChild:bg z:-1 tag:-1];
    //bg.opacity = 80;
    
    [self addChild:codeBase z:3 tag:3];
    //[self addChild:rotor z:4 tag:4];
    //[self addChild:sphereNode z:5 tag:5];
    [self addChild:base z:6 tag:6];
    [self addChild:figuresNode z:7];
    
    
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
        Figure *figure = [[Figure alloc] initWithFigureType:[Utils randomNumberBetween:0 andMax:8]];
        figure.place = i;
        figure.anchorPoint = CGPointMake(0, 0);
        figure.position = ccp(8 + 40*i, 10.0f);
        CCLOG(@"retain before is %d", [figure retainCount]);
        [codeBase addChild:figure z:i];
        [currentCode addObject:figure];
        //[figure destroy];
        CCLOG(@"retain is %d", [figure retainCount]);
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
        sprite.position = ccp(32.0 + i*40, 81.0 + row*44);
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

- (id) init {
    self = [super initWithColor:ccc4(0,0,0,0)];
    if (self != nil) {
        dislocation = 0.0;
        activeRow = 0;
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
    [selSprite stopAllActions];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:.2 scale:1.3];
    [newSprite runAction:scale];          
//        if (selSprite) {
//            [figuresNode reorderChild:selSprite z:selSprite.zOrder - 100];
//        }
    selSprite = newSprite;
    if (selSprite) {
        [figuresNode reorderChild:selSprite z:selSprite.zOrder + 100];
    }   
}

- (void) panForTranslation:(CGPoint)translation {    
    //CCLOG(@"Sel Sprite %@", selSprite);
    if (selSprite) {
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        selSprite.position = newPos;
    }  
}

- (void) activateTargetWithTarget:(CCSprite *)sprite andPlace:(int)place {
    if (targetSprite != sprite) {
        CCLOG(@"Logic debug: Target sprite %@", sprite);
        targetSprite = sprite;
        highlightSprite.visible = YES;
        highlightSprite.position = ccp(targetSprite.position.x, targetSprite.position.y);
        selSprite.place = place;
        //currentPlace = place;
    }
}

- (void) detectTarget {
    if (selSprite) {
        int i = 0;
        for (CCSprite *sprite in targets) {
            CGRect rect = CGRectMake(sprite.position.x, sprite.position.y, sprite.boundingBox.size.width, -(sprite.position.y - 80));
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
- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event  {       
    UITouch *touch = [touches anyObject];
    CGPoint new_location = [touch locationInView: [touch view]];
    new_location = [[CCDirector sharedDirector] convertToGL:new_location];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];

    [touchArray addObject:NSStringFromCGPoint(new_location)];
    [touchArray addObject:NSStringFromCGPoint(oldTouchLocation)];
    CCLOG(@"touches moved");
}


- (void) draw {
    glEnable(GL_LINE_SMOOTH);
    
    for(int i = 0; i < [touchArray count]; i+=2) {
        CGPoint start = CGPointFromString([touchArray objectAtIndex:i]);
        CGPoint end = CGPointFromString([touchArray objectAtIndex:i+1]);
        
        ccDrawLine(start, end);
        CCLOG(@"paint %@", NSStringFromCGPoint(start));
    }
}

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
    CCLOG(@"Logic debug: END ACTION! %@", sprite);
    
    //new figure to base
    Figure *figure = [[Figure alloc] initWithFigureType:sprite.currentFigure];
    figure.position = sprite.originalPosition;
    figure.position = ccp(sprite.originalPosition.x, sprite.originalPosition.y - 40);
    figure.originalPosition = ccp(sprite.originalPosition.x, sprite.originalPosition.y);
    [figuresNode addChild:figure z:1000];
    [movableFigures addObject:figure];
    CCMoveTo *moveToBase = [CCMoveTo actionWithDuration:.2 position:CGPointMake(figure.position.x, figure.originalPosition.y)];
    [figure runAction:moveToBase];
    
    highlightSprite.visible = NO; 
    Figure *deadFigure = [[Figure alloc] initWithFigureType:sprite.currentFigure];//convenient init, tj. prenest alloc do Figure?
    deadFigure.place = sprite.place;
    deadFigure.isActive = NO;
    CGPoint newPos = ccp(sprite.position.x, sprite.position.y + dislocation);
    deadFigure.position = newPos;
    [movableNode addChild:deadFigure z:2000];
    [movableFigures removeObject:sprite];
    Figure *tempSprite = nil;
    for (Figure *userSprite in userCode) {
        if (userSprite.place == sprite.place) {
            tempSprite = userSprite;
        }
    }
    if (tempSprite) {
        [userCode removeObject:tempSprite];
        [tempSprite destroy];
    }
    [sprite destroy];
    [userCode addObject:deadFigure];
    
    if (userCode.count == currentDifficulty) {
        isEndRow = YES;
    }
}

- (void) swipeArea:(int)direction {
    CCMoveTo *move = [CCMoveTo actionWithDuration:.3 position:CGPointMake(movableNode.position.x, movableNode.position.y - dislocation * direction)];
    [movableNode runAction:move];
    for (Mask *mask in placeNumbers) {
        [mask redrawRect:CGRectMake(mask.position.x, mask.position.y - dislocation * direction, 12, 18)];
    }
    for (Mask *mask in colorNumbers) {
        [mask redrawRect:CGRectMake(mask.position.x, mask.position.y - dislocation * direction, 12, 18)];
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
        [holderPlace addChild:rs];
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
        [holderColors addChild:rc];
        [rc moveToPosition:colors];
    }
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
                    userSprite.isCalculated = YES;
                }
            }
        }
        i++;
    }
    
    for (Figure *codeSprite in currentCode) {
        for (Figure *userSprite in userCode) {
            if (userSprite.currentFigure == codeSprite.currentFigure && !userSprite.isCalculated) {
                colors++;
                userSprite.isCalculated = YES;
                break;
            }
        }
    }
    
    CCLOG(@"Logic debug: PLACES %i AND COLORS %i", places, colors);
    [self showResult];
    if (places == currentDifficulty || activeRow == 9) {
        CCLOG(@"Logic debug: END GAME");
    } else {
        [self nextRow];
    }
}

- (void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
    CCLOG(@"Logic debug: Touch end");
    if (selSprite) {
        //[movableFigures removeObject:selSprite];
        //[selSprite destroy];
        CCScaleTo *scale = [CCScaleTo actionWithDuration:.5 scale:1.0];
        [selSprite runAction:scale];
        
        if (targetSprite != nil) {//animation to target
            CCLOG(@"sprite selSprite je %@", selSprite);
            CCSequence *moveSeq = [CCSequence actions:
                                   [CCMoveTo actionWithDuration:.03*activeRow position:CGPointMake(targetSprite.position.x + 1, targetSprite.position.y + 5 - dislocation)],
                                   [CCCallFuncND actionWithTarget:self selector:@selector(figureMoveEnded:data:) data:selSprite],//najit v zalozkach modernejsi zpusob jak volat callback
                                   nil];
            [selSprite runAction:moveSeq];
            //????release action?
        } else {//animation back to base
            CCMoveTo *moveBack = [CCMoveTo actionWithDuration:.3 position:CGPointMake(selSprite.originalPosition.x, selSprite.originalPosition.y)];
            [selSprite runAction:moveBack];
        }
        targetSprite = nil;
    } else {
        touchStop = [touch locationInView:[touch view]];
        touchStop = [[CCDirector sharedDirector] convertToGL:touchStop];
        
        float deltaX = touchStop.x - touchOrigin.x;
        float deltaY = touchStop.y - touchOrigin.y;
        
        if (fabs(deltaX) > MIN_DISTANCE_SWIPE_X && isEndRow) {
            isEndRow = NO;
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