//
//  RoomViewController.m
//  GrouponGo
//
//  Created by Jonah Grant on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoomViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "GrouponGoModel.h"
#import "Three20/Three20.h"
#import "SA_OAuthTwitterEngine.h"  
#import "MTStatusBarOverlay.h"

#define kOAuthConsumerKey        @"StQR6yZ9xgRkqFHI8TO1w"
#define kOAuthConsumerSecret    @"byWDt5n6Z3RqHn9IcwPSGiABX0fiHdfqFmflwfLA"
#define FONT_SIZE 16.0
#define CELL_CONTENT_WIDTH 320.0
#define CELL_CONTENT_MARGIN 10.0

@implementation RoomViewController

@synthesize pusher, eventsChannel;
@synthesize eventsReceived;
@synthesize headerView;
@synthesize tableView;
@synthesize tableCellSelf;
@synthesize tableCellPeer;
@synthesize attributedMessages;

#pragma mark -
#pragma mark View lifecycle

+ (RoomViewController *)controller
{
	RoomViewController *cont = [[[RoomViewController alloc] initWithNibName:@"RoomViewController" bundle:nil] autorelease];
	cont.title = nil;
	
	return cont;
}

- (id)initWithRoomName:(NSString *)rName
{
	nameOfRoom = rName;
	//[self joinRoom:rName];
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	if(!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey    = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
	}	
	if(![_engine isAuthorized]){
	    UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
	    if (controller){
		    [self presentModalViewController:controller animated:YES];
	    }
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSLog(@"id is: %@", [prefs stringForKey:@"user_id"]);
	NSLog(@"oauth token is: %@", [prefs stringForKey:@"oauth_token"]);
	
	TTURLMap *map = [TTNavigator navigator].URLMap; 
	[map from:@"*" toViewController:self selector:@selector(handleLink:)]; 
	
	self.eventsChannel = [self.pusher subscribeToChannel:@"presence-groupon_go_48_"
										   withAuthPoint:nil
												delegate:self];
	
	NSLog(@"%@", [NSString stringWithFormat:@"http://go.groupon.com/pusher/auth?user_id=%@&channel_name=%@&socket_id=%@", 
				  [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"],
				  @"presence-groupon_go_48_", 
				  @"448.248878"]);
	
	if (eventsReceived == nil) eventsReceived = [[NSMutableArray alloc] init];
	
	[eventsChannel addEventListener:@"new_post" block:^(PTPusherEvent *event) {
		NSLog(@"%@", event);
		[self.tableView beginUpdates];
		[eventsReceived insertObject:event atIndex:[eventsReceived count]];
		[attributedMessages insertObject:[TTStyledText textFromXHTML:[event.data valueForKey:@"body"]] atIndex:[attributedMessages count]];
		NSLog(@"%@", [event.data valueForKey:@"body"]);
		NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([eventsReceived count] - 1) inSection:0];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:scrollIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2e9), dispatch_get_main_queue(), ^{
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([eventsReceived count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		});	
		[self.tableView endUpdates];
	}];
	
	listening = YES;
	
	NSLog(@"opened a new connection and starting to listen for events");
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopListening:) name:UIApplicationWillResignActiveNotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startListening:) name:UIApplicationDidBecomeActiveNotification object:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self setupView];
	[self joinRoom:nameOfRoom];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

	[self.pusher unsubscribeFromChannel:eventsChannel];
	listening = NO;
	
	NSLog(@"closed the current connection");
}

- (void)stopListening:(NSNotification *)notification
{
	[self.pusher unsubscribeFromChannel:eventsChannel];
	listening = NO;
	
	NSLog(@"closed the current connection");	
}

- (void)startListening:(NSNotification *)notification
{
	if ([_engine isAuthorized]) {
		if (!listening) {
			self.eventsChannel = [self.pusher subscribeToChannel:@"presence-groupon_go_48_" withAuthPoint:nil delegate:self];
			
			if (eventsReceived == nil) eventsReceived = [[NSMutableArray alloc] init];
			
			[eventsChannel addEventListener:@"new_post" block:^(PTPusherEvent *event) {
				NSLog(@"%@", event);
				[self.tableView beginUpdates];
				[eventsReceived insertObject:event atIndex:[eventsReceived count]];
				[attributedMessages insertObject:[TTStyledText textFromXHTML:[event.data valueForKey:@"body"]] atIndex:[attributedMessages count]];
				NSLog(@"%@", [event.data valueForKey:@"body"]);
				NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([eventsReceived count] - 1) inSection:0];
				[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:scrollIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2e9), dispatch_get_main_queue(), ^{
					[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([eventsReceived count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
				});	
				[self.tableView endUpdates];
			}];
			
			listening = YES;
			
			NSLog(@"opened a new connection and starting to listen for events");
		}
		
	}
}

- (void)channelDidAuthenticate:(PTPusherChannel *)channel withReturnData:(NSData *)returnData
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test"
													message:@"sdf"
												   delegate:nil 
										  cancelButtonTitle:@"sdf"
										  otherButtonTitles:nil];
	[alert show];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown);
}

