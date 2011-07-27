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
- (void) buildCareer;
- (void) buildWires;
- (void) activateWires;
- (void) setProgress;
- (void) eraseCareer;
- (void) constructPercentLabel;
- (void) drawPercentToLabel;
- (NSString *) jsonFromFile:(NSString *)file;
- (void) handleError:(NSError *)error;
@end

static const float MIN_SCALE = 0.8;
static const float MAX_SCALE = 1.667;
static const float POS_X = 260;
static const float POS_Y = -40;

@implementation CareerLayer

- (void) endAnimation {
    PercentNumber *tempPercentNumber;
    for (int i=0; i < 3; i++) {
        tempPercentNumber = [percentLabelArray objectAtIndex:i];
        tempPercentNumber.visible = panelActive;
    }
    if (panelActive) {
        [self setProgress];
    }     
}

- (void) infoPanelIn {
    float debugSlow = -0.40;
    
    CCMoveTo *infoPanelMoveIn = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(125.00, 98.00)];
    CCScaleTo *infoPanelScaleInX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:1.0 scaleY:1.0];
    //CCRotateTo *leftGibRotationIn = [CCRotateTo actionWithDuration:debugSlow + 1.0 angle:-2];
    CCSpawn *infoPanelSeq = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.0f], infoPanelMoveIn, infoPanelScaleInX, nil];
    CCSequence *inSeq = [CCSequence actions:infoPanelSeq, [CCCallFunc actionWithTarget:self selector:@selector(endAnimation)], nil];
    
    [infoPanel runAction:inSeq];
}

- (void) infoPanelOut {
    float debugSlow = -0.60;
    
    CCMoveTo *infoPanelMoveOut = [CCMoveTo actionWithDuration:debugSlow + 1.0 position:ccp(-850.00, 0.00)];
    CCScaleTo *infoPanelScaleOutX = [CCScaleTo actionWithDuration:debugSlow + 1.0 scaleX:5 scaleY:22];
    CCSpawn *infoPanelSeqOut = [CCSpawn actions:[CCDelayTime actionWithDuration: 0.0f], infoPanelScaleOutX, infoPanelMoveOut, nil];
    
    [infoPanel runAction:infoPanelSeqOut];
}

- (void) buttonTapped:(CCMenuItem *)sender { 
    switch (sender.tag) {
        case kButtonBack:
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kSlideInL];
            break;
        case kButtonEraseCareer:
            //[self eraseCareer];
            CCLOG(@"erase tap");
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

- (void) infoButtonTapped:(id)sender {  
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
    if (toggleItem.selectedItem == infoOff) {
        panelActive = NO;
        [self endAnimation];
        [self infoPanelOut];
    } else if (toggleItem.selectedItem == infoOn) {
        panelActive = YES;
        [self infoPanelIn];
    }  
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 1) {
            [self eraseCareer];
        }
    }
}

- (void) eraseCareer {
    for (City *city in citiesArray) {
        city.visible = NO;
        city.isActive = NO;
    }
    for (Wire *wire in wiresArray) {
        wire.visible = NO;
    }
    percent = 4;
    prog = 1;
    [self setProgress];
    PercentNumber *tempPercentNumber;
    for (int i=1; i < 3; i++) {
        tempPercentNumber = [percentLabelArray objectAtIndex:i];
        [tempPercentNumber moveToPosition:-1];
    }
    [self drawPercentToLabel];
}

#pragma mark -
#pragma mark Enter & Exit
- (void) onEnter {
    panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)] autorelease];
    pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)] autorelease];
    
    singleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)] autorelease];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    
//    doubleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleDoubleTapFrom:)] autorelease];
//    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
//    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    
    //[singleTapGestureRecognizer requireGestureRecognizerToFail: doubleTapGestureRecognizer];
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTapGestureRecognizer];
    //[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:doubleTapGestureRecognizer];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panGestureRecognizer];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pinchGestureRecognizer];
    
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    //panGestureRecognizer.cancelsTouchesInView = YES;
    //pinchGestureRecognizer.cancelsTouchesInView = YES;
    //singleTapGestureRecognizer.delegate = self;
    
    [super onEnter];
}

- (void) onExit {
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:singleTapGestureRecognizer];
    //[[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:doubleTapGestureRecognizer];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:panGestureRecognizer];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pinchGestureRecognizer];
    [super onExit];
}

#pragma mark -
#pragma mark GESTURES DELEGATE METHODS
#pragma mark Simultaneous
//- (BOOL) gestureRecognizer:singleTapGestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:panGestureRecognizer {
//    return NO;
//}

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
        
        prog = 1;
        percent = 4;
        
        panelActive = NO;
        
        zoomBase = [CCColorLayer layerWithColor:ccc4(0,0,0,0)];
		zoomBase.position = ccp(0, 0);
        //zoomBase.contentSize = CGSizeMake(740, 600);
		[self addChild:zoomBase z:1];
        
        zbLastPos = zoomBase.position;
        
        background = [CCSprite spriteWithSpriteFrameName:@"logik_levels.png"];
        //background.position = ccp(96.00, 282.00);
        background.anchorPoint = ccp(0, 0);
        background.position = ccp(-POS_X, 0);
        [zoomBase addChild:background z:1];
        
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_levels_bulbon_start.png"];
        sprite.anchorPoint = ccp(0, 0);
        sprite.position = ccp(359.5, 222);
        [background addChild:sprite z:100];
        
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
        
