//
//  PWorld.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PWorld.h"

@implementation PWorld

@synthesize errorCode = _errorCode;
@synthesize cancelFlag = _cancelFlag;
@synthesize dbNames = _dbNames;
@synthesize topics = _topics;
@synthesize kijis = _kijis;

@synthesize dbNameManager = _dbNameManager;
@synthesize topicManager = _topicManager;
@synthesize kijiManager = _kijiManager;

- (id)initWithDbNameArray:(NSArrayController *)dbNames topicArray:(NSArrayController *)topics kijiArray:(NSArrayController *)kijis
{
	self = [super init];
	if (self) {
		_dbNames = dbNames;
		_topics = topics;
		_kijis = kijis;
		_dbNameManager = [[DbNameManager alloc] initWithPWorld:self];
		_topicManager = [[TopicManager alloc] initWithPWorld:self];
		_kijiManager = [[KijiManager alloc] initWithPWorld:self];
	}
	return self;
}

- (BOOL)loadDbName
{
	return [_dbNameManager loadDbName];
}

- (BOOL)loadTopic:(NSString *)dbName
{
	return [_topicManager loadTopic:dbName];
}

- (BOOL)loadKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp pageNumber:(NSInteger)pageNumber
{
	return [_kijiManager loadKiji:dbName kijiGrp:kijiGrp pageNumber:pageNumber];
}

@end
