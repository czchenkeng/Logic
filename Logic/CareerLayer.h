//
//  CareerLayer.h
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mask.h"


@interface CareerLayer : CCLayer {
    CCLayerColor *zoomBase;
    CGPoint zbLastPos;
    
    CCArray *buttonsArray;
    CCSprite *selSprite;
    CCSprite *background;
    
    CGRect rectsArray[24];
    
    UIPanGestureRecognizer *panGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;    
    UITapGestureRecognizer *singleTapGestureRecognizer;
    UITapGestureRecognizer *doubleTapGestureRecognizer;

}

@end
