//
//  Utils.m
//  Logic
//
//  Created by Pavel Krusek on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"


@implementation Utils

+ (int) randomNumberBetween:(int)min andMax:(int)max {
	int range = max - min;
	int ranNumber = (arc4random() % range) + min;
	return ranNumber;
}

@end
