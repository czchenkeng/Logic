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

@interface GameData : NSObject {

FMDatabase *db;
FMResultSet *rs;
    
}

- (void) writeScore:(int)score andDifficulty:(int)diff;
- (NSMutableArray *) getScores:(int)diff;

@end
