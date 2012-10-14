//
//  NSString_PwEditor.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString_PwEditor.h"

@implementation NSString(PwEditor)

- (NSString *)substringFromPattern:(NSString *)pattern
{
	NSRange range = [self rangeOfString:pattern];
	if (range.location == NSNotFound)
		return [NSString string];
    
	return [self substringFromIndex:range.location + range.length];
}

- (NSString *)substringFromPattern:(NSString *)openPattern toPattern:(NSString *)closePattern
{
	NSRange range = [self rangeOfString:openPattern];
	if (range.location == NSNotFound)
		return [NSString string];
	
    NSString *temp = [self substringFromIndex:range.location + range.length];
	range = [temp rangeOfString:closePattern];
	if (range.location == NSNotFound)
		return [NSString string];
	
	return [temp substringToIndex:range.location];
}

- (NSInteger)integerValueFromPattern:(NSString *)openPattern toPattern:(NSString *)closePattern
{
	NSString *temp = [self substringFromPattern:openPattern toPattern:closePattern];
	return [temp integerValue];
}

- (NSDate *)dateValue
{
	NSString *s = [self stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	s = [s stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	s = [s stringByReplacingOccurrencesOfString:@"日" withString:@""];
	s = [s stringByReplacingOccurrencesOfString:@"時" withString:@":"];
	s = [s stringByReplacingOccurrencesOfString:@"分" withString:@""];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
	NSDate *date = [formatter dateFromString:s];
	
	return date;
}

- (NSString *)stringByReplacingOccurrencesOfEscapeChar
{
    NSString *str = [self stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
	
    str = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    str = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    str = [str stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    str = [str stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    str = [str stringByReplacingOccurrencesOfString:@"&#96;" withString:@"｀"];
	str = [str stringByReplacingOccurrencesOfString:@"&#44;" withString:@","];
	
    return str;
}

- (NSInteger)pweByteCount
{
	NSInteger len = 0;
	const char *p = [self cStringUsingEncoding:NSJapaneseEUCStringEncoding];
	if (p) {
		len = strlen(p);
		while (*p != '\0') {
			switch (*p) {
			case '>':
			case '<':
			case '\n':
				len += 3;
				break;
			case ',':
				len += 4;
				break;
        	}
        	p++;
    	}
	}
    
    return len;
}

@end
