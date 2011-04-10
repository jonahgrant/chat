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

@class SA_OAuthTwitterEngine;  
@class AsyncImageView;
@class PTPusherChannel;

@protocol GrouponGoDelegate

- (void)sendEventWithMessage:(NSString *)message;

@end

@interface RootViewController : UIViewController <GrouponGoDelegate, PTPusherChannelDelegate, PTPusherDelegate, NSXMLParserDelegate, UITextFieldDelegate, SA_OAuthTwitterControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITableView *table;
	UITableViewCell *tableCell;
	UILabel *name;
	UITextView *messageView;
	UILabel *message;
	UIView *textFieldBackground;
	UITextField *textField;
	UIButton *send;
	BOOL text;
	NSTimer *timer;
	NSMutableArray *messages;
	NSMutableArray *attributedMessages;
	
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
@property (nonatomic, retain) UITextView *messageView;
@property (nonatomic, retain) IBOutlet AsyncImageView *avatar;
@property (nonatomic, retain) UIButton *send;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableCell;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) PTPusher *pusher;
@property (nonatomic, readonly) PTPusherChannel *eventsChannel;
@property (nonatomic, retain) NSMutableArray *attributedMessages;

- (void)sendMessage;
- (void)refresh;

@end
