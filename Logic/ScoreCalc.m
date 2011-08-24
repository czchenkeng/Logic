//
//  ScoreCalc.m
//  Logic
//
//  Created by Pavel Krusek on 8/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreCalc.h"

@interface ScoreCalc (PrivateMethods)
- (void) generatePatterns;
- (BOOL) compareArrays:(CCArray *)pattern1 withArray:(CCArray *)pattern2;
@end


static const int NUM_OF_ROWS = 10;

@implementation ScoreCalc

@synthesize hiddenPattern;

- (id) initWithColors:(int)c pins:(int)p {
    self = [super init];
    if (self) {
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
    patterns = [[CCArray alloc] init];
    int patternCount = (int)pow(colorsCount, pinsCount);
    int c = 0;
    for (int i = 0; i < patternCount; i++) {
        //int newPattern[pinsCount];
        CCArray *newPattern = [[CCArray alloc] initWithCapacity:pinsCount];
        [newPattern addObject:[NSNumber numberWithInt:i%colorsCount]]; 
        //newPattern[0] = i % colorsCount;
        for (int pin = 1; pin < pinsCount; pin++) {
            //newPattern[pin] = i % (int)pow(colorsCount, pin + 1) / (int)pow(colorsCount, pin);
            [newPattern addObject:[NSNumber numberWithInt:i % (int)pow(colorsCount, pin + 1) / (int)pow(colorsCount, pin)]];
        }
        c++;
        //CCLOG(@"PATTERN %@", newPattern);
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

- (BOOL) isPlayerTurnInPatterns:(CCArray *)turn {
    BOOL retVal = NO;
    for (CCArray *pattern in patterns) {
        if ([self compareArrays:pattern withArray:turn]) {
            retVal = YES;
            break;
        }
    }
    return retVal;
}

- (BOOL) compareArrays:(CCArray *)pattern1 withArray:(CCArray *)pattern2 {
    for (int i = [pattern2 count] - 1; i >= 0; i--) {
        if ([[pattern1 objectAtIndex:i] intValue] != [[pattern2 objectAtIndex:i] intValue]) {
            return NO;
        }
    }
    return YES;
}

- (Guess *) makeResult:(CCArray *)patternR guess:(CCArray *)guessR {
    //CCArray *pattern = [[CCArray alloc] initWithCapacity:hiddenPattern.count];
    //CCArray *guess = [[CCArray alloc] initWithCapacity:turn.count];
    Guess *guessResult = [[Guess alloc] init];
    //guessResult.pattern = [[CCArray alloc] initWithCapacity:hiddenPattern.count];
    guessResult.pattern = [[CCArray alloc] initWithArray:guessR];
    
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

- (void) removeNotEligible:(Guess *)guess {
    for (int i = patterns.count - 1; i >= 0; i--) {
        Guess *g = [self makeResult:[patterns objectAtIndex:i] guess:guess.pattern];
        if (![guess compareResult:g]) {
            [patterns removeObjectAtIndex:i];
        }
    }
}

- (int) calculateScoreWithRow:(int)row andTurn:(CCArray *)turn{
    for (NSNumber *t  in turn) {
        //CCLOG(@"TURN JE %i", [t intValue]);
    }
    for (NSNumber *p  in hiddenPattern) {
        //CCLOG(@"PATTERN JE %i", [p intValue]);
    }
    totalTurns = row;
    //int newPattern[pinsCount];
    
    int k1 = 1000; //koeficient spravneho tahu
    int k2 = 300; //bonus za dvojice v prvnim tahu
    int k3 = 300; //koeficient casu spravneho tahu
    int k4 = 100; //koeficient casu nespravneho tahu
    
    int endBonus = 3000;
    
//    if (row == 0) {
//        points += k2;
//    }
    
    if ([self isPlayerTurnInPatterns:turn]) {
        points += k1 / (row + 1) + k3 / [Utils randomNumberBetween:1 andMax:101];
        CCLOG(@"JE TAM PATTERN");
        Guess *result = [self makeResult:hiddenPattern guess:turn];
        [self removeNotEligible:result];
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
    [hiddenPattern release];
    hiddenPattern = nil;
    
    [super dealloc];
}

@end