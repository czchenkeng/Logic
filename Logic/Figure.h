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
    CCSprite *imageSprite;
}

- (Figure *) initWithFigureType:(FigureTypes)figureID;

@property FigureTypes currentFigure;

@end
