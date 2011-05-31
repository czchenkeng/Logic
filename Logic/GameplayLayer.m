//
//  GameplayLayer.m
//  Logic
//
//  Created by Pavel Krusek on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameplayLayer.h"


@implementation GameplayLayer

//@synthesize currentDifficulty;


- (void) createBackground {
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelBgHd.plist"];
    
    CCSprite *background;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //background = [CCSprite spriteWithSpriteFrameName:@"6Lines.png"];
    } else {
        background = [CCSprite spriteWithSpriteFrameName:@"6Lines.png"];
    }

    background.anchorPoint = CGPointMake(0, 0);
    [self addChild:background z:-10];
}

- (void) generateCode {
    NSString *imageFile;
    //float *p_pinchXpos[4];
    float pinchXpos[6] = {37.55, 75.55, 114.55, 151.55, 189.55, 227.55};
    //vnorit do sprite a bude mit stejny pocatek?
    
    switch (currentDifficulty) {
        case kEasy:     
            imageFile = @"logik_levelend_4line.png";
            //float easyXpos[4] = {0, 0, 0, 0};
            //p_pinchXpos = &easyXpos;
            break;
        case kMedium:
            imageFile = @"logik_levelend_5line.png";
            break;
        case kHard:
            imageFile = @"logik_levelend_6line.png";
            break;
        default:
            CCLOG(@"Unknown ID, cannot create image");
            return;
            break;
    }
    
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPinchHd.plist"];
    
    CCSprite *baseTop = [CCSprite spriteWithSpriteFrameName:imageFile];
    baseTop.position = ccp(133, 460);
    [self addChild:baseTop z:1];
    
    [imageFile release];
    
    currentCode = [[CCArray alloc] init]; 
    for (int i = 0; i < currentDifficulty; ++i) {
        Figure *figure = [[Figure alloc] initWithFigureType:[Utils randomNumberBetween:0 andMax:7]];
        figure.position = ccp(pinchXpos[i], 450.00f);
        [self addChild:figure z:i+1000];
        [currentCode addObject:figure];
    }
}

- (void) createRotor {
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPinchHd.plist"];
    
    CCSprite *rotors = [CCSprite spriteWithSpriteFrameName:@"rotors.png"];
    rotors.position = ccp(160, 430);
    [self addChild:rotors z:2000];
    
    CCSprite *sphere = [CCSprite spriteWithSpriteFrameName:@"sphere.png"];
    sphere.position = ccp(152, 454);
    [self addChild:sphere z:2001];
}

//- (void) 

- (void) createLevel {
    CCLOG(@"CREATE LEVEL");
    [self createBackground];
    //[self generateCode];
    [self createRotor];
}

- (id) init {
    self = [super init];
    if (self != nil) {
        activeRow = 0;
        currentDifficulty = [[GameManager sharedGameManager] currentDifficulty];
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        [self createLevel];
        [self addFigures];
        [self constructRowWithIndex:2];
    }
    return self;
}


- (void) constructRowWithIndex:(int)row {
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPinchHd.plist"];
    for (int i = 0; i < 6; ++i) {
        CCSprite *debugPoint = [CCSprite spriteWithSpriteFrameName:@"debug_center.png"];
        debugPoint.position = ccp(32.0 + i*40, 81.0 + row*44); 
        [self addChild:debugPoint z:2001 + i]; 
    }
}


