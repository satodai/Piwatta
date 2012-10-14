//
//  PwManager.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PwManager.h"

@implementation PwManager

@synthesize pworld = _pworld;

- (id)initWithPWorld:(PWorld *)pworld
{
	self = [super init];
	if (self) {
		_pworld = pworld;
	}
	return self;
}

@end
