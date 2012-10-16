//
//  AppDelegate_Misc.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_Misc.h"
#import "PwEditorDef.h"
#import "NSString_PwEditor.h"

@implementation AppDelegate(Misc)

- (BOOL)showSaveAsPanel
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setDirectory:[self.appStatus valueForKey:CBKEY_APPSTATUS_DIRECTORYNAME]];
	//[savePanel setNameFieldLabel:@"名前："];
	[savePanel setNameFieldStringValue:[[self.appStatus content] valueForKey:CBKEY_APPSTATUS_FILENAME]];
		[savePanel beginSheetModalForWindow:self.window completionHandler:
		 ^(NSInteger result) {
			 if (result == NSFileHandlingPanelOKButton) {
				NSString *fullPath = [savePanel fileName];
				NSString fileName = [fullPath lastPathComponet];
				[self.appStatus setValue:fileName forKey:CBKEY_APPSTATUS_FILENAME];
				NSRange range = [fullPath rangeOfString:fileName];
				if (range.location != NSNotFound) {
					NSString directoryName = [fullPath substringToIndex:range.location];
					[self.appStatus setValue:directoryName forKey:CBKEY_APPSTATUS_DIRECTORYNAME];
				}
				return YES;
			 }
		}];
	
	return NO;
}

- (void)synchronizeSegmentedControl
{
	NSInteger documentCount = [[self.documents content] count];
	[self.segmentedControl setSegmentCount:documentCount];
	
	NSInteger width = [self.segmentedControl widthForSegment:0];
	NSInteger count = [self.segmentedControl segmentCount];
	for (NSInteger i = 0; i < count; i++) {
		[self.segmentedControl setWidth:width forSegment:i];
		[self.segmentedControl setLabel:[NSString stringWithFormat:@"%ld", i + 1] forSegment:i];
	}
	
	[self.segmentedControl sizeToFit];
	
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:(documentCount < MAX_DOCUMENT_COUNT) ? YES : NO] forKey:CBKEY_APPSTATUS_CANADDPAGE];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:(documentCount > 1) ? YES : NO] forKey:CBKEY_APPSTATUS_CANREMOVEPAGE];
}

- (void)synchronizeCount
{
	NSInteger count = [[self.textView string] pweByteCount];
	BOOL exceeded = ([remainByte integerValue] < 0) ? YES : NO;
	[[self.appStatusController content] setValue:[NSNumber numberWithInteger:count] forKey:CBKEY_APPSTATUS_CURRENTBYTE];
	[[self.appStatusController content] setValue:[NSNumber numberWithInteger:MAX_BODY_LENGTH - count] forKey:CBKEY_APPSTATUS_REMAINBYTE];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:exceeded] forKey:CBKEY_APPSTATUS_EXCEEDED];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:CBKEY_APPSTATUS_DOCUMENTEDITED];
}

