//
//  Figure.h
//  Logic
//
//  Created by Pavel Krusek on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


@interface Figure : CCSprite {
    FigureTypes currentFigure;
    CGPoint originalPosition;
    CGPoint tempPosition;
    int place;
    int oldPlace;
    BOOL isActive;//vyhodit? uz se umistene neposouvaji
    BOOL isCalculated;
    BOOL isOnActiveRow;
}

- (Figure *) initWithFigureType:(FigureTypes)figureID;

@property FigureTypes currentFigure;
@property CGPoint originalPosition;
@property CGPoint tempPosition;
@property int place;
@property int oldPlace;
@property BOOL isActive;
@property BOOL isCalculated;
@property BOOL isOnActiveRow;

- (void) destroy;

@end
