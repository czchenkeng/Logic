//
//  City.h
//  Logic
//
//  Created by Pavel Krusek on 7/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface City : CCSprite {
    float buttonX;
    float buttonY;
    int idCity;
    BOOL isActive;
    NSArray *belongs;
    NSArray *difficulty;
}

@property (readwrite) float buttonX;
@property (readwrite) float buttonY;
@property (readwrite) int idCity;
@property (readwrite) BOOL isActive;
@property (retain, readwrite) NSArray *belongs;
@property (retain, readwrite) NSArray *difficulty;

@end
