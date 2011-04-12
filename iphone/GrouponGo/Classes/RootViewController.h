//
//  RootViewController.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSLineView.h"
#import "SSTextField.h"
#import "SA_OAuthTwitterController.h"  
#import "PTPusher.h"
#import "PTPusherDelegate.h"
#import "PTPusherChannelDelegate.h"
#import "Three20/Three20.h"
#import "GrouponGoModel.h"
#import "SA_OAuthTwitterEngine.h"  
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "MessageViewController.h"
#import "LRLinkableLabel.h"

@class SA_OAuthTwitterEngine;  
@class AsyncImageView;
@class PTPusherChannel;

@interface RootViewController : UIViewController <UIActionSheetDelegate, PTPusherChannelDelegate, PTPusherDelegate, NSXMLParserDelegate, UITextFieldDelegate, SA_OAuthTwitterControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITableView *table;
	UITableViewCell *tableCell;
	UITableViewCell *tableCellSelf;
	UILabel *name;
	UITextView *messageView;
	UILabel *message;
	UILabel *time;
	UIView *textFieldBackground;
	UITextField *textField;
	UIButton *send;
	BOOL text;
	NSTimer *timer;
	NSMutableArray *messages;
	NSMutableArray *attributedMessages;
	NSURL *tappedURL;

	UIView *headerView;
	UILabel *roomName;
	UILabel *roomCount;
	
	SSLineView *lineView;
	SA_OAuthTwitterEngine *_engine;
	PTPusher *pusher;
	PTPusherChannel *eventsChannel;
	AsyncImageView *avatar;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *message;
@property (nonatomic, retain) UIView *textFieldBackground;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) IBOutlet UITextView *messageView;
@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet AsyncImageView *avatar;
@property (nonatomic, retain) UIButton *send;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableCellSelf;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) PTPusher *pusher;
@property (nonatomic, readonly) PTPusherChannel *eventsChannel;
@property (nonatomic, retain) NSMutableArray *attributedMessages;
@property (nonatomic, retain) NSURL *tappedURL;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UILabel *roomName;
@property (nonatomic, retain) IBOutlet UILabel *roomCount;

- (void)sendMessage;
- (void)refresh;
- (NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim;

@end
