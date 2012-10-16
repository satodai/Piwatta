//
//  AppDelegate.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate_Misc.h"
#import "DateFormatTransformer.h"
#import "PwEditorDef.h"
#import "PWorld.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize textView = _textView;
@synthesize segmentedControl = _segmentedControl;
@synthesize submitWindow = _submitWindow;
@synthesize documents = _documents;
@synthesize dbNames = _dbNames;
@synthesize topics = _topics;
@synthesize kijis = _kijis;
@synthesize appStatusController = _appStatusController;

@synthesize submitPanelTabView = _submitPanelTabView;

@synthesize pworld = _pworld;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Thread終了通知登録
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(OnThreadEnd:) name:NOTIFICATION_NAME object:nil];
	
	// 日付フォーマッター登録
	DateFormatTransformer *transformaer = [[DateFormatTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformaer forName:@"DateFormatTransFormer"];
	
	// ユーザー設定初期値登録
	NSString *userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
	
	// アプリ状態初期値設定
	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_LOADING];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:CBKEY_APPSTATUS_CANADD_PAGE];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_CANREMOVEPAGE];
	[[_appStatusController content] setValue:@"" forKey:CBKEY_APPSTATUS_TABLEVIEWSTATUSMESSAGE];
	[[_appStatusController content] setValue:[NSNumber numberWithInteger:0] forKey:CBKEY_APPSTATUS_CURRENTBYTE];
	[[_appStatusController content] setValue:[NSNumber numberWithInteger:MAX_BODY_LENGTH] forKey:CBKEY_APPSTATUS_REMAINBYTE];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_EXCEEDED];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_DOCUMENTEDITED];
	[[_appStatusController content] setValue:@"名称未設定.pwe" forKey:CBKEY_APPSTATUS_FILENAME];
	
	
	_pworld = [[PWorld alloc] initWithDbNameArray:_dbNames topicArray:_topics kijiArray:_kijis];
	
	
	[self loadTopic];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if ([_window isDocumentEdited]) {
		[_documents commitEditing];
		
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"保存..."];
		[alert addButtonWithTitle:@"キャンセル"];
		[alert addButtonWithTitle:@"保存しない"];
		[alert setMessageText:[NSString stringWithFormat:@"書類「%@」に加えた変更を保存しますか？", [[_appStatusController content] objectForKey:@"fileName"]]];
		[alert setInformativeText:@"保存しないと、変更内容は失われます。"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:_window modalDelegate:self didEndSelector:@selector(saveWarningAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
		
		return NSTerminateCancel;
	}
	
	return NSTerminateNow;
}

- (void) OnThreadEnd:(NSNotification *)notification
{
	NSString *threadName = [[notification userInfo] valueForKey:@"threadName"];
	BOOL result = [[[notification userInfo] valueForKey:@"result"] boolValue];
	
	if (!result) {
		NSLog(@"読込エラーが発生しました。[%@],[%ld]", threadName, _pworld.errorCode);
	}
	
	
	if ([threadName isEqualToString:@"laodTopicThread"]) {
		[self loadKiji];
		return;
	}
	
	if ([threadName isEqualToString:@"loadKijiThread"]) {
		NSMutableDictionary *topic = [[_topics content] objectAtIndex:[_topics selectionIndex]];
		NSInteger kijiCount = [[topic valueForKey:CBKEY_TOPIC_KIJICOUNT] integerValue];
		
		NSString *statusMsg;
		if (kijiCount == 0)
			statusMsg = @"投稿はまだありません";
		else
			statusMsg = [NSString stringWithFormat:@"%ld 件の投稿があります", kijiCount];
		
		[[_appStatus content] setValue:statusMsg forKey:CBKEY_APPSTATUS_STATUSMESSAGE];
	}
}

- (IBAction)onFileNew:(id)sender
{
	[[_documents content] removeAllObjects];
	
	NSMutableDictionary *document = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", CBKEY_DOCUMENT_TITLE, @"new document created", CBKEY_DOCUMENT_BODY];
	[_documents addObject:document];
	
	[[_appStatus content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_DOCUMENTEDITED];
	[self synchronizeSegmentedControl];
	[self synchronizeCount];
}

- (IBAction)onFileOpen:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel beginSheetModalForWindow:self.window completionHandler:
		^(NSInteger result) {
			 if (result == NSFileHandlingPanelOKButton) {
				 NSString *fileName = [openPanel filename];
				 [_documents setContent:[NSKeyedUnarchiver unarchiveObjectWithFile:fileName]];
				 [[_appStatus content] setValue:[NSNumber numberWithBool:NO] forKey:CBKEY_APPSTATUS_DOCUMENTEDITED];
				 [[_appStatus content] setValue:[NSString lastPathComponent:fileName] forKey:CBKEY_APPSTATUS_FILENAME];
				 [self synchronizeSegmentedControl];
				 [self synchronizeCount];
			 }
		}];
}

