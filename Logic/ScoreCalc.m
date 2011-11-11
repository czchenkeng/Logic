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
        time = 0;
        saveData = [[NSMutableArray alloc] init];
        
        patterns = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id) scoreWithColors:(int)c pins:(int)p row:(int)r {
    return [[[self alloc] initWithColors:(int)c pins:(int)p row:(int)r] autorelease];
}

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
    
    return guessResult;
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

- (BOOL) compareResult:(Guess *)oldGuess res:(Guess *)newGuess {
    Guess *result = [self makeResult:oldGuess.pattern guess:newGuess.pattern];
    return result.resultInPosition == oldGuess.resultInPosition && result.resultOutOfPosition == oldGuess.resultOutOfPosition;
}


- (int) calculateScoreWithRow:(int)row andTurn:(NSArray *)turn andTime:(int)roundTime andTotalTime:(int)totalTime{
    totalTurns = row;
    
    time = totalTime;
    
    points = 0;
    
    int k1 = 1000; //koeficient spravneho tahu
    int k2 = 1000; //bonus za dvojice v prvnim tahu
    int k3 = 800; //koeficient casu spravneho tahu
    int k4 = 600; //koeficient casu nespravneho tahu
    int k5 = 200; //koeficient nespravneho tahu
    
    //int endBonusConst = 5000;
    
    if (row == 0 && [self hasDoubles:turn]) {
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
        points += k5 / (row + 1) + k4 / (roundTime + 1);
    }
    
    if (row == 0)
        points = (int)ceil(points/2);
    
    if (result.resultInPosition == pinsCount) {
        done = YES;
    }
    
    [patterns addObject:result];
    
    [saveData addObject:turn];
    
    [[GameManager sharedGameManager] savePattern:saveData];
    
    return points;
}

- (int) getBonus {
    int bonus;
    if (done) {
        float bonusConst;
        switch ([hiddenPattern count]) {
            case 4:
                bonusConst = 1.34;
                break;
            case 5:
                bonusConst = 1.196;
                break;
            case 6:
                bonusConst = 1.137;
                break;
            default:
                break;
        }
        //bonus = (int)floor( 100000 * ( 1/pow(sqrt(bonusConst), time) ) );
        bonus = (int)floor( 100000 * ( 1/pow(pow(bonusConst, 0.02), time) ) );
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