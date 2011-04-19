//
//  RoomPicker.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomViewController.h"

@interface RoomPicker : UIViewController {
	id<RoomViewControllerDelegate> delegate;
	IBOutlet UITextField *roomField;
	IBOutlet UIButton *join;
}
@property (nonatomic, assign) id<RoomViewControllerDelegate> delegate;

- (IBAction)joinRoom:(id)sender;

@end
