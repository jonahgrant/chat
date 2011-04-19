//
//  RoomPickerViewController.m
//  GrouponGo
//
//  Created by Jonah Grant on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoomPickerViewController.h"
#import "RoomViewController.h"

@implementation RoomPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"RoomPickerViewController" bundle:nil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg.png"]];
	[roomField becomeFirstResponder];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)enterRoom
{
	if ([roomField.text length] == 0) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
		[animation setDuration:0.08];
		[animation setRepeatCount:2];
		[animation setAutoreverses:YES];
		[animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([roomField center].x - 20.0f, [roomField center].y)]];
		[animation setToValue:[NSValue valueWithCGPoint:CGPointMake([roomField center].x + 20.0f, [roomField center].y)]];
		[[roomField layer] addAnimation:animation forKey:@"position"];
	}
	else {
		RoomViewController *root = [[RoomViewController alloc] initWithRoomName:roomField.text];
		[self.navigationController pushViewController:root animated:YES];
		[root release];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.navigationItem.title = @"Back";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//self.navigationItem.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	if (![self isViewLoaded]) self = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
