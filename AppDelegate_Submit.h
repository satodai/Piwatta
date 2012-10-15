//
//  AppDelegate_Submit.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface AppDelegate(Submit)

- (IBAction)onPrev:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onCancel:(id)sender;

- (void)switchPage:(NSInteger)page;

@end
