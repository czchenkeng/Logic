//
//  ProgressTimer.h
//  Logic
//
//  Created by Pavel Krusek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProgressTimer : CCSprite {
    CCLabelTTF *timeLabel;
	ccTime totalTime;
	int myTime;
	int currentTime;
    int gameTime;
}

@property (readonly) int gameTime;

@end
