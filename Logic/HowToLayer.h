//
//  HowToLayer.h
//  Logic
//
//  Created by Pavel Krusek on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLabelBMFontMultiline.h"

@interface HowToLayer : CCLayer <UIGestureRecognizerDelegate> {
    UIPanGestureRecognizer *panGestureRecognizer;
    CGPoint zbLastPos;
    CCLayer *howTo;
    
    BOOL anim3;
    BOOL anim4;
}

@end
