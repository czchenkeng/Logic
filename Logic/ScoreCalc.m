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
- (Guess *) makeResult:(NSArray *)patternR guess:(NSArray *)guessR;
//- (void) testAlgorithm;
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
        done = NO;
        saveData = [[NSMutableArray alloc] init];
        
        patterns = [[NSMutableArray alloc] init];
            
        //patterns = [[GameManager sharedGameManager] readPattern];
        //[patterns retain];
        
        CCLOG(@"game pattern ready %i", [patterns count]);
        //[self testAlgorithm];
    }
    return self;
}

+ (id) scoreWithColors:(int)c pins:(int)p row:(int)r {
    return [[[self alloc] initWithColors:(int)c pins:(int)p row:(int)r] autorelease];
}

//- (BOOL) compareArrays:(NSArray *)pattern1 withArray:(NSArray *)pattern2 {
//    for (int i = [pattern2 count] - 1; i >= 0; i--) {
//        if ([[pattern1 objectAtIndex:i] intValue] != [[pattern2 objectAtIndex:i] intValue]) {
//            return NO;
//        }
//    }
//    return YES;
//}

- (void) previousData {
    NSMutableArray *data = [[GameManager sharedGameManager] readPattern];
    for (int i = 0; i < data.count; i++) {
        Guess *result = [self makeResult:hiddenPattern guess:[data objectAtIndex:i]];
        [patterns addObject:result];
    }
    CCLOG(@"nacteni patternu OK %@", patterns);
}

- (BOOL) findInArray:(NSMutableArray *)array posArray:(NSMutableArray *)posArray value:(int)value pos:(int)pos{
    for (int i = 0; i < array.count; i++){
        if ([[array objectAtIndex:i] intValue] == value) {
            for (int j = 0; j < posArray.count; j++) {
                if ([[posArray objectAtIndex:j] intValue] == pos) {
                    return YES;
                }
            }
        }
    }
    return NO;
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
    
    NSMutableArray *calculated = [[NSMutableArray alloc] init];
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    for (int i = 0; i < patternR.count; i++){
        for (int j = 0; j < guessR.count; j++) {
            if ([[patternR objectAtIndex:i] intValue] == [[guessR objectAtIndex:j] intValue] && ![self findInArray:calculated posArray:positions value:[[guessR objectAtIndex:j] intValue] pos:j]) {
                [calculated addObject:[guessR objectAtIndex:j]];
                [positions addObject:[NSNumber numberWithInt:j]];
                guessResult.resultOutOfPosition++;
                break;
            }
        }
    }
    guessResult.resultOutOfPosition = guessResult.resultOutOfPosition - guessResult.resultInPosition;
    CCLOG(@"IN POSITION %i", guessResult.resultInPosition);
    CCLOG(@"OUT POSITION %i", guessResult.resultOutOfPosition);
    
    return guessResult;
}

//- (void) calculationDone {
//    CCLOG(@"CALC DONE");
//    [[GameManager sharedGameManager] savePattern:patterns];
//}
//
//- (void) removeNotEligible:(Guess *)guess {
//    for (int i = patterns.count - 1; i >= 0; i--) {
//        Guess *g = [self makeResult:[patterns objectAtIndex:i] guess:guess.pattern];
//        if (![guess compareResult:g]) {
//            [patterns removeObjectAtIndex:i];
//        }
//    }
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        [self calculationDone];
//    });
//}

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

- (BOOL) compareResult:(Guess *)oldGuess res:(Guess *)newGuess {
    Guess *result = [self makeResult:oldGuess.pattern guess:newGuess.pattern];
    CCLOG(@"R IN POSITION %i", result.resultInPosition);
    CCLOG(@"R OUT POSITION %i", result.resultOutOfPosition);
    CCLOG(@"O IN POSITION %i", oldGuess.resultInPosition);    
    CCLOG(@"O OUT POSITION %i", oldGuess.resultOutOfPosition);
    return result.resultInPosition == oldGuess.resultInPosition && result.resultOutOfPosition == oldGuess.resultOutOfPosition;
}


