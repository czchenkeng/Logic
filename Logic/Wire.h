//
//  Wire.h
//  Logic
//
//  Created by Pavel Krusek on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Wire : CCSprite {
    NSArray *lights;
}

@property (retain, readwrite) NSArray *lights;

@end
