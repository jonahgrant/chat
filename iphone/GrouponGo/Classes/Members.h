//
//  Members.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomViewController.h"

@interface Members : UITableViewController <RoomViewControllerDelegate> {
	id<RoomViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id<RoomViewControllerDelegate> delegate;

@end
