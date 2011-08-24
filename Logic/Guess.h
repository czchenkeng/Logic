//
//  Guess.h
//  Logic
//
//  Created by Apple on 8/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Guess : NSObject {
    int resultInPosition;
    int resultOutOfPosition;
    CCArray *pattern;
}

@property int resultInPosition;
@property int resultOutOfPosition;
@property (nonatomic, retain) CCArray *pattern;

- (BOOL) compareResult:(Guess *)guess;

@end