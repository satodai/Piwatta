//
//  AppDelegate_Submit.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_Submit.h"

static const NSInteger SUBMIT_ASSISTANT_MAX_PAGE_NUM  = 6;
static NSInteger _page = 0;


@implementation AppDelegate(Submit)

- (IBAction)onPrev:(id)sender
{
	_page--;
	if (_page < 0)
		_page = 0;
	
	[self switchPage:_page];
}

- (IBAction)onNext:(id)sender
{
	if (_page == SUBMIT_ASSISTANT_MAX_PAGE_NUM) {
		[NSApp endSheet:[sender window] returnCode:1];
		return;
	}
	
	_page++;
	if (_page > SUBMIT_ASSISTANT_MAX_PAGE_NUM)
		_page = SUBMIT_ASSISTANT_MAX_PAGE_NUM;
	
	[self switchPage:_page];
}

- (IBAction)onCancel:(id)sender
{
	[NSApp endSheet:[sender window] returnCode:0];
}

- (void)switchPage:(NSInteger)page
{
	[self.submitPanelTabView selectTabViewItemAtIndex:page];
	
	switch (page) {
		case 0: //投稿先確認
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonNextEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:NO] forKey:@"buttonBackEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonCancelEnabled"];
			[[self.submitPanelStatus content] setValue:@"続ける" forKey:@"buttonNextLabel"];
			break;
			
		case 1: // 投稿情報取得中
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:NO] forKey:@"buttonNextEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:NO] forKey:@"buttonBackEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonCancelEnabled"];
			[[self.submitPanelStatus content] setValue:@"続ける" forKey:@"buttonNextLabel"];
			
			[NSThread detachNewThreadSelector:@selector(prepareSubmitThread) toTarget:self withObject:nil];
			break;
			
		case 2: // ハンドル名
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonNextEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonBackEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonCancelEnabled"];
			[[self.submitPanelStatus content] setValue:@"続ける" forKey:@"buttonNextLabel"];
			break;
			
		case 3: // タイトル
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonNextEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonBackEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonCancelEnabled"];
			[[self.submitPanelStatus content] setValue:@"続ける" forKey:@"buttonNextLabel"];
			break;
			
		case 4: // 最終確認
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonNextEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonBackEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonCancelEnabled"];
			[[self.submitPanelStatus content] setValue:@"投稿" forKey:@"buttonNextLabel"];
			break;
			
		case 5: // 通信中
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:NO] forKey:@"buttonNextEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:NO] forKey:@"buttonBackEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:NO] forKey:@"buttonCancelEnabled"];
			[[self.submitPanelStatus content] setValue:@"投稿" forKey:@"buttonNextLabel"];
			
			[NSThread detachNewThreadSelector:@selector(submitThread) toTarget:self withObject:nil];
			break;
			
		case 6: // 完了
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:YES] forKey:@"buttonNextEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:NO] forKey:@"buttonBackEnabled"];
			[[self.submitPanelStatus content] setValue:[NSNumber numberWithBool:NO] forKey:@"buttonCancelEnabled"];
			[[self.submitPanelStatus content] setValue:@"完了" forKey:@"buttonNextLabel"];
			break;
	}
}



@end
