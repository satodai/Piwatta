//
//  DateFormatTransformer.m
//  PwEditorMac
//
//  Created by Daisuke Sato on 12/10/05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateFormatTransformer.h"

@implementation DateFormatTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
	return [formatter stringFromDate:value];
}

@end
