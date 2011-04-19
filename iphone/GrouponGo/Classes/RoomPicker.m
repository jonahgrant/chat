//
//  RoomPicker.m
//  GrouponGo
//
//  Created by Jonah Grant on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoomPicker.h"
#import "GrouponGoModel.h"

@implementation RoomPicker
@synthesize delegate;

- (id)init
{
	return [self initWithNibName:@"RoomPicker" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	join = nil;
	roomField = nil;
}

- (IBAction)joinRoom:(id)sender
{
	GrouponGoModel *model = [GrouponGoModel sharedModel];
	model.delegate = self;
	//[model joinRoomWithKeyname:roomField.text];
	[model release];
	
	[self.delegate joinRoomWithIdentifier:@"presence-groupon_go_48_production"];
}

- (void)dealloc {
	[join release];
	[roomField release];
    [super dealloc];
}


@end
