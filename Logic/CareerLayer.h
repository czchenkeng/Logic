//
//  CareerLayer.h
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mask.h"
#import "City.h"
#import "Wire.h"
#import "PercentNumber.h"
#import "GameManager.h"

@interface CareerLayer : CCLayer <UIAlertViewDelegate, UIGestureRecognizerDelegate>{
    CCLayerColor *zoomBase;
    CGPoint zbLastPos;
    
    CCArray *citiesArray;
    CCArray *wiresArray;
    City *selSprite;
    CCSprite *background;
    
    CCSprite *infoPanel;
    
    int buttonWidth;
    int buttonHeight;
    
    CCMenuItem *infoOff;
    CCMenuItem *infoOn;
    
    CCSprite *progressBar;
    int prog;
    float total;
    int percent;
    CCArray *percentLabelArray;
    BOOL panelActive;
    
    UIPanGestureRecognizer *panGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;    
    UITapGestureRecognizer *singleTapGestureRecognizer;
    UITapGestureRecognizer *doubleTapGestureRecognizer;
    
    ///DEBUG PURPOSE
    CCLabelBMFont *debugText;

}

@end
