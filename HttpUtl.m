//
//  HtppUtl.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HttpUtl.h"

@implementation HttpUtl

+ (NSString *)httpGet:(NSString *)urlString
{
	return [self httpGet:urlString withEncoding:NSJapaneseEUCStringEncoding];
}

+ (NSString *)httpGet:(NSString *)urlString withEncoding:(NSInteger)encoding
{
	NSURL* url = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	[req setHTTPMethod:@"GET"];
	//[req setHTTPBody:[s dataUsingEncoding:encoding]];
	NSURLResponse *res;
	NSError* error = nil;
	NSData *result = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
	if (result == nil) {
		NSLog(@"%@", @"error");
	}
	
	
	NSString *html = [[NSString alloc] initWithData:result encoding:encoding];
	if (html == nil || [html length] == 0)
		NSLog(@"%@", @"error");
	
	
	return html;
}

+ (NSString *)httpPost:(NSString *)urlString postData:(NSDictionary *)data
{
	return [self httpPost:urlString postData:data withEncoding:NSJapaneseEUCStringEncoding];
}

+ (NSString *)httpPost:(NSString *)urlString postData:(NSDictionary *)data withEncoding:(NSInteger)encoding
{
	NSMutableString *s = [NSMutableString string];
	for (id key in data) {
		NSLog(@"key: %@, value: %@\n", key, [data objectForKey:key]);
		if ([s length] > 0)
			[s appendString:@"&"];
		
		[s appendFormat:@"%@=%@", key, [data objectForKey:key]];
	}
	
	NSURL* url = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	[req setHTTPMethod:@"POST"];
	[req setHTTPBody:[s dataUsingEncoding:encoding]];
	NSURLResponse *res;
	NSError* error = nil;
	NSData *result = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
	
	//if (res.statusCode != 200) {
	//	if (error) {
	//		NSLog(@"error = %@", error);
	//		return [NSString string];
	//	}
	//}
	
	NSString *html = [[NSString alloc] initWithData:result encoding:encoding];
	
	return html;
}

@end
