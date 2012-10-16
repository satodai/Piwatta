//
//  PWorld.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PWorld.h"
#import "PwEditor.h"
#import "NSString_Pwe.h"

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
@synthesize prevPageNumber = _prevPageNumber;
@synthesize nextPageNumber = _nextPageNumber;
@synthesize canLoadPrevPage = _canLoadPrevPage;
@synthesize canLoadNextPage = _canLoadNextPage;
@synthesize dbNames = _dbNames;
@synthesize topics = _topics;
@synthesize kijis = _kijis;

@synthesize topicManager = _topicManager;
@synthesize kijiManager = _kijiManager;

- (id)initWithDbNameArray:(NSArrayController *)dbNames topicArray:(NSArrayController *)topics kijiArray:(NSArrayController *)kijis
{
	self = [super init];
	if (self) {
		_dbNames = dbNames;
		_topics = topics;
		_kijis = kijis;
		_topicManager = [[TopicManager alloc] initWithPWorld:self];
		_kijiManager = [[KijiManager alloc] initWithPWorld:self];
	}
	
	return self;
}

- (BOOL)loadDbName
{
	for (NSInteger i = 0; g_dbNames[i][0] != nil; i++) {
		NSMutableDictionary *dbName = [NSMutableDictionary dictionary];
		[dbName setObject:g_dbNames[i][0] forKey:CBKEY_DBNAME_LABEL];
		[dbName setObject:g_dbNames[i][1] forKey:CBKEY_DBNAME_VALUE];
		[_dbNames addObject:dbName];
	}
	
	return YES;
}

- (BOOL)loadTopic:(NSString *)dbName
{
	_errorCode = ERR_NONE;
	_cancelFlag = NO;
	
	NSString *urlString = [NSString stringWithFormat:@"http://www.p-world.co.jp/community/message.cgi?dbname=%@", dbName];
	NSString *html = [HttpUtl httpGet:urlString];
	
	NSRange range = [html rangeOfString:@"連続アクセスは禁止されています"];
	if (range.location != NSNotFound) {
		_errorCode = ERR_PW_RENZOKU;
		return NO;
	}
	
	NSString *str = [html substringFromPattern:@"【" toPattern:@"】"];
	NSInteger maxPageNumber = [str integerValue];
	if (maxPageNumber == 0)
		maxPageNumber = 1;
	
	NSInteger number = 0;
	for (NSInteger i = 1; i <= maxPageNumber; i++) {
		if (self.pworld.cancelFlag)
			return NO;
		
		NSString *urlString = [NSString stringWithFormat:@"http://www.p-world.co.jp/community/message.cgi?pg_no=%d&dbname=%@", i, dbName];
		html = [HttpUtl httpGet:urlString];
		
		range = [html rangeOfString:@"連続アクセスは禁止されています"];
		if (range.location != NSNotFound) {
			_errorCode = ERR_PW_RENZOKU;
		    return NO;
		}
		
		range = [html rangeOfString:@"<td align=\"right\"><font size=\"2\">【"];
		while (range.location != NSNotFound) {
			// 終了したトピック一覧より下にあるものは除外
			NSRange endpos = [html rangeOfString:@"<b>&nbsp;■終了したトピック</b>　（返信できません）"];
			if (endpos.location != NSNotFound && range.location > endpos.location) {
				i = maxPageNumber;
				break;
			}
			
			NSString *dateStr = [html  substringFromPattern:@"<td align=\"right\"><font size=\"2\">【" toPattern:@"】"];
			html = [html substringFromPattern:@"<td align=\"right\"><font size=\"2\">【"];
			NSString *timeStr = [html substringFromPattern:@"<td align=\"right\"><font size=\"2\">" toPattern:@"<"];
			NSString *datetimeStr = [NSString stringWithFormat:@"%@ %@", dateStr, timeStr];
			NSDate *lastSubmittedTime = [datetimeStr dateValue];
			
			NSString *kijiGrp = [html substringFromPattern:@"<a href=\"keiziban2disp.cgi?mode=kiji&kiji_grp=" toPattern:@"&"];
			
			html = [html substringFromPattern:@"<a href=\"keiziban2disp.cgi?mode=kiji&kiji_grp="];
			NSString *title = [html substringFromPattern:@"<font size=\"3\">" toPattern:@"<"];
			title = [title stringByReplacingOccurrencesOfEscapeChar];
			
			NSInteger kijiCount = [html integerValueFromPattern:@"<font size=\"2\">(" toPattern:@"件"];
			
			NSMutableDictionary *topic =
				[NSMutableDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInteger:number], CBKEY_TOPIC_NUMBER,
					kijiGrp,  CBKEY_TOPIC_KIJIGRP,
					title,  CBKEY_TOPIC_TITLE,
					lastSubmittedTime,  CBKEY_TOPIC_LASTSUBMITTEDTIME,
					[NSNumber numberWithInteger:kijiCount],CBKEY_TOPIC_KIJICOUNT,
					nil];
			
			[_topics addObject:topic];
			
			number++;
			range = [html rangeOfString:@"<td align=\"right\"><font size=\"2\">【"];
		}
	}
	
	return YES;
}

