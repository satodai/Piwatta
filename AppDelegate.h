//
//  AppDelegate.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PWorld.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSSegmentedControl *segmentedControl;
@property (assign) IBOutlet NSWindow *submitWindow;

@property (assign) IBOutlet NSArrayController *documents;
@property (assign) IBOutlet NSArrayController *dbNames;
@property (assign) IBOutlet NSArrayController *topics;
@property (assign) IBOutlet NSArrayController *kijis;

@property (assign) IBOutlet NSObjectController *appStatus;
@property (assign) IBOutlet NSTabView *submitPanelTabView;


@property (assign) PWorld *pworld;

- (IBAction)onFileNew:(id)sender;
- (IBAction)onFileOpen:(id)sender;
- (IBAction)onFileSave:(id)sender;
- (IBAction)onFileSaveAs:(id)sender;
- (IBAction)onPageSelected:(id)sender;
- (IBAction)onAddPage:(id)sender;
- (IBAction)onRemovePage:(id)sender;
- (IBAction)dbNameSelected:(id)sender;
- (IBAction)onTopicSelected:(id)sender;
- (IBAction)onOpenTopic:(id)sender;
- (IBAction)onPrevPage:(id)sender;
- (IBAction)onNextPage:(id)sender;
- (IBAction)onReload:(id)sender;
- (IBAction)onSubmit:(id)sender;


@end
