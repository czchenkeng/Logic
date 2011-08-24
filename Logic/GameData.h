//
//  GameData.h
//  Logic
//
//  Created by Pavel Krusek on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Figure.h"

@interface GameData : NSObject {

FMDatabase *db;
FMResultSet *rs;
    
}
//score
- (void) writeScore:(int)score andDifficulty:(int)diff;
- (NSMutableArray *) getScores:(int)diff;
- (int) getMaxScore:(int)diff;

//game settings
- (void) updateSettingsWithDifficulty:(int)diff andMusicLevel:(float)music andSoundLevel:(float)sound;
- (settings) getSettings;

//truncate game data tables
- (void) gameDataCleanup;

- (BOOL) isActiveGame;

//write game data
- (void) insertGameData:(gameInfo)data;
- (void) insertDeadFigure:(deadFigure)figure;
- (void) insertActiveFigure:(activeFigure)figure;
- (void) insertRow:(gameRow)row;
- (void) insertCode:(int)code;

- (void) deleteActiveFigure:(int)place;
- (void) deleteActiveFigures;

//- (void) updateActiveFigure:(int)oldPlace withPlace:(int)newPlace andPosition:(CGPoint)pos;
- (void) updateActiveFigure:(int)fid withPlace:(int)newPlace andPosition:(CGPoint)pos;
- (void) updateActiveFigurePosition:(int)place andPosition:(CGPoint)pos;

//read game data
- (gameInfo) getGameData;
- (NSMutableArray *) getDeadFigures;
- (NSMutableArray *) getActiveFigures;
- (NSMutableArray *) getRows;
- (NSMutableArray *) getCode;

//write career
- (void) insertCareerData:(int)city xPos:(float)xPos yPos:(float)yPos;
- (void) updateCareerData:(BOOL)flag andScore:(int)score;

//read career
- (NSMutableArray *) getCareerData;
- (city) getCityInProgress;
- (city) getLastCity;
- (void) updateCarrerLastCity;

//delete career
- (void) resetCareer;


@end