- (int) calculateScoreWithRow:(int)row andTurn:(NSArray *)turn andTime:(int)roundTime{
    totalTurns = row;
    
    points = 0;
    
    int k1 = 1000; //koeficient spravneho tahu
    int k2 = 300; //bonus za dvojice v prvnim tahu
    int k3 = 400; //koeficient casu spravneho tahu
    int k4 = 200; //koeficient casu nespravneho tahu
    
    //int endBonusConst = 5000;
    
    if (row == 0 && [self hasDoubles:turn]) {
        CCLOG(@"HAS DOUBLES");
        points += k2;
    }
    
    Guess *result = [self makeResult:hiddenPattern guess:turn];
    BOOL correctGuess = true;
    
    for (int i = 0; i < patterns.count; i++) {
        if (![self compareResult:[patterns objectAtIndex:i] res:result]){
            correctGuess = false;
            break;
        }
    }
    
    if (correctGuess) {
        CCLOG(@"CORRECT");
        points += k1 / (row + 1) + k3 / (roundTime + 1);
    } else {
        CCLOG(@"BAD");
        points += k4 / (roundTime + 1);
    }
    
    if (result.resultInPosition == pinsCount) {
        CCLOG(@"end game");
        done = YES;
    }
    
    [patterns addObject:result];
    
    [saveData addObject:turn];
    
    [[GameManager sharedGameManager] savePattern:saveData];
    
    return points;
}

//- (void) testAlgorithm {
//    NSArray *h = [[NSArray alloc] initWithObjects:
//                  [NSNumber numberWithInt:1],
//                  [NSNumber numberWithInt:2],
//                  [NSNumber numberWithInt:3],
//                  [NSNumber numberWithInt:1],
//                  [NSNumber numberWithInt:7],
//                  [NSNumber numberWithInt:7],
//                  nil];
//    NSMutableArray *turns = [[NSMutableArray alloc] init];
//    
//
//    NSArray *turn1 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:0],
//                      [NSNumber numberWithInt:0],
//                      [NSNumber numberWithInt:4],
//                      [NSNumber numberWithInt:4],
//                      [NSNumber numberWithInt:5],
//                      [NSNumber numberWithInt:5],
//                      nil];
//    NSArray *turn2 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:6],
//                      [NSNumber numberWithInt:6],
//                      [NSNumber numberWithInt:6],
//                      [NSNumber numberWithInt:6],
//                      [NSNumber numberWithInt:6],
//                      [NSNumber numberWithInt:6],
//                      nil];
//    NSArray *turn3 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:7],
//                      [NSNumber numberWithInt:7],
//                      [NSNumber numberWithInt:2],
//                      [NSNumber numberWithInt:2],
//                      nil];
//    
//    NSArray *turn4 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:2],
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:7],
//                      [NSNumber numberWithInt:7],
//                      [NSNumber numberWithInt:6],
//                      nil];
//    NSArray *turn5 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:7],
//                      [NSNumber numberWithInt:7],
//                      [NSNumber numberWithInt:3],
//                      [NSNumber numberWithInt:3],
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:1],
//                      nil];
//    NSArray *turn6 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:0],
//                      [NSNumber numberWithInt:0],
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:2],
//                      [NSNumber numberWithInt:0],
//                      [NSNumber numberWithInt:7],
//                      nil];
//    NSArray *turn7 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:2],
//                      [NSNumber numberWithInt:3],
//                      [NSNumber numberWithInt:2],
//                      [NSNumber numberWithInt:0],
//                      [NSNumber numberWithInt:7],
//                      nil];
//    NSArray *turn8 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:2],
//                      [NSNumber numberWithInt:3],
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:5],
//                      [NSNumber numberWithInt:7],
//                      nil];
//    NSArray *turn9 = [[NSArray alloc] initWithObjects:
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:2],
//                      [NSNumber numberWithInt:3],
//                      [NSNumber numberWithInt:1],
//                      [NSNumber numberWithInt:7],
//                      [NSNumber numberWithInt:7],
//                      nil];
//    [turns addObject:turn1];
//    [turns addObject:turn2];
//    [turns addObject:turn3];
//    [turns addObject:turn4];
//    [turns addObject:turn5];
//    [turns addObject:turn6];
//    [turns addObject:turn7];
//    [turns addObject:turn8];
//    [turns addObject:turn9];
//    
//    for (int i = 0; i < turns.count; i++) {
//        Guess *result = [self makeResult:h guess:[turns objectAtIndex:i]];
//        BOOL correctGuess = true;
//        
//        for (int i = 0; i < patterns.count; i++) {
//            if (![self compareResult:[patterns objectAtIndex:i] res:result]){
//                correctGuess = false;
//                break;
//            }
//        }
//        
//        if (correctGuess) {
//            CCLOG(@"TEST ALGORITHM - CORRECT TURN AT ROW %i", i);
//        } else {
//            CCLOG(@"TEST ALGORITHM - BAD TURN AT ROW %i", i);
//        }
//        
//        [patterns addObject:result];
//    }
//    
//}

- (int) getBonus {
    int bonus;
    if (done) {
        bonus = (int)ceil(5000 / (10 - totalTurns)) * 100;
    } else {
        bonus = 0;
    }
    return bonus;
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