- (BOOL)loadKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp pageNumber:(NSInteger)pageNumber
{
	_errorCode = ERR_NONE;
	_cancelFlag = NO;
	
	_canLoadPrevPage = NO;
	_canLoadNextPage = NO;
	
	NSInteger maxPageNumber = _prevPageNumber = pageNumber;
	BOOL maxCounted = NO;
	NSInteger pagesToLoad = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_PAGESTOLOAD];
	
	NSLog(@"pagesToLoad=<%ld>", pagesToLoad);
	
	for (_nextPageNumber = pageNumber; _nextPageNumber < pageNumber + pagesToLoad && _nextPageNumber <= maxPageNumber; _nextPageNumber++) {
		if (self.pworld.cancelFlag)
			return NO;
		
		NSString *urlString =
			[NSString stringWithFormat:@"http://www.p-world.co.jp/community/keiziban2disp.cgi?mode=kiji&pg_no=%d&kiji_grp=%@&dbname=%@",
				_nextPageNumber,
				kijiGrp,
				dbName];
		
		NSLog(@"%@", urlString);
		NSString *html = [HttpUtl httpGet:urlString];
		
		if (html == nil || [html isEqualToString:@""]) {
			_errorCode = ERR_PW_HTTPCOMM;
			return NO;
		}
		
		NSRange range = [html rangeOfString:@"連続アクセスは禁止されています"];
		if (range.location != NSNotFound) {
			_errorCode = ERR_PW_RENZOKU;
			return NO;
		}
		
		if (_nextPageNumber == 1) {
			NSString *topicTitle;
			NSString *topicAuthor;
			NSDate *topicSubmittedTime;
			NSString *topicBody;
			
			topicTitle = [html substringFromPattern:@"               <strong>" toPattern:@"\n"];
			topicTitle = [topicTitle stringByReplacingOccurrencesOfEscapeChar];
			
			html = [html substringFromPattern:@"               <strong>"];
			
			topicAuthor = [html substringFromPattern:@"<font size=\"3\"><strong><font color=#0000FF>" toPattern:@"<"];
			topicAuthor = [topicAuthor stringByReplacingOccurrencesOfEscapeChar];
			
			html = [html substringFromPattern:@"<font size=\"3\"><strong><font color=#0000FF>"];
			
			NSString *strYear = [html substringFromPattern:@"color=\"#000000\" size=\"2\">（" toPattern:@"<"];
			html = [html substringFromPattern:@"color=\"#000000\" size=\"2\">（"];
			
			NSString *strMonthTime = [html substringFromPattern:@"mono\">" toPattern:@"）"];
			NSString *dateStr = [NSString stringWithFormat:@"%@ %@", strYear, strMonthTime];
			NSDate *topicSubmittedTime = [dateStr dateValue];
			
			topicBody = [html substringFromPattern:@"bgcolor=\"#EEEEEE\">" toPattern:@"            </tr>"];
			topicBody = [topicBody stringByReplacingOccurrencesOfEscapeChar];
			
			NSMutableDictionary *topic = [[_topics content] objectAtIndex:[_topics selectionIndex]];
			[topic setValue:topicTitle forKey:CBKEY_TOPIC_TITLE];
			[topic setValue:topicAuthor forKey:CBKEY_TOPIC_AUTHOR];
			[topic setValue:topicSubmittedTime forKey:CBKEY_TOPIC_SUBMITTEDTIME];
			[topic setValue:topicBody forKey:CBMEY_TOPIC_BODY];
			
            html = [html substringFromPattern:@"bgcolor=\"#EEEEEE\">"];
			html = [html substringFromPattern:@"            </tr>"];
		}
		
		while ([html length] > 0) {
			if (!maxCounted) {
				range = [html rangeOfString:@"      <td width=\"50%\">■ "];
				if (range.location != NSNotFound) {
					NSInteger kijiCount = [html integerValueFromPattern:@"      <td width=\"50%\">■ " toPattern:@"件"];
					html = [html substringFromPattern:@"      <td width=\"50%\">■ "];
					maxPageNumber = kijiCount / 10;
					if (kijiCount % 10 != 0)
						maxPageNumber++;
				}
				maxCounted = YES;
			}
			
			range = [html rangeOfString:@"<td bgcolor=\"#F5E098\"><font size=\"3\"><strong>【"];
			if (range.location == NSNotFound)
				break;
			
			NSNumber displayNumber;
			NSString *title;
			NSString *author;
			NSDate *submittedTime;
			NSString *kijiNo;
			NSString *replyedTo;
			NSString *body;
			NSString *userNumber;
			NSString *iconPath;
			
			NSInteger dispNum = [html integerValueFromPattern:@"<td bgcolor=\"#F5E098\"><font size=\"3\"><strong>【" toPattern:@"】"];
			displayNumber = [NSNumber numberWithInteger:dispNum];
			html = [html substringFromPattern:@"<td bgcolor=\"#F5E098\"><font size=\"3\"><strong>【"];
			
			NSRange posNext = [html rangeOfString:@"<font size=\"3\">               "];
			NSRange iconPathPos = [html rangeOfString:@"<td bgcolor=\"#F5E098\"><img align=\"left\" src=."];
			if (iconPathPos.location != NSNotFound && iconPathPos.location < posNext.location) {
				NSString *s = [html substringFromPattern:@"<td bgcolor=\"#F5E098\"><img align=\"left\" src=." toPattern:@">"];
				iconPath = [NSString stringWithFormat:@"http://www.p-world.co.jp/community%@", s];
			}
			
			html = [html substringFromPattern:@"<font size=\"3\">               "];
			
			BOOL deleted = NO;
			if (![html hasPrefix:@"<b>"])
				deleted = true;
			
			if (deleted) {
				title = [html substringFromPattern:@"color=\"#A0A0A0\">" toPattern:@"</font>"];
				html = [html substringFromPattern:@"color=\"#A0A0A0\">"];
			}
			else {
				title = [html substringFromPattern:@"<b>" toPattern:@"</b>"];
				html = [html substringFromPattern:@"</b>"];
				NSRange p1 = [html rangeOfString:@"<a href=keiziban2prodisp.cgi?userno="];
				NSRange p2 = [html rangeOfString:@"                <strong><font color=#0000FF>"];
				if (p1.location < p2.location)
					userNumber = [html substringFromPattern:@"<a href=keiziban2prodisp.cgi?userno=" toPattern:@">"];
			}
			
			author = [html substringFromPattern:@"                <strong><font color=#0000FF>" toPattern:@"<"];
			author = [author stringByReplacingOccurrencesOfEscapeChar];
			html = [html substringFromPattern:@"                <strong><font color=#0000FF>"];
			
			NSString *strYear = [html substringFromPattern:@"                color=\"#000000\" size=\"2\">(" toPattern:@"<"];
			NSString *strMonthTime = [html substringFromPattern:@"mono\">" toPattern:@")"];
			NSString *dateStr = [NSString stringWithFormat:@"%@ %@", strYear, strMonthTime];
			submittedTime = [dateStr dateValue];
			
			html = [html substringFromPattern:@"mono\">"];
			
			if (!deleted) {
				kijiNo = [html substringFromPattern:@"<INPUT TYPE=\"hidden\" NAME=\"kiji_no\" VALUE=\"" toPattern:@"\""];
				html = [html substringFromPattern:@"<INPUT TYPE=\"hidden\" NAME=\"kiji_no\" VALUE=\""];
				replyedTo = [html substringFromPattern:@"><font size=\"2\">【" toPattern:@"】"];
				html = [html substringFromPattern:@"><font size=\"2\">"];
				html = [html substringFromPattern:@"><font size=\"2\">"];
				body = [html substringFromPattern:@", mono\">" toPattern:@"                </font></td>"];
			}
			else {
				body = [html substringFromPattern:@"color=\"#A0A0A0\">" toPattern:@"</font>"];
			}
			body = [body stringByReplacingOccurrencesOfEscapeChar];
			
			html = [html substringFromPattern:@"                </font></td>"];
			
			NSLog(@"%ld", displayNumber);
			NSDictionary *kiji =
				[NSDictionary dictionaryWithObjectsAndKeys:
					displayNumber, CBKEY_KIJI_DISPLAYNUMBER,
					kijiNo,  CBKEY_KIJI_KIJINO,
					title,  CBKEY_KIJI_TITLE,
					author,  CBKEY_KIJI_AUTHOR,
					submittedTime,  CBKEY_KIJI_SUBMITTEDTIME,
					replyedTo,  CBKEY_KIJI_REPLYEDTO,
					body,  CBKEY_KIJI_BODY,
					userNumber,  CBKEY_KIJI_USERNO,
					iconPath,  CBKEY_KIJI_ICONPATH,
					nil];
			
			[_kijis addObject:kiji];
		}
		
		_canLoadPrevPage = _nextPageNumber - pagesToLoad > 0;
		_canLoadNextPage = _nextPageNumber < maxPageNumber;
	}
	
	return YES;
}

- (BOOL)loadPreviousKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp;
{
	NSInteger pagesToLoad = [[NSUserDefaults standardUserDefaults] integerForKey:UDKEY_PAGESTOLOAD];
	NSInteger page = _prevPageNumber - pagesToLoad;
	if (page < 1)
		page = 1;
	
	if (pagesToLoad != 1) {
		while (page % pagesToLoad != 1)
			page--;
	}
	
	return [self loadKiji:dbName kijiGrp:kijiGrp pageNumber:page];
}

- (BOOL)loadNextKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp;
{
	return [self loadKiji:dbName kijiGrp:kijiGrp pageNumber:_nextPageNumber];
}

@end
