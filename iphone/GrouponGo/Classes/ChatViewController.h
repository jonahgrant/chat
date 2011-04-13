//
//  ChatViewController.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSLineView.h"
#import "SSTextField.h"
#import "SA_OAuthTwitterController.h"  
#import "Three20/Three20.h"
#import "GrouponGoModel.h"
#import "SA_OAuthTwitterEngine.h"  

#import "PTPusher.h"
#import "PTPusherDelegate.h"
#import "PTPusherChannelDelegate.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"

@class SA_OAuthTwitterEngine;  
@class AsyncImageView;
@class PTPusherChannel;
@class TTStyledTextLabel;

@interface ChatViewController : UIViewController <UITextFieldDelegate, SA_OAuthTwitterControllerDelegate, UITableViewDelegate, UITableViewDataSource, PTPusherChannelDelegate, PTPusherDelegate> {
	UITableView *table;
	UITableViewCell *peerCell;
	UITableViewCell *selfCell;
	UIView *header;
	NSString *room;
	UILabel *roomName;
	UILabel *roomCount;
	UILabel *name;
	UILabel *message;
	TTStyledTextLabel *body;
	AsyncImageView *avatar;
	UIImageView *avatarMask;
	SSTextField *textField;
	UIView *textFieldBackground;
	SSLineView *lineView;
	UIButton *sendButton;
	NSMutableArray *messages;
	NSMutableArray *attributedMessages;
	SA_OAuthTwitterEngine *_engine;
	PTPusher *pusher;
	PTPusherChannel *eventsChannel;	
	BOOL text;
	BOOL listening;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) IBOutlet UITableViewCell *peerCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *selfCell;
@property (nonatomic, retain) IBOutlet UIView *header;
@property (nonatomic, copy) NSString *room;
@property (nonatomic, retain) IBOutlet UILabel *roomName;
@property (nonatomic, retain) IBOutlet UILabel *roomCount;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *message;
@property (nonatomic, retain) IBOutlet TTStyledTextLabel *body;
@property (nonatomic, retain) IBOutlet AsyncImageView *avatar;
@property (nonatomic, retain) IBOutlet UIImageView *avatarMask;
@property (nonatomic, retain) SSTextField *textField;
@property (nonatomic, retain) SSLineView *lineView;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSMutableArray *attributedMessages;
@property (nonatomic, retain) SA_OAuthTwitterEngine *_engine;
@property (nonatomic, retain) PTPusher *pusher;
@property (nonatomic, retain) PTPusherChannel *eventsChannel;

- (void)sendMessage;
- (void)setupView;
- (NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim;

@end
