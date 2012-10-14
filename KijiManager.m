//
//  kijiManager.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "kijiManager.h"
#import "PwEditorDef.h"
#import "PWorld.h"
#import "HttpUtl.h"
#import "NSString_PwEditor.h"

@implementation KijiManager

@synthesize prevPageNumber = _prevPageNumber;
@synthesize nextPageNumber = _nextPageNumber;
@synthesize canLoadPrevPage = _canLoadPrevPage;
@synthesize canLoadNextPage = _canLoadNextPage;

- (BOOL)loadKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp pageNumber:(NSInteger)pageNumber
{
	//NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	//[dic setObject:@"aaa" forKey:@"kijiNo"];
	//[dic setObject:@"bbb" forKey:@"title"];
	//[self.pworld.kijis addObject:(dic)];
	
	//self.pworld.loading = YES;
	self.pworld.errorCode = ERR_NONE;
	self.pworld.cancelFlag = NO;
	
	[[self.pworld.kijis content] removeAllObjects];
	
	_canLoadPrevPage = NO;
	_canLoadNextPage = NO;
	
	//NSString *dbNameValue = [self.pworld.dbName objectForKey:@"value"];
	//NSString *kijiGrp = [self.pworld.topic valueForKey:@"kijiGrp"];
	
	NSInteger maxPageNumber = _prevPageNumber = pageNumber;
	BOOL maxCounted = NO;
	NSInteger pagesToLoad = [[NSUserDefaults standardUserDefaults] integerForKey:PAGES_TO_LOAD];
	
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
			self.pworld.errorCode = ERR_PW_HTTPCOMM;
			return NO;
		}
		
		NSRange range = [html rangeOfString:@"連続アクセスは禁止されています"];
		if (range.location != NSNotFound) {
			self.pworld.errorCode = ERR_PW_RENZOKU;
			return NO;
		}
		
		if (_nextPageNumber == 1) {
			NSString *topicTitle = [html substringFromPattern:@"               <strong>" toPattern:@"\n"];
			topicTitle = [topicTitle stringByReplacingOccurrencesOfEscapeChar];
			
			html = [html substringFromPattern:@"               <strong>"];
			
			NSString *topicAuthor = [html substringFromPattern:@"<font size=\"3\"><strong><font color=#0000FF>" toPattern:@"<"];
			topicAuthor = [topicAuthor stringByReplacingOccurrencesOfEscapeChar];
			
			html = [html substringFromPattern:@"<font size=\"3\"><strong><font color=#0000FF>"];
			
			NSString *strYear = [html substringFromPattern:@"color=\"#000000\" size=\"2\">（" toPattern:@"<"];
			html = [html substringFromPattern:@"color=\"#000000\" size=\"2\">（"];
			
			NSString *strMonthTime = [html substringFromPattern:@"mono\">" toPattern:@"）"];
			NSString *dateStr = [NSString stringWithFormat:@"%@ %@", strYear, strMonthTime];
			NSDate *topicSubmittedTime = [dateStr dateValue];
			
			NSString *topicBody = [html substringFromPattern:@"bgcolor=\"#EEEEEE\">" toPattern:@"            </tr>"];
			topicBody = [topicBody stringByReplacingOccurrencesOfEscapeChar];
			
			NSMutableDictionary *topic = [[self.pworld.topics content] objectAtIndex:self.pworld.topics.selectionIndex];
			
			
			[topic setValue:topicTitle forKey:@"title"];
			[topic setValue:topicAuthor forKey:@"author"];
			[topic setValue:topicSubmittedTime forKey:@"submittedTime"];
			[topic setValue:topicBody forKey:@"body"];
			
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
			
			NSInteger displayNumber = 0;
			NSString *title = [NSString string];
			NSString *author = [NSString string];
			NSDate *submittedTime = nil;
			NSString *kijiNo = [NSString string];
			NSString *replyedTo = [NSString string];
			NSString *body = [NSString string];
			NSString *userNumber = [NSString string];
			NSString *iconPath = [NSString string];
			
			displayNumber = [html integerValueFromPattern:@"<td bgcolor=\"#F5E098\"><font size=\"3\"><strong>【" toPattern:@"】"];
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
			NSDictionary *kiji = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInteger:displayNumber], @"displayNumber",
				kijiNo, @"kijiNo",
				title, @"title",
				author, @"author",
				submittedTime, @"submittedTime",
				replyedTo, @"replyedTo",
				body, @"body",
				userNumber, @"userNumber",
				iconPath, @"iconPath",
				nil];
			
			//NSMutableDictionary *kiji = [NSMutableDictionary dictionary];
			//[kiji setValue:[NSNumber numberWithInteger:displayNumber] forKey:@"displayNumber"];
			//[kiji setValue:kijiNo forKey:@"kijiNo"];
			//[kiji setValue:title forKey:@"title"];
			//[kiji setValue:author forKey:@"author"];
			//[kiji setValue:submittedTime forKey:@"submittedTime"];
			//[kiji setValue:replyedTo forKey:@"replyedTo"];
			//[kiji setValue:body forKey:@"body"];
			//[kiji setValue:userNumber forKey:@"userNumber"];
			//[kiji setValue:iconPath forKey:@"iconPath"];
			
			[self.pworld.kijis addObject:kiji];
		}
		
		_canLoadPrevPage = _nextPageNumber - pagesToLoad > 0;
		_canLoadNextPage = _nextPageNumber < maxPageNumber;
	}
	
	
	
	return YES;
}

- (BOOL)loadPreviousPage:(NSString *)dbName kijiGrp:(NSString *)kijiGrp;
{
	NSInteger pagesToLoad = [[NSUserDefaults standardUserDefaults] integerForKey:PAGES_TO_LOAD];
	NSInteger page = _prevPageNumber - pagesToLoad;
	if (page < 1)
		page = 1;
	
	if (pagesToLoad != 1) {
		while (page % pagesToLoad != 1)
			page--;
	}
	
	return [self loadKiji:dbName kijiGrp:kijiGrp pageNumber:page];
}

- (BOOL)loadNextPage:(NSString *)dbName kijiGrp:(NSString *)kijiGrp;
{
	return [self loadKiji:dbName kijiGrp:kijiGrp pageNumber:_nextPageNumber];
}


@end