- (void)showSubmitSheet:(NSWindow *)window
{
	[NSApp beginSheet:self.submitSheet modalForWindow:window modalDelegate:self didEndSelector:@selector(submitSheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

- (IBAction)closeSubmitSheet:(id)sender
{
    [NSApp endSheet:self.submitSheet];
}


- (void)appFinishAlertSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[[alert window] orderOut:self];
	
	switch (returnCode) {
		case NSAlertFirstButtonReturn:
			NSLog(@"NSAlertFirstButtonReturn");
			if ([self showSaveAsPanel]) {
				NSString directoryName = [self.appStatus valueForKey:CBKEY_APPSTATUS_DIRECTORYNAME];
				NSString *fullPath = [directoryName stringByAppendingPathComponent:[self.appStatus valueForKey:CBKEY_APPSTATUS_FILENAME]];
				[self saveToFile:fullPath];
				[NSApp terminate:self];
			}
			break;
			
		case NSAlertSecondButtonReturn:
			NSLog(@"NSAlertSecondButtonReturn");
			break;
			
		case NSAlertThirdButtonReturn:
			NSLog(@"NSAlertThirdButtonReturn");
			[[self.appStatus content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_DOCUMENTEDITED];
			[NSApp terminate:self];
			break;
	}
}

- (void)submitSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
}

- (void)saveToFile:(NSString *)fileName
{
	[NSKeyedArchiver archiveRootObject:[self.documentArrayController content] toFile:fileName];
	[[self.appStatusController content] setValue:fileName forKey:@"fileName"];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"documentEdited"];
}

- (void)loadTopic
{
	[NSThread detachNewThreadSelector:@selector(loadTopicThread:) toTarget:self withObject:nil];
}

- (void)loadKiji
{
	[NSThread detachNewThreadSelector:@selector(laodKijiThread:) toTarget:self withObject:[NSNumber numberWithInteger:0]];
}

- (void)loadPrevKiji
{
	[NSThread detachNewThreadSelector:@selector(laodKijiThread:) toTarget:self withObject:[NSNumber numberWithInteger:-1]];
}

- (void)loadNextKiji
{
	[NSThread detachNewThreadSelector:@selector(laodKijiThread:) toTarget:self withObject:[NSNumber numberWithInteger:1]];
}

- (void)submit
{
	[NSApp beginSheet:_submitWindow modalForWindow:_window modalDelegate:self didEndSelector:@selector(submitSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)prePareSubmit:(BOOL)isSubmitToTopic
{
	[NSThread detachNewThreadSelector:@selecter(prepareSubmitThread) toTarget:self withObject:[NSNumber numberWithBool:isSubmitToTopic]];
}

- (void)submit:(BOOL)isSubmitToTopic
{
	
	//[NSThread detachNewThreadSelector:@selecter(submitThread) toTarget:self withObject:[NSNumber numberWithBool:isSubmitToTopic]];
}

- (void)loadTopicThread:(id)param
{
	[[self.appStatus content] setValue:[NSNumber numberWithBool:YES] forKey:CBKEY_APPSTATUS_LOADING];

	[[self.kijis content] removeAllObjects];
	[[self.topics content] removeAllObjects];
	
	NSInteger index = [self.dbNames selectionIndex];
	NSMutableDictionary * dbName = [[self.dbNameArrayController content] objectAtIndex:index];
	NSString *dbNameValue = [dbName objectForKey:CBKEY_DBNAME_VALUE];
	
	
	BOOL result = [self.pworld loadTopic:dbNameValue];
	
	if ([[self.topics content] count] > 0)
		[self.topics setSelectionIndex:0];
	
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_LOADING];
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"loadTopicThread", @"threadName", [NSNumber numberWithBool:result], @"result", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME object:nil userInfo:userInfo];
}

- (void)laodKijiThread:(id)param
{
	[[self.kijis content] removeAllObjects];
	
	NSMutableDictionary *dbName = [[self.dbNameArrayController content] objectAtIndex:self.dbNameArrayController.selectionIndex];
	NSString *dbNameValue = [dbName objectForKey:CBKEY_DBNAME_VALUE];
	
	NSMutableDictionary *topic = [[self.topicArrayController content] objectAtIndex:self.topicArrayController.selectionIndex];
	NSString *kijiGrp = [topic objectForKey:CBKEY_TOPIC_KIJIGRP];
	
	
	
	[[self.appStatus content] setValue:[NSNumber numberWithBool:YES] forKey:CBKEY_APPSTATUS_LOADING];
	
	BOOL result = NO;
	NSInteger number = [param integerValue];
	switch (number) {
		case -1:
			result = [self.pworld loadPreviousKiji:dbNameValue kijiGrp:kijiGrp];
			break;
		case 0:
			result = [self.pworld loadKiji:dbNameValue kijiGrp:kijiGrp pageNumber:1];
			break;
		case 1:
			result = [self.pworld loadNextKiji:dbNameValue kijiGrp:kijiGrp];
			break;
	}
	
	if ([[self.kijis content] count] > 0)
		[self.kijis setSelectionIndex:0];
	
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_LOADING];
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"loadKijiThread", @"threadName", [NSNumber numberWithBool:result], @"result", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME object:nil userInfo:userInfo];
}


@end
