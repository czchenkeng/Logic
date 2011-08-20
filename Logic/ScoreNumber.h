//
//  ScoreNumber.h
//  Logic
//
//  Created by Pavel Krusek on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScoreNumber : CCSprite {
    CCSprite *numbers;
}

- (void) moveToPosition:(int)position;
- (void) jumpToPosition:(int)position;

@end
