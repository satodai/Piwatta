//
//  AppDelegate_SplitView.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_SplitView.h"

@implementation AppDelegate(SplitView)

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	for (id view in [subview subviews]) {
		if ([view isKindOfClass:[NSSegmentedControl class]])
			return YES;
	}
	return NO;
}

@end
