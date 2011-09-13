//
//  ScoreCalc.m
//  Logic
//
//  Created by Pavel Krusek on 8/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreCalc.h"
#import "Guess.h"

@interface ScoreCalc (PrivateMethods)
- (void) generatePatterns:(NSMutableArray *)pattern colors:(int)colors pins:(int)pins;
- (BOOL) compareArrays:(NSArray *)pattern1 withArray:(NSArray *)pattern2;
@end


static const int NUM_OF_ROWS = 10;

@implementation ScoreCalc

@synthesize hiddenPattern, endBonus;

- (id) initWithColors:(int)c pins:(int)p row:(int)r {
    self = [super init];
    if (self) {
        backgroundQueue = dispatch_queue_create(NULL, NULL);
        
        colorsCount = c;
        pinsCount = p;
        totalTurns = 0;
        points = 0;
        
        //[self generatePatterns];
        if (r == 0)
            patterns = [[NSMutableArray alloc] initWithArray:[[GameManager sharedGameManager] getGamePattern] copyItems:YES];
        else {
            patterns = [[GameManager sharedGameManager] readPattern];
            [patterns retain];
        }
        
        CCLOG(@"game pattern ready %i", [patterns count]);
    }
    return self;
}

+ (id) scoreWithColors:(int)c pins:(int)p row:(int)r {
    return [[[self alloc] initWithColors:(int)c pins:(int)p row:(int)r] autorelease];
}


- (BOOL) isPlayerTurnInPatterns:(NSArray *)turn {
    BOOL retVal = NO;
    for (NSArray *pattern in patterns) {
        if ([self compareArrays:pattern withArray:turn]) {
            retVal = YES;
            break;
        }
    }
    return retVal;
}

- (BOOL) compareArrays:(NSArray *)pattern1 withArray:(NSArray *)pattern2 {
    for (int i = [pattern2 count] - 1; i >= 0; i--) {
        if ([[pattern1 objectAtIndex:i] intValue] != [[pattern2 objectAtIndex:i] intValue]) {
            return NO;
        }
    }
    return YES;
}

- (Guess *) makeResult:(NSArray *)patternR guess:(NSArray *)guessR {
    Guess *guessResult = [[Guess alloc] init];
    guessResult.pattern = [[NSArray alloc] initWithArray:guessR copyItems:YES];
    for (int i = 0; i < patternR.count; i++)
    {
        if ([[patternR objectAtIndex:i] intValue] == [[guessR objectAtIndex:i] intValue])
        {
            guessResult.resultInPosition++;
        }
    }
    
    for (int i = 0; i < patternR.count; i++)
    {
        for (int j = 0; j < patternR.count; j++)
        {
            if (([[patternR objectAtIndex:i] intValue] == [[guessR objectAtIndex:j] intValue]) && i != j && ([[patternR objectAtIndex:i] intValue] != 255))
            {
                guessResult.resultOutOfPosition++;
            }
        }
    }
    
    return guessResult;
}

- (void) calculationDone {
    CCLOG(@"CALC DONE");
    [[GameManager sharedGameManager] savePattern:patterns];
}

- (void) removeNotEligible:(Guess *)guess {
    for (int i = patterns.count - 1; i >= 0; i--) {
        Guess *g = [self makeResult:[patterns objectAtIndex:i] guess:guess.pattern];
        if (![guess compareResult:g]) {
            [patterns removeObjectAtIndex:i];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self calculationDone];
    });
}

- (BOOL) hasDoubles:(NSArray *)array {
    for (int i = 0; i < array.count - 1; i++) {
        int item = [[array objectAtIndex:i] intValue];
        for (int j = i + 1; j < array.count; j++) {
            if (item == [[array objectAtIndex:j] intValue]) {
                return YES;
            }
        }
    }
    return NO;
}

- (int) calculateScoreWithRow:(int)row andTurn:(NSArray *)turn{
    totalTurns = row;
    
    int k1 = 1000; //koeficient spravneho tahu
    int k2 = 300; //bonus za dvojice v prvnim tahu
    int k3 = 300; //koeficient casu spravneho tahu
    int k4 = 100; //koeficient casu nespravneho tahu
    
    //int endBonusConst = 3000;
    
    if (row == 0 && [self hasDoubles:turn]) {
        CCLOG(@"HAS DOUBLES");
        points += k2;
    }
    
    if ([self isPlayerTurnInPatterns:turn]) {
        CCLOG(@"JE TAM PATTERN");
        points += k1 / (row + 1) + k3 / [Utils randomNumberBetween:1 andMax:101];
        Guess *result = [self makeResult:hiddenPattern guess:turn];
        dispatch_async(backgroundQueue, ^(void) {
            [self removeNotEligible:result];
        });
        
        
    } else {
        CCLOG(@"NENI TAM PATTERN");
        points += k4 / ([Utils randomNumberBetween:1 andMax:21]); 
    }
    
    //CCLOG(@"PATTERNS COUNT %i", patterns.count);
    
    //Dohral
//    if (patterns.count == 1)
//    {
//        endBonus = (int)ceil(endBonusConst / (10 - totalTurns));
//    }
    
    return points;
}

- (int) getBonus {
    return (int)ceil(3000 / (10 - totalTurns));
}

- (void) dealloc {
    dispatch_release(backgroundQueue);
    [patterns release];
    patterns = nil;
    [hiddenPattern release];
    hiddenPattern = nil;
    
    [super dealloc];
}

@end