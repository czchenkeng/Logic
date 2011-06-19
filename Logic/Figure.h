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
    int place;
    BOOL isActive;//vyhodit? uz se umistene neposouvaji
    BOOL isCalculated;
}

- (Figure *) initWithFigureType:(FigureTypes)figureID;

@property FigureTypes currentFigure;
@property CGPoint originalPosition;
@property int place;
@property BOOL isActive;
@property BOOL isCalculated;

- (void) destroy;

@end
