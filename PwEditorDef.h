//
//  PwEditorDef.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef PwEditor_PwEditorDef_h
#define PwEditor_PwEditorDef_h

#import <Cocoa/Cocoa.h>

#define NOTIFICATION_NAME @"PwEditorThreadFinishEvent"

#define MAX_DOCUMENT_COUNT	10
#define MAX_BODY_LENGTH		3200

#define UDKEY_PAGESTOLOAD		@"pagesToLoad"
#define UDKEY_CHECKUPDATER		@"checkUpdater"
#define UDKEY_OPENAFTERSUBMIT	@"openAfterSubmit"
#define UDKEY_HANDLENAME		@"handleName"
#define UDKEY_PASSWORD			@"password"
#define UDKEY_RMAIL				@"rmail"
#define UDKEY_TOPICUP			@"topicUp"
#define UDKEY_ORDERFROMTOP		@"orderFromTop"
#define UDKEY_TOPICFILTERS		@"topicFilters"


#define CBKEY_DBNAME_LABEL	@"label"
#define CBKEY_DBNAM_VALUE	@"value"


#define CBKEY_TOPIC_KIJIGRP			@"kijiGrp"
#define CBKEY_TOPIC_TITLE			@"title"
#define CBKEY_TOPIC_AUTHOR			@"author"
#define CBKEY_TOPIC_BODY			@"body"
#define CBKEY_TOPIC_SUBMITTEDTIME	@"submittedTime"
#define CBKEY_TOPIC_KIJICOUNT		@"kijiCount"


#define CBKEY_APPSTATUS_LOADING			@"loading"
#define CBKEY_APPSTATUS_CANADDPAGE		@"canAddPage";
#define CBKEY_APPSTATUS_CANREMOVEPAGE	@"canremovePage"
#define CBKEY_APPSTATUS_STATUSMESSAGE	@"statusMessage"
#define CBKEY_APPSTATUS_CURRENTBYTE		@"currentByte"
#define CBKEY_APPSTATUS_REMAINBYTE		@"remainByte"
#define CBKEY_APPSTATUS_EXCEEDED		@"exceeded"
#define CBKEY_APPSTATUS_DOCUMENTEDITED	@"documentEdited"
#define CBKEY_APPSTATUS_FILENAME		@"fileName"



/*----------------------------------------------------------------------*/
// Error codes
#define ERR_NONE					0
#define ERR_PW_RENZOKU				101	//連続アクセスは禁止されています。
#define ERR_PW_PREPARE				102	//返信フォームデータ不一致
#define ERR_PW_ACCESS_DENINED		103	//１時間程度たってから、もう一度アクセスしてください。
#define ERR_PW_ACCESS_DENINED2		104	//この認証コードは、投稿が制限されています
#define ERR_PW_HANDLENAME_EMPTY		105	//ハンドル名が未入力です
#define ERR_PW_HANDLENAME_USED		106	//すでに他の方が利用しています。他のハンドル名にて、ご投稿下さい
#define ERR_PW_PASSWORD_EMPTY		107	//認証コードが未入力です
#define ERR_PW_PASSWORD_INVALID		108	//認証コードが正しくありません
#define ERR_PW_ITEM_MISSING			109	//必要な項目が記入されていないようです
#define ERR_PW_TITLE_LENGTH			110	//タイトルが長すぎます。
#define ERR_PW_BODY_LENGTH			111	//文字以内で投稿してください
#define ERR_PW_NGWORD_INCLUDED		112	//設定されている制限事項に該当するため投稿できません
#define ERR_NO_CONFIRMATION			201	//「投稿を受け付けました」が無い
#define ERR_PW_OTHER				202	//未知のエラー
#define ERR_PW_HTTPCOMM				400	//通信エラー（レスポンス空など）
#define ERR_PROGRAM					500	//プログラムミス







#endif
