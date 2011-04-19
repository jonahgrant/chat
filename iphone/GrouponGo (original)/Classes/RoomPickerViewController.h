//
//  RoomPickerViewController.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RoomPickerViewController : UIViewController <UITextFieldDelegate> {
	UITextField *roomField;
	UIButton *enterRoomButton;
}
@property (nonatomic, retain) IBOutlet UITextField *roomField;
@property (nonatomic, retain) IBOutlet UIButton *enterRoomButton;

- (IBAction)enterRoom;

@end
