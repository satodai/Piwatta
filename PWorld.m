//
//  PWorld.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PWorld.h"

static const NSString *g_dbNames[][2] = {
	{@"談話室", @"etc"},
	{@"業界/行政問題", @"gyoukai"},
	{@"パチンコ", @"pachi"},
	{@"パチスロ", @"slot"},
	{@"北海道/東北", @"touhoku"},
	{@"北海道", @"touhoku/hokkaido"},
	{@"青森県", @"touhoku/aomori"},
	{@"岩手県", @"touhoku/iwate"},
	{@"宮城県", @"touhoku/miyagi"},
	{@"山形県", @"touhoku/yamagata"},
	{@"秋田県", @"touhoku/akita"},
	{@"福島県", @"touhoku/fukushima"},
	{@"関東", @"kantou"},
	{@"茨城県", @"kantou/ibaraki"},
	{@"栃木県", @"kantou/tochigi"},
	{@"群馬県", @"kantou/gunma"},
	{@"埼玉県", @"kantou/saitama"},
	{@"千葉県", @"kantou/chiba"},
	{@"東京都", @"kantou/tokyo"},
	{@"神奈川県", @"kantou/kanagawa"},
	{@"中部", @"chyuubu"},
	{@"山梨県", @"chyuubu/yamanashi"},
	{@"長野県", @"chyuubu/nagano"},
	{@"新潟県", @"chyuubu/niigata"},
	{@"富山県", @"chyuubu/toyama"},
	{@"石川県", @"chyuubu/ishikawa"},
	{@"福井県", @"chyuubu/fukui"},
	{@"岐阜県", @"chyuubu/gifu"},
	{@"静岡県", @"chyuubu/shizuoka"},
	{@"愛知県", @"chyuubu/aichi"},
	{@"近畿", @"kinki"},
	{@"三重県", @"kinki/mie"},
	{@"滋賀県", @"kinki/shiga"},
	{@"京都府", @"kinki/kyoto"},
	{@"大阪府", @"kinki/osaka"},
	{@"兵庫県", @"kinki/hyogo"},
	{@"奈良県", @"kinki/nara"},
	{@"和歌山県", @"kinki/wakayama"},
	{@"中国/四国", @"chyuugoku"},
	{@"鳥取県", @"chyuugoku/tottri"},
	{@"島根県", @"chyuugoku/shimane"},
	{@"岡山県", @"chyuugoku/okayama"},
	{@"広島県", @"chyuugoku/hiroshima"},
	{@"山口県", @"chyuugoku/yamaguchi"},
	{@"徳島県", @"chyuugoku/tokushima"},
	{@"香川県", @"chyuugoku/kagawa"},
	{@"愛媛県", @"chyuugoku/ehime"},
	{@"高知県", @"chyuugoku/kochi"},
	{@"九州/沖縄", @"kyuusyuu"},
	{@"福岡県", @"kyuusyuu/fukuoka"},
	{@"佐賀県", @"kyuusyuu/saga"},
	{@"長崎県", @"kyuusyuu/nagasaki"},
	{@"熊本県", @"kyuusyuu/kumamoto"},
	{@"大分県", @"kyuusyuu/oita"},
	{@"宮崎県", @"kyuusyuu/miyazaki"},
	{@"鹿児島県", @"kyuusyuu/kagoshima"},
	{@"沖縄県", @"kyuusyuu/okinawa"},
	{nil, nil}
};

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
		//_dbNameManager = [[DbNameManager alloc] initWithPWorld:self];
		_topicManager = [[TopicManager alloc] initWithPWorld:self];
		_kijiManager = [[KijiManager alloc] initWithPWorld:self];
		
		for (int i = 0; g_dbNames[i][0] != nil; i++) {
			NSMutableDictionary *dbName = [NSMutableDictionary dictionary];
			[dbName setObject:g_dbNames[i][0] forKey:CBKEY_DBNAMELABEL];
			[dbName setObject:g_dbNames[i][1] forKey:CBKEY_DBNAMEVALUE];
			[_dbNames addObject:dbName];
		}
		[_dbNames setSelectionIndex:0];
	}
	return self;
}

//- (BOOL)loadDbName
//{
//	return [_dbNameManager loadDbName];
//}

- (BOOL)loadTopic:(NSString *)dbName
{
	return [_topicManager loadTopic:dbName];
}

- (BOOL)loadKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp pageNumber:(NSInteger)pageNumber
{
	return [_kijiManager loadKiji:dbName kijiGrp:kijiGrp pageNumber:pageNumber];
}

@end
