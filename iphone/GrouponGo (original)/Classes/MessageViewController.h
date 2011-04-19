//
//  MessageViewController.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MessageViewController : UIViewController {
	UITableView *table;
	AsyncImageView *avatar;
	UILabel *name;
	UITextView *message;
}
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet AsyncImageView *avatar;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UITextView *message;


- (IBAction)close;

@end
