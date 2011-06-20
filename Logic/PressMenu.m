//
//  PressMenu.m
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PressMenu.h"


@implementation PressMenu

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super ccTouchBegan:touch withEvent:event];
    [selectedItem_ unselected];
    [selectedItem_ activate];
    state_ = kCCMenuStateWaiting;
    return NO;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
	
	//[selectedItem_ unselected];
	//[selectedItem_ activate];
	
	//state_ = kCCMenuStateWaiting;
}

@end
