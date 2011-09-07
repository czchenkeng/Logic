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
- (void) generatePatterns;
- (BOOL) compareArrays:(NSArray *)pattern1 withArray:(NSArray *)pattern2;
@end


static const int NUM_OF_ROWS = 10;

@implementation ScoreCalc

@synthesize hiddenPattern;

- (id) initWithColors:(int)c pins:(int)p {
    self = [super init];
    if (self) {
        backgroundQueue = dispatch_queue_create(NULL, NULL);
        
        colorsCount = c;
        pinsCount = p;
        totalTurns = 0;
        points = 0;
        
        [self generatePatterns];
    }
    return self;
}

+ (id) scoreWithColors:(int)c pins:(int)p {
    return [[[self alloc] initWithColors:(int)c pins:(int)p] autorelease];
}

- (void) generatePatterns {
    patterns = [[NSMutableArray alloc] init];
    int patternCount = (int)pow(colorsCount, pinsCount);
    int c = 0;
    for (int i = 0; i < patternCount; i++) {
        NSMutableArray *newPattern = [[NSMutableArray alloc] initWithCapacity:pinsCount];
        [newPattern addObject:[NSNumber numberWithInt:i%colorsCount]]; 
        for (int pin = 1; pin < pinsCount; pin++) {
            [newPattern addObject:[NSNumber numberWithInt:i % (int)pow(colorsCount, pin + 1) / (int)pow(colorsCount, pin)]];
        }
        c++;
        [patterns addObject:newPattern];
    }
    CCLOG(@"****\n****\n****\n****\n****\n****\nKOLIK TOHO JE? %i****\n****\n****\n****\n****\n****\n", c);
    //return patterns;
}

//- (BOOL) hasDoubles
//
//
//private static bool HasDoubles(int[] pattern)
//{
//    List<int> list = new List<int>();
//    for (int i = 0; i < pattern.Length; i++)
//    {
//        if (list.Where(a => a == pattern[i]).FirstOrDefault() != null)
//        {
//            return true;
//        }
//        list.Add(pattern[i]);
//    }
//    return false;
//}

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
    guessResult.pattern = [[NSArray alloc] initWithArray:guessR];
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

- (void) hotovo {
    CCLOG(@"HOTOVO!!!!");
}

- (void) removeNotEligible:(Guess *)guess {
    for (int i = patterns.count - 1; i >= 0; i--) {
        Guess *g = [self makeResult:[patterns objectAtIndex:i] guess:guess.pattern];
        if (![guess compareResult:g]) {
            [patterns removeObjectAtIndex:i];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self hotovo];
    });
}

- (int) calculateScoreWithRow:(int)row andTurn:(NSArray *)turn{
    for (NSNumber *t  in turn) {
        //CCLOG(@"TURN JE %i", [t intValue]);
    }
    for (NSNumber *p  in hiddenPattern) {
        //CCLOG(@"PATTERN JE %i", [p intValue]);
    }
    totalTurns = row;
    
    int k1 = 1000; //koeficient spravneho tahu
    //int k2 = 300; //bonus za dvojice v prvnim tahu
    int k3 = 300; //koeficient casu spravneho tahu
    int k4 = 100; //koeficient casu nespravneho tahu
    
    int endBonus = 3000;
    
    
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
    
    CCLOG(@"PATTERNS COUNT %i", patterns.count);
    
    //Dohral
    if (patterns.count == 1)
    {
        points += endBonus / (10 - totalTurns);
    }
    
    return points;
}

- (void) dealloc {
    dispatch_release(backgroundQueue);
    [hiddenPattern release];
    hiddenPattern = nil;
    
    [super dealloc];
}

@end