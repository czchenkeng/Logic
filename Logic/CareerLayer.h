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
    CCArray *percentLabelArray;
    
    CCSprite *infoPanel;
    CCSprite *background;
    City *selSprite;
    City *currentCity;
    City *lastCity;
    CCSprite *progressBar;
    
    int buttonWidth;//zatim nefachci - mrknout se
    int buttonHeight;//zatim nefachci - mrknout se
    
    CCMenuItem *infoOff;
    CCMenuItem *infoOn;
        
    int prog;
    float total;//progress bar width
    int percent;    
    BOOL panelActive;
    
    int score;
    
    int diff;//default diff
    
    BOOL blink;
    
    UIPanGestureRecognizer *panGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;    
    UITapGestureRecognizer *singleTapGestureRecognizer;

}

@end
