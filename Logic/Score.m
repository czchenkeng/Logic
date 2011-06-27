//
//  Score.m
//  Logic
//
//  Created by Pavel Krusek on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Score.h"


@implementation Score
@synthesize uniqueId, score, time, date;

- (id)initWithUniqueId:(NSString *)uid score:(NSString *)lscore time:(NSString *)ltime date:(NSString *)ldate {
    if ((self = [super init])) {
        self.uniqueId = [[NSString alloc] initWithString:uid];
        self.score = [[NSString alloc] initWithString:lscore];
        self.time = [[NSString alloc] initWithString:ltime];
        self.date = [[NSString alloc] initWithString:ldate];
    }
    return self;
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    self.uniqueId = nil;
    self.score = nil;
    self.time = nil;
    self.date = nil;
    [super dealloc];
}

@end
