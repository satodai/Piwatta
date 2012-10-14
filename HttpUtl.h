//
//  HtppUtl.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PwManager.h"

@interface HttpUtl : PwManager

+ (NSString *)httpGet:(NSString *)urlString;
+ (NSString *)httpGet:(NSString *)urlString withEncoding:(NSInteger)encoding;
+ (NSString *)httpPost:(NSString *)urlString postData:(NSDictionary *)data;
+ (NSString *)httpPost:(NSString *)urlString postData:(NSDictionary *)data withEncoding:(NSInteger)encoding;

@end
