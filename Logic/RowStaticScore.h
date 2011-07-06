//
//  RowStaticScore.h
//  Logic
//
//  Created by Pavel Krusek on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RowStaticScore : CCSprite {
    
    CCSprite *empty;
    CCSprite *number;
}

- (void) showNumber:(int)position;

@end