- (void) addFigures {
    CCLOG(@"ADD FIGURES");
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    
//    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
//    movableFigures = [[CCArray alloc] init];
//    
//    spritesBgNode = [CCSpriteBatchNode batchNodeWithFile:@"gameAssets.pvr.ccz"];
//    [self addChild:spritesBgNode];
//    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gameAssets.plist"];
//    
//    NSArray *images = [NSArray arrayWithObjects:@"figure1.png", @"figure2.png", @"figure3.png", @"figure4.png", @"figure5.png", @"figure6.png", @"figure7.png", @"figure8.png", nil];
//    CCLOG(@"count %i", images.count);
//    for (int i = 0; i < images.count; ++i) {
//        NSString *image = [images objectAtIndex:i];
//        float offsetFraction = ((float)(i+1))/(images.count+1); 
//        CCLOG(@"image %@", image);
//        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:image];
//        sprite.position = ccp(winSize.width*offsetFraction, winSize.height/2);
//        [spritesBgNode addChild:sprite z:i];
//        //default je 0?
//        [movableFigures addObject:sprite];
//    }
    
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPinchHd.plist"];
    CCSprite *base = [CCSprite spriteWithSpriteFrameName:@"pinchBase.png"];
    base.anchorPoint = CGPointMake(0, 0);
    [self addChild:base];
    
    movableFigures = [[CCArray alloc] init];
    
//    CCSprite *figuresHolder = [CCSprite node];
//    [self addChild:figuresHolder];
//    figuresHolder.position = ccp(50.0f, 420.0f);
    
    float pinchXpos[8] = {27.55, 66.11, 104.66, 143.22, 180.77, 218.33, 256.88, 294.44};
    
    for (int i = 0; i < 8; ++i) {
        
        //float offsetFraction = ((float)(i+1))/9;
        //CCLOG(@"xpos %f", pinchXpos[i]);
        Figure *figure = [[Figure alloc] initWithFigureType:i];
        //figure.position = ccp(10 + winSize.width*offsetFraction, 33.0f);
        figure.position = ccp(pinchXpos[i], 32.0f);
        figure.originalPosition = ccp(figure.position.x, figure.position.y);
        [self addChild:figure z:i];
        //[self addChild:figure];
        //default z je 0? je, protoze sel z textury - coocs umisti na 0 z index
        [movableFigures addObject:figure];
    }
    
}

- (void) selectSpriteForTouch:(CGPoint)touchLocation {
    //CCSprite * newSprite = nil;
    Figure *newSprite = nil;
//    for (CCSprite *sprite in movableFigures) {
//        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {            
//            newSprite = sprite;
//            break;
//        }
//    }
    for (Figure *sprite in movableFigures) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {            
            newSprite = sprite;
            break;
        }
    }
   // newSprite = [movableFigures randomObject];
   // CCLOG(@"width of figure %@", NSStringFromCGRect(newSprite.boundingBox));
    if (newSprite != selSprite) {
//        [selSprite stopAllActions];
//        [selSprite runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
//        CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-4.0];
//        CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
//        CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:4.0];
//        CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
//        [newSprite runAction:[CCRepeatForever actionWithAction:rotSeq]];            
        if (selSprite) {
            [self reorderChild:selSprite z:selSprite.zOrder - 100];
        }
        selSprite = newSprite;
        CCLOG(@"z order of sprite before %i", selSprite.zOrder);
        if (selSprite) {
            [self reorderChild:selSprite z:selSprite.zOrder + 100];
            CCLOG(@"z order of sprite %i", selSprite.zOrder);
            CCLOG(@"ID of Pinch %i", selSprite.currentFigure);
        }
    }
    
}

- (void) panForTranslation:(CGPoint)translation {    
    CCLOG(@"Sel Sprite %@", selSprite);
    if (selSprite) {
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        selSprite.position = newPos;
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
    //CCLOG(@"Translation %f %f", translation.x, translation.y);
    [self panForTranslation:translation];    
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];
    //CCLOG(@"Touch began %f %f", touchLocation.x, touchLocation.y);
    CCLOG(@"Touch began %@", NSStringFromCGPoint(touchLocation));
    //return TRUE;
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"Touch end");
    //CCLOG(@"Sel Sprite %@", selSprite);
    CCLOG(@"ID of sprite %i", selSprite.currentFigure);
    CCLOG(@"x pos sprite %f", selSprite.position.x);
    CCLOG(@"y pos sprite %f", selSprite.position.y);
    if (selSprite) {
        Figure *figure = [[Figure alloc] initWithFigureType:selSprite.currentFigure];
        figure.position = selSprite.originalPosition;
        figure.originalPosition = ccp(selSprite.originalPosition.x, selSprite.originalPosition.y);
        [self addChild:figure z:1000];
        [movableFigures addObject:figure];
    }       
}

- (void) dealloc {
    [movableFigures release];
    movableFigures = nil;
    [currentCode release];
    currentCode = nil;
    [super dealloc];
}

@end