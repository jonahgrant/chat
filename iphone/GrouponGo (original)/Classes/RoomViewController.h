//
//  RoomViewController.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherChannelDelegate.h"
#import "PTPusherDelegate.h"
#import "SSTextField.h"
#import "Three20/Three20.h"
#import "SSLineView.h"
#import "SSTextField.h"
#import "MTStatusBarOverlay.h"

#import "SA_OAuthTwitterController.h"  
#import "SA_OAuthTwitterEngine.h"  
@class SA_OAuthTwitterEngine;  

@class PTPusher;
@class PTPusherChannel;
@class SSTextField;
@class AsyncImageView;

@interface RoomViewController : UIViewController <MTStatusBarOverlayDelegate, SA_OAuthTwitterControllerDelegate, UITextFieldDelegate, PTPusherDelegate, PTPusherChannelDelegate> {
	PTPusher *pusher;
	PTPusherChannel *eventsChannel;
	SA_OAuthTwitterEngine *_engine;
	NSMutableArray *eventsReceived;
	NSMutableArray *attributedMessages;
	NSString *nameOfRoom;
	
	UITableView *tableView;
	UITableViewCell *tableCellSelf;
	UITableViewCell *tableCellPeer;
	UILabel *messageName;
	UILabel *messageBody;
	AsyncImageView *avatar;
	UIImageView *avatarFrame;
	
	SSLineView *lineView;
	MTStatusBarOverlay *overlay;
	UIView *headerView;
	UILabel *roomName;
	UILabel *roomCount;
	UIView *textFieldBackground;
	UITextField *textField;
	UIButton *send;
	BOOL text;
	BOOL listening;
}
@property (nonatomic, retain) PTPusher *pusher;
@property (nonatomic, retain) PTPusherChannel *eventsChannel;
@property (nonatomic, readonly) NSMutableArray *eventsReceived;
@property (nonatomic, readonly) NSMutableArray *attributedMessages;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UILabel *roomName;
@property (nonatomic, retain) IBOutlet UILabel *roomCount;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableCellSelf;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableCellPeer;
@property (nonatomic, retain) NSString *nameOfRoom;
@property (nonatomic, retain) IBOutlet UILabel *messageName;
@property (nonatomic, retain) IBOutlet UILabel *messageBody;
@property (nonatomic, retain) IBOutlet AsyncImageView *avatar;
@property (nonatomic, retain) IBOutlet UIImageView *avatarFrame;

+ (RoomViewController *)controller;
- (void)setupView;
- (void)roomNameWithString:(NSString *)rName;
- (id)initWithRoomName:(NSString *)rName;
- (void)joinRoom:(NSString *)rName;

@end
