//
//  GrouponGoAppDelegate.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherDelegate.h"
#import "PTPusherChannelDelegate.h"

@class RoomViewController;
@class PTPusher;

@interface GrouponGoAppDelegate : NSObject <UIApplicationDelegate, PTPusherDelegate, PTPusherChannelDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
	PTPusher *pusher;
	RoomViewController *chatViewController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) RoomViewController *chatViewController;
@property (nonatomic, retain) PTPusher *pusher;

@end