//        CCMenuItem *infoItem = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:buttonInfoOn target:self selector:@selector(buttonTapped:)];
//        infoItem.tag = kButtonInfo;
//        infoItem.anchorPoint = CGPointMake(0.5, 1);
//        infoItem.position = ccp(RIGHT_BUTTON_TOP_X, RIGHT_BUTTON_TOP_Y);
        
        CCMenu *topMenu = [CCMenu menuWithItems:backItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:3];
        
        infoOff = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOff selectedSprite:nil target:nil selector:nil];
        infoOn = [CCMenuItemSprite itemFromNormalSprite:buttonInfoOn selectedSprite:nil target:nil selector:nil];
        
        CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(infoButtonTapped:) items:infoOff, infoOn, nil];
        CCMenu *toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
        toggleMenu.position = ccp(RIGHT_BUTTON_TOP_X, RIGHT_BUTTON_TOP_Y);
        toggleItem.anchorPoint = CGPointMake(0.5, 1);
        [self addChild:toggleMenu z:4];

        infoPanel = [CCSprite spriteWithSpriteFrameName:@"infoPanel.png"];
        
        infoPanel.scaleY = 22;
        infoPanel.scaleX = 5;
        [infoPanel setPosition:ccp(-850.00, 0.00)];
        
        //infoPanel.position = ccp(125.00, 98.00);
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
        
        debugText = [CCLabelBMFont labelWithString:@"debug" fntFile:@"BellGothicBoldHt.fnt"];
        debugText.anchorPoint = ccp(0, 0.5);
        [debugText setPosition:ccp(50, 5)];
        [self addChild:debugText z:1000];
        
        [self constructPercentLabel];
        [self buildCareer];
        [self buildWires];
        //[self setProgress];
    }
    return self;
}

#pragma mark Construct score Label
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

- (void) buildCareer {
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
        [background addChild:city z:100];
        [citiesArray addObject:city];
    }
}
    
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

#pragma mark -
#pragma mark Data from file
- (NSString *) jsonFromFile:(NSString *)file {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];  
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    NSString *s = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];    
    return s;
}

- (void)zoomLayer:(float)zoomScale {
	if ((zoomBase.scale*zoomScale) <= MIN_SCALE) {
		zoomScale = MIN_SCALE/zoomBase.scale;
	}
	if ((zoomBase.scale*zoomScale) >= MAX_SCALE) {
		zoomScale =	MAX_SCALE/zoomBase.scale;
	}
	zoomBase.scale = zoomBase.scale*zoomScale;
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    //CCLOG(@"SCALE %f", zoomBase.scale);
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, POS_X);
    retval.x = MAX(retval.x, -background.contentSize.width*zoomBase.scale + POS_X + winSize.width);
    retval.y = MIN(retval.y, POS_Y);
    retval.y = MAX(retval.y, -background.contentSize.height*zoomBase.scale - POS_Y + winSize.height);
    return retval;
}

//retval.x = MAX(retval.x, -background.contentSize.width*self.scale+winSize.width);
//retval.y = MIN(retval.y, 0);
//retval.y = MAX(retval.y, -background.contentSize.height*self.scale+winSize.height);

- (void) moveBoard:(CGPoint)translation from:(CGPoint)lastLocation {
	CGPoint target_position = ccpAdd(translation, lastLocation);
    
	//CGSize size = [[CCDirector sharedDirector] winSize];
    
	// Insert routine here to check that target position is not out of bounds for your background
	// Remember that ZB_last_posn is a variable that holds the current position of zoombase
    //CCLOG(@"pos %@", NSStringFromCGPoint(target_position));
	//zoomBase.position = target_position;
    zoomBase.position = [self boundLayerPos:target_position];
}

#pragma mark -
#pragma mark Gestures methods & callbacks
- (void) selectSpriteForTouch:(CGPoint)touchLocation {
    CCLOG(@"je tam %i ?", buttonWidth);
    City *newSprite = nil;
    for (City *sprite in citiesArray) {
        if (CGRectContainsPoint(CGRectMake(sprite.buttonX, sprite.buttonY, 46, 56), touchLocation)) {            
            newSprite = sprite;
            break;
        }
    }
    selSprite = newSprite;
    if (selSprite) {
        BOOL active = NO;
        int diff = 6;
        City *city;
        if ([selSprite.belongs count] == 0) {
            active = YES;
            diff = [[selSprite.difficulty objectAtIndex:0] intValue];
        } else {
            for (int i = 0; i < [selSprite.belongs count]; i++) {
                int index = [[selSprite.belongs objectAtIndex:i] intValue];
                city = [citiesArray objectAtIndex:index - 1];
                if (city.isActive) {
                    active = YES;
                    if ([[selSprite.difficulty objectAtIndex:i] intValue] < diff) {
                        diff = [[selSprite.difficulty objectAtIndex:i] intValue];
                    }
                }
            }
        }
        if (active) {
            [debugText setString:[NSString stringWithFormat:@"%i", diff]];
            selSprite.visible = YES;
            selSprite.isActive = YES;
            prog += 1;
            percent += 4;
            [self activateWires];
            [self setProgress];
        }
    }
}

- (void) setProgress {
    if (panelActive) {
        CGRect barRect = [progressBar textureRect];
        barRect.size.width = total / 25 * prog;
        [progressBar setTextureRect: barRect];
        [self drawPercentToLabel];
    }
}

- (void) activateWires {
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
            wire.visible = YES;
        }
    }
}

#pragma mark -
#pragma mark UIGesture recognizer handlers
- (void) handleSingleTapFrom:(UITapGestureRecognizer *)recognizer {
    //CCLOG(@"single tap");
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [background convertToNodeSpace:touchLocation];               
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

#pragma mark -
#pragma mark Error handlers
- (void) handleError:(NSError *)error {
    if (error != nil) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [errorAlertView show];
        [errorAlertView release];
    }
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [citiesArray release];
    citiesArray = nil;
    [wiresArray release];
    wiresArray = nil;
    [percentLabelArray release];
    percentLabelArray = nil;
    [super dealloc];
}

@end