- (IBAction)onFileSave:(id)sender
{
	NSString *fileName = [[_appStatus content] objectForKey:CBKEY_APPSTATUS_FILENAME];
	if ([fileName length] == 0)
		[self onFileSaveAs:sender];
	else
		[self saveToFile:fileName];
}

- (IBAction)onFileSaveAs:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setDirectory:[NSURL URLWithString:NSHomeDirectory()]];
	//[savePanel setNameFieldLabel:@"名前："];
	[savePanel setNameFieldStringValue:[[_appStatus content] valueForKey:CBKEY_APPSTATUS_FILENAME]];
	[savePanel beginSheetModalForWindow:self.window completionHandler:
		^(NSInteger result) {
			if (result == NSFileHandlingPanelOKButton) {
				[self saveToFile:[savePanel filename]];
				[[_appStatus content] setValue:[NSString lastPathComponent:fileName] forKey:CBKEY_APPSTATUS_FILENAME];
			}
		}];
}


- (IBAction)onAddPage:(id)sender
{
	NSInteger documentCount =[ [_documents content] count];
	if (documentCount > MAX_DOCUMENT_COUNT)
		return;
	
	[_documents commitEditing];
	[_segmentedControl setSegmentCount:documentCount + 1];
	
	NSMutableDictionary *document = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", CBKEY_DOCUMENT_TITLE, [NSString stringWithFormat:@"new text for page %ld", documentCount + 1], CBKEY_DOCUMENT_BODY, nil];
	
	[_documents addObject:document];
	[[_appStatus content] setValue:[NSNumber numberWithBool:YES] forKey:CBKEY_APPSTATUS_DOCUMENTEDITED];
	[self synchronizeSegmentedControl];
	[self synchronizeCount];
}

- (IBAction)onRemovePage:(id)sender
{
	if ([[_documents content] count] == 1)
		return;
	
	if ([documents selectionIndex] == 0)
		return;
	
	NSString *currentText = [_textView string];
	NSMutableDictionary *prevDocument = [[_documents content] objectAtIndex:[_documents selectionIndex] - 1];
	NSAttributedString *prevText = [prevDocument valueForKey:@"body"];
	NSString *text = [NSString stringWithFormat:@"%@\n%@", [prevText string], currentText];
	[prevDocument setValue:text forKey:@"body"];
	
	[_documentArray remove:sender];
	
	[[_appStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"documentEdited"];
	[self synchronizeSegmentedControl];
	[self synchronizeCount];
	[self.segmentedControl setSegmentCount:[[documents content] count]];
}



- (IBAction)onOpenTopic:(id)sender
{
	NSMutableDictionary *dbName = [[_dbNameArrayController content] objectAtIndex:[_documentArrayController selectionIndex]];
	NSString *dbNameValue = [dbName objectForKey:@"value"];
	
	NSMutableDictionary *topic = [[_topicArrayController content] objectAtIndex:[_topicArrayController selectionIndex]];
	NSString *kijiGrp = [topic objectForKey:@"kijiGrp"];
	
	NSString *urlStr = [NSString stringWithFormat:@"http://www.p-world.co.jp/community/keiziban2disp.cgi?mode=kiji&kiji_grp=%@&dbname=%@", kijiGrp, dbNameValue];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlStr]];
}

- (IBAction)dbNameSelected:(id)sender
{
	[self loadTopic];
}

- (IBAction)onTopicSelected:(id)sender
{
	[self loadKiji];
}

- (IBAction)onDocumentSelected:(id)sender
{
	[self synchronizeCount];
}

- (IBAction)onPrevPage:(id)sender
{
	[self loadPrevKiji];
}

- (IBAction)onNextPage:(id)sender
{
	[self loadNextKiji];
}

- (IBAction)onReload:(id)sender
{
	[self loadKiji];
}

- (IBAction)onSubmit:(id)sender
{
	[self submit];
}


@end