- (void)joinRoom:(NSString *)rName
{
	if ([_engine isAuthorized]) {
		if (!listening) {
			self.eventsChannel = [self.pusher subscribeToChannel:@"presence-groupon_go_48_" withAuthPoint:nil delegate:self];
			
			if (eventsReceived == nil) eventsReceived = [[NSMutableArray alloc] init];
			
			[eventsChannel addEventListener:@"new_post" block:^(PTPusherEvent *event) {
				NSLog(@"%@", event);
				[self.tableView beginUpdates];
				[eventsReceived insertObject:event atIndex:[eventsReceived count]];
				[attributedMessages insertObject:[TTStyledText textFromXHTML:[event.data valueForKey:@"body"]] atIndex:[attributedMessages count]];
				NSLog(@"%@", [event.data valueForKey:@"body"]);
				NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([eventsReceived count] - 1) inSection:0];
				[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:scrollIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2e9), dispatch_get_main_queue(), ^{
					[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([eventsReceived count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
				});	
				[self.tableView endUpdates];
			}];
			
			listening = YES;
			
			NSLog(@"opened a new connection and starting to listen for events");
		}
		
	}
	
}

- (void)setupView
{
	UIView *v = [UIView new];
	v.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg.png"]];
	self.tableView.backgroundView = v;
	
	[headerView setBackgroundColor:[UIColor clearColor]];
	
	roomName.text = nameOfRoom;
	
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self.view addSubview:headerView];
	[self.tableView setContentInset:UIEdgeInsetsMake(30, 0, 0, 0)];
	[self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(30, 0, 0, 0)];
		
	textFieldBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 40.0, self.view.frame.size.width, 40.0)];
	textFieldBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, textFieldBackground.frame.size.width, textFieldBackground.frame.size.height)];
	[bg setImage:[[UIImage imageNamed:@"bg_sendmessage.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
	[textFieldBackground addSubview:bg];
	[self.view addSubview:textFieldBackground];
	
	textField = [[SSTextField alloc] initWithFrame:CGRectMake(6.0, 381.5, self.view.frame.size.width - 75.0, 29.0)];
	textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	textField.background = [[UIImage imageNamed:@"input.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
	textField.backgroundColor = [UIColor clearColor];
	textField.autocorrectionType = UITextAutocorrectionTypeDefault;
	textField.delegate = self;
	textField.placeholder = @"Enter your message...";
	textField.font = [UIFont systemFontOfSize:15.0];
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[self.view addSubview:textField];
	[self.view bringSubviewToFront:textField];
	[textField release];
	
	send = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	send.frame = CGRectMake(self.view.frame.size.width - 65.0, 382, 59.0, 29.0);
	send.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	send.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
	send.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	[send setBackgroundImage:[[UIImage imageNamed:@"btn_send.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0] forState:UIControlStateNormal];
	[send setTitle:@"Send" forState:UIControlStateNormal];
	[send addTarget:nil action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
	[send setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
	[send setTitleShadowColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
	[self.view addSubview:send];
	
}

- (void)handleLink:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", sender]]];
	NSLog(@"%@", sender);
}

- (void)sendMessage
{
	
	if (text) {
		[self performSelector:@selector(sendMessageWithString:) withObject:textField.text afterDelay:0.00];
		textField.text = nil;
		textField.placeholder = @"Enter your message...";
	}
	else if(!text) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
		[animation setDuration:0.08];
		[animation setRepeatCount:2];
		[animation setAutoreverses:YES];
		[animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([textField center].x - 20.0f, [textField center].y)]];
		[animation setToValue:[NSValue valueWithCGPoint:CGPointMake([textField center].x + 20.0f, [textField center].y)]];
		[[textField layer] addAnimation:animation forKey:@"position"];
		
		//textField.text = @"No text!";
		//textField.textColor = [UIColor colorWithRed:255.0/255.0 green:108.0/255.0 blue:108.0/255.0 alpha:1];
		//textField.textAlignment = UITextAlignmentRight;
		
	}
	
	text = NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)_textField {
	[UIView beginAnimations:@"beginEditing" context:textFieldBackground];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	tableView.contentInset = UIEdgeInsetsMake(30.0, 0.0, self.view.frame.size.height/2 + 45, 0.0);
	tableView.scrollIndicatorInsets = self.tableView.contentInset;
	textFieldBackground.frame = CGRectMake(0.0, 160.0, self.view.frame.size.width, 40.0);
	textField.frame = CGRectMake(6.0, 165.0, self.view.frame.size.width - 75.0, 29.0);
	send.frame = CGRectMake(256.0, 165.0, 59.0, 27.0);
	[UIView commitAnimations];
	
	if ([eventsReceived count] > 0) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([eventsReceived count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
	
	textField.text = nil;
	textField.textColor = [UIColor blackColor];
	textField.textAlignment = UITextAlignmentLeft;
	textField.layer.borderWidth = 0.0;
}

-(BOOL)textFieldShouldReturn:(UITextField *)_textField
{
	[_textField resignFirstResponder];
	
	if ([textField.text length] > 0) {
		[self performSelector:@selector(sendMessageWithString:) withObject:textField.text afterDelay:0.00];
		textField.text = nil;
		textField.placeholder = @"Enter your message...";
	}
	else {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
		[animation setDuration:0.08];
		[animation setRepeatCount:2];
		[animation setAutoreverses:YES];
		[animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([textField center].x - 20.0f, [textField center].y)]];
		[animation setToValue:[NSValue valueWithCGPoint:CGPointMake([textField center].x + 20.0f, [textField center].y)]];
		[[textField layer] addAnimation:animation forKey:@"position"];
	}
	
	
	return YES;	
}

- (void)sendMessageWithString:(NSString *)msg
{
	GrouponGoModel *model = [GrouponGoModel sharedModel];
	model.delegate = self;
	[model postWithBody:msg];
	
	overlay = [MTStatusBarOverlay sharedInstance];
	overlay.animation = MTStatusBarOverlayAnimationFallDown;  // MTStatusBarOverlayAnimationShrink
	overlay.detailViewMode = MTDetailViewModeHistory;         // enable automatic history-tracking and show in detail-view
	overlay.delegate = self;
	overlay.progress = 0.99999;
	[overlay postMessage:@"Posting…"];
}

- (void)messagePosted
{
	overlay.progress = 1.0;	
	[overlay postImmediateFinishMessage:@"Message posted" duration:1.0 animated:YES];	
}

- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	text = YES;
	[send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)_textField {
	[UIView beginAnimations:@"endEditing" context:textFieldBackground];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
	tableView.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 0, 0);
	textFieldBackground.frame = CGRectMake(0.0, self.view.frame.size.height - 40.0, self.view.frame.size.width, 40.0);
	textField.frame = CGRectMake(6.0, 381.5, self.view.frame.size.width - 75.0, 29.0);
	send.frame = CGRectMake(self.view.frame.size.width - 65.0, 383, 59.0, 27.0);
	[send setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
	[UIView commitAnimations];
}

#pragma mark SA_OAuthTwitterEngineDelegate

- (void) storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username {
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:data forKey:@"authData"];
	[defaults setObject:username forKey:@"username"];
	[defaults synchronize];
	
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	NSLog(@"twitter authed 2");
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"authData"];
}

- (NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim 
{
	NSScanner *theScanner;
	NSString *text_ = nil;
	theScanner = [NSScanner scannerWithString:html];
	while ([theScanner isAtEnd] == NO) {
		[theScanner scanUpToString:@"<" intoString:NULL] ;                 
		[theScanner scanUpToString:@">" intoString:&text_] ;
		html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text_]
											   withString:@" "];
	}
	return trim ? [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : html;
	
}

- (NSString *)getYoutubeURL:(NSString *)body
{
	/*NSScanner *theScanner;
	NSString *text_ = nil;
	theScanner = [NSScanner scannerWithString:html];
	while ([theScanner isAtEnd] == NO) {
		[theScanner scanUpToString:@"http://youtube.com/" intoString:NULL] ;                 
		[theScanner scanUpToString:@">" intoString:&text_] ;
		html = [html stringByReplacingOccurrencesOfString:
				[ NSString stringWithFormat:@"%@>", text_]
											   withString:@" "];
	}
	*/
	return body;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [eventsReceived count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	PTPusherEvent *event = [eventsReceived objectAtIndex:indexPath.row];
	
	NSString *cellText = [event.data valueForKey:@"body"];
	CGSize constraintSize = CGSizeMake(310, MAXFLOAT);
	CGSize labelSize = [cellText sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:16.0f]
							constrainedToSize:constraintSize 
								lineBreakMode:UILineBreakModeWordWrap];
	
	NSRange aRange = [[self flattenHTML:cellText trimWhiteSpace:NO] rangeOfString:@"youtube"];
	if (aRange.location == NSNotFound) {
		if (labelSize.height > 85) {
			return labelSize.height + 50;
		}
		else {
			return 85;
		}
	} else {
		if (labelSize.height > 85) {
			return labelSize.height + 100;
		}
		else {
			return 225;
		}
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	PTPusherEvent *event = [eventsReceived objectAtIndex:indexPath.row];
    if (cell == nil) {
		if ([[event.data objectForKey:@"twitter_login"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"screen_name"]]) {
			[[NSBundle mainBundle] loadNibNamed:@"TableCellSelf" owner:self options:nil];
			cell = tableCellSelf;
		}
		else {
			[[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
			cell = tableCellPeer;
		}
    }
    
	NSString *cellText = [event.data valueForKey:@"body"];
	CGSize constraintSize = CGSizeMake(messageBody.frame.size.width, MAXFLOAT);
	CGSize labelSize = [cellText sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:16.0f]
							constrainedToSize:constraintSize 
								lineBreakMode:UILineBreakModeWordWrap];
	CGRect frame = CGRectMake(messageBody.frame.origin.x, messageBody.frame.origin.y, messageBody.frame.size.width, labelSize.height);
	
	TTStyledTextLabel *htmlLabel = [[[TTStyledTextLabel alloc] initWithFrame:frame] autorelease];
	htmlLabel.userInteractionEnabled = YES;
	htmlLabel.textColor = [UIColor darkGrayColor];
	htmlLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0f];
	htmlLabel.backgroundColor = [UIColor clearColor];
	htmlLabel.text = [TTStyledText textFromXHTML:[event.data valueForKey:@"body"]];
	[cell addSubview:htmlLabel];
	
	NSRange aRange = [[self flattenHTML:cellText trimWhiteSpace:NO] rangeOfString:@"youtube"];
	if (aRange.location == NSNotFound) {
		if (labelSize.height > 85) {
			lineView = [[SSLineView alloc] initWithFrame:CGRectMake(10, labelSize.height + 44, 300, 2)];
		}
		else {
			lineView = [[SSLineView alloc] initWithFrame:CGRectMake(10, 85, 300, 2)];
		}		
	} else {
		if (labelSize.height > 85) {
			lineView = [[SSLineView alloc] initWithFrame:CGRectMake(10, labelSize.height + 94, 300, 2)];
		}
		else {
			lineView = [[SSLineView alloc] initWithFrame:CGRectMake(10, 185, 300, 2)];
		}
		
	}
	lineView.tag = 101;
	[lineView setLineColor:[UIColor colorWithRed:186.0/255.0 
										   green:185.0/255.0 
											blue:185.0/255.0 
										   alpha:1.0]];
	[cell addSubview:lineView];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	messageName.text = [event.data objectForKey:@"name"];
	
	[(AsyncImageView *)[cell.contentView viewWithTag:104] setBackgroundColor:[UIColor clearColor]];
	[(AsyncImageView *)[cell.contentView viewWithTag:104] loadImageFromURL:[NSURL URLWithString:[event.data valueForKey:@"profile_image_url"]]];
	
	if (aRange.location == NSNotFound) {
		
	} 
	else {
		TTYouTubeView *youTubeView = [[TTYouTubeView alloc] initWithURLPath:@"http://www.youtube.com/watch?v=CD2LRROpph0"];
		youTubeView.center = CGPointMake(cell.frame.size.width/2, 130);
		[cell addSubview:youTubeView];	
	}

	
	

	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [textField resignFirstResponder];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

