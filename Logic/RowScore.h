//
//  RowScore.h
//  Logic
//
//  Created by Pavel Krusek on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RowScore : CCSprite {
    CCSprite *numbers;
}

- (void) moveToPosition:(int)position;

@end
