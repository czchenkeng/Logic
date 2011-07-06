//
//  ProgressTimer.m
//  Logic
//
//  Created by Pavel Krusek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressTimer.h"


@implementation ProgressTimer
@synthesize gameTime;


- (id) init {
    self = [super init];
    if (self != nil) {
        myTime = 0;
        
		timeLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:48];
		//timeLabel.position = CGPointMake(size.width / 2, size.height);
		// Adjust the label's anchorPoint's y position to make it align with the top.
		timeLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
		// Add the time label
		[self addChild:timeLabel];
        
        [self schedule:@selector(update:)];
    }
    return self;
}

- (void) update:(ccTime)dt{
    
    totalTime += dt;
    currentTime = (int)totalTime;
    gameTime = (int)totalTime;
	if (myTime < currentTime)
	{
		myTime = currentTime;
		//[timeLabel setString:[NSString stringWithFormat:@"%i", myTime]];
        //CCLOG(@"game timer %@",  [NSString stringWithFormat:@"%02d:%02d", myTime/60, myTime%60]);
        //int seconds = myTime % 10;
        //CCLOG(@"timer %i",  seconds < 10 ? seconds : abs(10 - seconds));
        //CCLOG(@"timer %i",  seconds);
	}
    
}

@end
