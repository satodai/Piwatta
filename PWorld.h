//
//  PWorld.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DbNameManager.h"
#import "TopicManager.h"
#import "kijiManager.h"

@interface PWorld : NSObject

@property (assign) NSInteger errorCode;
@property (assign) BOOL cancelFlag;
@property (assign) NSInteger prevPageNumber;
@property (assign) NSInteger nextPageNumber;
@property (assign) BOOL canLoadPrevPage;
@property (assign) BOOL canLoadNextPage;
@property (assign) NSArrayController *dbNames;
@property (assign) NSArrayController *topics;
@property (assign) NSArrayController *kijis;


- (id)initWithDbNameArray:(NSArrayController *)dbNames topicArray:(NSArrayController *)topics kijiArray:(NSArrayController *)kijis;

- (BOOL)loadDbName;
- (BOOL)loadTopic:(NSString *)dbName;
- (BOOL)loadKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp pageNumber:(NSInteger)pageNumber;

@end
