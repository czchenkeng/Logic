//
//  Viewport.h
//  Logic
//
//  Created by Pavel Krusek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Mask : CCNode {
}

+ (Mask*) maskWithRect:(CGRect)rect;
- (id) initWithRect:(CGRect)rect;
- (void) redrawRect:(CGRect)rect;

@end
