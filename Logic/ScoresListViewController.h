//
//  ScoresListViewController.h
//  Logic
//
//  Created by Pavel Krusek on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreCell.h"


@interface ScoresListViewController : UITableViewController {
    NSMutableArray *scores;
}

@property (nonatomic, retain, readwrite) NSMutableArray *scores;

- (void) removeScores;

@end
