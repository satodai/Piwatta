//
//  TopicManager.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopicManager.h"
#import "PwEditorDef.h"
#import "PWorld.h"
#import "httpUtl.h"
#import "NSString_PwEditor.h"

@implementation TopicManager

- (BOOL)loadTopic:(NSString *)dbName
{
	self.pworld.errorCode = ERR_NONE;
	self.pworld.cancelFlag = NO;
	
	
	
	NSString *urlString = [NSString stringWithFormat:@"http://www.p-world.co.jp/community/message.cgi?dbname=%@", dbName];
	NSString *html = [HttpUtl httpGet:urlString];
	
	NSRange range = [html rangeOfString:@"連続アクセスは禁止されています"];
	if (range.location != NSNotFound) {
		self.pworld.errorCode = ERR_PW_RENZOKU;
		return NO;
	}
	
	//NSString *key = [NSString stringWithFormat:@"<a href=\"message.cgi?pg_no=2&dbname=%@\">", dbName];
	//NSString *s = [html substringFromPattern:key toPattern:@"<"];
	NSString *s = [html substringFromPattern:@"【" toPattern:@"】"];
	NSInteger maxPageNumber = [s integerValue];
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
			self.pworld.errorCode = ERR_PW_RENZOKU;
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
			 [NSNumber numberWithInteger:number], @"number",
			 kijiGrp, @"kijiGrp",
			 title, @"title",
			 lastSubmittedTime, @"lastSubmittedTime",
			 [NSNumber numberWithInteger:kijiCount], @"kijiCount",
			 nil];
			
			[self.pworld.topics addObject:topic];
			
			number++;
			range = [html rangeOfString:@"<td align=\"right\"><font size=\"2\">【"];
		}
	}
	
	return YES;
}

@end
