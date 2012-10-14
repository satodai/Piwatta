//
//  AppDelegate_TextView.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_TextView.h"
#import "NSString_PwEditor.h"
#import "PwEditorDef.h"

@implementation AppDelegate(TextView)

- (void)textDidChange:(NSNotification *)aNotification
{
	NSInteger count = [[self.textView string] pweByteCount];
	NSNumber *curentByte = [NSNumber numberWithInteger:count];
	NSNumber *remainByte = [NSNumber numberWithInteger:MAX_BODY_LENGTH - count];
	NSNumber *exceeded = [NSNumber numberWithBool:[remainByte integerValue] < 0 ? YES : NO];
	
	[[self.appStatusController content] setValue:curentByte forKey:@"currentByte"];
	[[self.appStatusController content] setValue:remainByte forKey:@"remainByte"];
	[[self.appStatusController content] setValue:exceeded forKey:@"exceeded"];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:@"documentEdited"];
}

@end
