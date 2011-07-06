//
//  RowScore.h
//  Logic
//
//  Created by Pavel Krusek on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mask.h"


@interface RowScore : CCLayer {
    CCSprite *numbers;
    Mask *_mask;
}

- (void) moveToPosition:(int)position andMask:(Mask *)mask;

@end
