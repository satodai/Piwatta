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
@property (assign) NSArrayController *dbNames;
@property (assign) NSArrayController *topics;
@property (assign) NSArrayController *kijis;

@property (assign) DbNameManager *dbNameManager;
@property (assign) TopicManager *topicManager;
@property (assign) KijiManager *kijiManager;

- (id)initWithDbNameArray:(NSArrayController *)dbNames topicArray:(NSArrayController *)topics kijiArray:(NSArrayController *)kijis;

- (BOOL)loadDbName;
- (BOOL)loadTopic:(NSString *)dbName;
- (BOOL)loadKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp pageNumber:(NSInteger)pageNumber;

@end
