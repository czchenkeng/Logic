//
//  CareerLayer.m
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CareerLayer.h"

static const float MIN_SCALE = 0.5;
static const float MAX_SCALE = 2.0;

@implementation CareerLayer

- (void) buttonTapped:(CCMenuItem *)sender { 
    switch (sender.tag) {
        case kButtonBack:
            CCLOG(@"TAP ON BACK");
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kSlideInL];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

#pragma mark -
#pragma mark Enter & Exit
- (void) onEnter {
    panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)] autorelease];
    pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)] autorelease];
    
    singleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)] autorelease];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    
    doubleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleDoubleTapFrom:)] autorelease];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    
    //[singleTapGestureRecognizer requireGestureRecognizerToFail: doubleTapGestureRecognizer];
    
//    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTapGestureRecognizer];
//    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:doubleTapGestureRecognizer];
//    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panGestureRecognizer];
//    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pinchGestureRecognizer];
    
    [super onEnter];
}

- (void) onExit {
//    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:singleTapGestureRecognizer];
//    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:doubleTapGestureRecognizer];
//    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:panGestureRecognizer];
//    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pinchGestureRecognizer];
    [super onExit];
}

- (void) buttonFake:(CCMenuItem *)sender {
    CCLOG(@"test tap %i", sender.tag);
}


- (id) init {
    self = [super init];
    if (self != nil) {
        buttonsArray = [[CCArray alloc] init];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Career.plist"];
        
        zoomBase = [CCColorLayer layerWithColor:ccc4(0,0,0,0)];
		zoomBase.position = ccp(0, 0);
		[self addChild:zoomBase z:1];
        
        zbLastPos = zoomBase.position;
        
        background = [CCSprite spriteWithSpriteFrameName:@"logik_levels.png"];
        //background.position = ccp(96.00, 282.00);
        background.position = ccp(150.00, 180.00);
        [zoomBase addChild:background z:1];
        
        CCSprite *button;
//        float buttX[24] = {330, 288.50, 0, 0, 330,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0};
//        float buttY[24] = {483, 258, 0, 0, 483,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0};
        float buttX[24] = {230, 288.50, 0, 0, 230,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0};
        float buttY[24] = {383, 258, 0, 0, 383,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0};
        for (int i = 0; i < 24; i++) {
            button = [CCSprite spriteWithSpriteFrameName:@"button.png"];
            button.anchorPoint = ccp(0, 0);
            //[background addChild:button z:100];
            button.position = ccp(buttX[i], buttY[i]);
            [buttonsArray addObject:button];
            CCLOG(@"rect %@", NSStringFromCGRect(button.boundingBox));
        }
        
        CCMenuItem *firstItem = [CCMenuItemSprite itemFromNormalSprite:[buttonsArray objectAtIndex:0] selectedSprite:[buttonsArray objectAtIndex:4] target:self selector:@selector(buttonFake:)];
        firstItem.tag = 0;

        CCMenu *fakeMenu = [CCMenu menuWithItems:firstItem, nil];
        fakeMenu.position = CGPointZero;
        [self addChild:fakeMenu z:30];

        
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"shadow.png"];
        sprite.anchorPoint = ccp(0.00, 0.00);
        [self addChild:sprite z:2];
        
        CCSprite *buttonBackOff = [CCSprite spriteWithSpriteFrameName:@"back_off.png"];
        CCSprite *buttonBackOn = [CCSprite spriteWithSpriteFrameName:@"back_on.png"];
        CCSprite *buttonInfoOff = [CCSprite spriteWithSpriteFrameName:@"i_off.png"];
        CCSprite *buttonInfoOn = [CCSprite spriteWithSpriteFrameName:@"i_on.png"];
        
        CCMenuItem *backItem = [CCMenuItemSprite itemFromNormalSprite:buttonBackOff selectedSprite:buttonBackOn target:self selector:@selector(buttonTapped:)];
        backItem.tag = kButtonBack;
        backItem.anchorPoint = CGPointMake(0.5, 1);
        backItem.position = ccp(LEFT_BUTTON_TOP_X, LEFT_BUTTON_TOP_Y);
        
        CCMenuItem *infoItem = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:buttonInfoOn target:self selector:@selector(buttonTapped:)];
        infoItem.tag = kButtonInfo;
        infoItem.anchorPoint = CGPointMake(0.5, 1);
        infoItem.position = ccp(RIGHT_BUTTON_TOP_X, RIGHT_BUTTON_TOP_Y);
        
        CCMenu *topMenu = [CCMenu menuWithItems:backItem, infoItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:3];
    }
    return self;
}

- (void)zoomLayer:(float)zoomScale {
	// Debugging purposes
	//	NSLog(@"zoombase scale: %f and scale from the gesture: %f\n",zoombase.scale, zoomScale);
	if ((zoomBase.scale*zoomScale) <= MIN_SCALE) {
		zoomScale = MIN_SCALE/zoomBase.scale;
	}
	if ((zoomBase.scale*zoomScale) >= MAX_SCALE) {
		zoomScale =	MAX_SCALE/zoomBase.scale;
	}
	zoomBase.scale = zoomBase.scale*zoomScale;
}

- (void) moveBoard:(CGPoint)translation from:(CGPoint)lastLocation {
	CGPoint target_position = ccpAdd(translation, lastLocation);
    
	//CGSize size = [[CCDirector sharedDirector] winSize];
    
	// Insert routine here to check that target position is not out of bounds for your background
	// Remember that ZB_last_posn is a variable that holds the current position of zoombase
	zoomBase.position = target_position;
    
}

#pragma mark -
#pragma mark Gestures methods & callbacks
- (void) selectSpriteForTouch:(CGPoint)touchLocation {
    CCSprite *newSprite = nil;
    for (CCSprite *sprite in buttonsArray) {
        CCLOG(@"touch loc %@", NSStringFromCGPoint(touchLocation));
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {            
            newSprite = sprite;
            break;
        }
    }
    selSprite = newSprite;
    if (selSprite) {
        CCLOG(@"zdar %@", selSprite);
    }
}

#pragma mark -
#pragma mark UIGesture recognizer handlers
- (void) handleSingleTapFrom:(UITapGestureRecognizer *)recognizer {
    CCLOG(@"single tap");
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToWorldSpaceAR:touchLocation];                
    [self selectSpriteForTouch:touchLocation];
}

- (void) handleDoubleTapFrom:(UITapGestureRecognizer *)recognizer {
	//zoombase.scale = 1;
}
- (void) handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint translation = [recognizer translationInView:recognizer.view];
		translation.y = -1 * translation.y;
		[self moveBoard:translation from:zbLastPos];
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
        zbLastPos = zoomBase.position;
    }
}

- (void) handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
	if ((recognizer.state == UIGestureRecognizerStateBegan) || (recognizer.state == UIGestureRecognizerStateChanged)) {
		float zoomScale = [recognizer scale];
		[self zoomLayer:zoomScale];
		recognizer.scale = 1;
	}
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		// Update the zoombase position
		zbLastPos = zoomBase.position;
	}
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end
