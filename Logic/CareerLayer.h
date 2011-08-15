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
    CCSprite *progressBar;
    
    int buttonWidth;//zatim nefachci - mrknout se
    int buttonHeight;//zatim nefachci - mrknout se
    
    CCMenuItem *infoOff;
    CCMenuItem *infoOn;
        
    int prog;
    float total;//progress bar width
    int percent;    
    BOOL panelActive;
    
    int diff;//default diff
    
    UIPanGestureRecognizer *panGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;    
    UITapGestureRecognizer *singleTapGestureRecognizer;

}

@end

/*
Nova kariera - existuje rozehrana s 0? Pokud ano a tapnu na mesto, tak vymazat z dbase a nahodit s novym mestem (muze byt stejne, checkovat to nebudu)
reset (new) game z pauzy, reload game (tady asi ne, k tomuto buttonu se dostanu az po dokonceni levelu) - vymazat hrani kariery?
 game - code fail - vymazat karieru? asi ano, opet posledni radek pokud je is_done 0
 u klasicky rozehrane hry kariera zustava
 
 */
