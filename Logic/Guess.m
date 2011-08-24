//
//  Guess.m
//  Logic
//
//  Created by Apple on 8/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Guess.h"

@implementation Guess

@synthesize resultInPosition, resultOutOfPosition, pattern;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL) compareResult:(Guess *)guess {
    return [self resultInPosition] == [guess resultInPosition] && [self resultOutOfPosition] == [guess resultOutOfPosition];
}

- (void)dealloc {
    [super dealloc];
}

@end
