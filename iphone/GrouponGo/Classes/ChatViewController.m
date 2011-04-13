//
//  ChatViewController.m
//  GrouponGo
//
//  Created by Jonah Grant on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatViewController.h"

#define kOAuthConsumerKey        @"StQR6yZ9xgRkqFHI8TO1w"
#define kOAuthConsumerSecret    @"byWDt5n6Z3RqHn9IcwPSGiABX0fiHdfqFmflwfLA"
#define FONT_SIZE 16.0
#define CELL_CONTENT_WIDTH 320.0
#define CELL_CONTENT_MARGIN 10.0

#define ROOM_NAME @"groupon_go_production"

@implementation ChatViewController

@synthesize table;
@synthesize peerCell;
@synthesize selfCell;
@synthesize header;
@synthesize room;
@synthesize roomName;
@synthesize roomCount;
@synthesize name;
@synthesize body;
@synthesize avatar;
@synthesize avatarMask;
@synthesize textField;
@synthesize sendButton;
@synthesize messages;
@synthesize attributedMessages;
@synthesize _engine;
@synthesize pusher;
@synthesize eventsChannel;	
@synthesize message;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"ChatViewController" bundle:nil];
    if (self) {
        // Custom initialization.
    }
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
	if ([_engine isAuthorized]) {
		if ([_engine isAuthorized]) {
			if (messages == nil) {
				messages = [[NSMutableArray alloc] init];
				attributedMessages = [[NSMutableArray alloc] init];
			}
			if (eventsChannel == nil) {
				eventsChannel = [PTPusher newChannel:ROOM_NAME];
				eventsChannel.delegate = self;
			}
			if (!listening) {
				[eventsChannel startListeningForEvents];
				listening = YES;
			}
			else {
				NSLog(@"Already listening for events");
			}

			
			roomName.text = ROOM_NAME;
			roomCount.text = @"12 members";
			
			pusher = [[PTPusher alloc] initWithKey:@"534d197146cf867179ee" 
										   channel:ROOM_NAME];
			pusher.delegate = self;
			pusher.reconnect = YES;
			
			[PTPusher setKey:@"534d197146cf867179ee"];
			[PTPusher setSecret:@"4a0cf79a75eaff29cfc7"];
			[PTPusher setAppID:@"3638"];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(handlePusherEvent:)
														 name:PTPusherEventReceivedNotification 
													   object:nil];
			[pusher addEventListener:@"alert" 
							  target:self 
							selector:@selector(handleAlertEvent:)];
			
		}		
	}
	
	TTURLMap *map = [TTNavigator navigator].URLMap; 
	[map from:@"*" toViewController:self selector:@selector(handleLink:)]; 
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopListening:) name:UIApplicationDidEnterBackgroundNotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startListening:) name:UIApplicationWillEnterForegroundNotification object:NULL];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self setupView];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
	[eventsChannel stopListeningForEvents];
	listening = NO;
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)handleLink:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", sender]]];
	NSLog(@"%@ clicked", sender);
}

- (void)setupView
{	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, self.view.frame.size.height - 40.0)];
	table.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
	table.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 0, 0);
	table.dataSource = self;
	table.delegate = self;
	table.backgroundColor = [UIColor clearColor];
	[self.view addSubview:table];
	[self.view addSubview:header];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg.png"]]];
	[header setBackgroundColor:[UIColor clearColor]];
	
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
	
	sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	sendButton.frame = CGRectMake(self.view.frame.size.width - 65.0, 382, 59.0, 29.0);
	sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
	sendButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	[sendButton setBackgroundImage:[[UIImage imageNamed:@"btn_send.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0] forState:UIControlStateNormal];
	[sendButton setTitle:@"Send" forState:UIControlStateNormal];
	[sendButton addTarget:nil action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
	[sendButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
	[sendButton setTitleShadowColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
	[self.view addSubview:sendButton];
}

- (void)sendMessage
{
	
	if (text) {
		GrouponGoModel *model = [GrouponGoModel sharedModel];
		model.delegate = self;
		[model postWithBody:textField.text];
		
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
	}
	
	text = NO;
}

#pragma mark -
#pragma mark UITextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)_textField {
	[UIView beginAnimations:@"beginEditing" context:textFieldBackground];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	table.contentInset = UIEdgeInsetsMake(30.0, 0.0, self.view.frame.size.height/2 + 3, 0.0);
	table.scrollIndicatorInsets = table.contentInset;
	textFieldBackground.frame = CGRectMake(0.0, 160.0, self.view.frame.size.width, 40.0);
	textField.frame = CGRectMake(6.0, 165.0, self.view.frame.size.width - 75.0, 29.0);
	sendButton.frame = CGRectMake(256.0, 165.0, 59.0, 27.0);
	[UIView commitAnimations];
	
	if ([messages count] > 1) {
		[table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
		GrouponGoModel *model = [GrouponGoModel sharedModel];
		model.delegate = self;
		[model postWithBody:textField.text];
		
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


- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	text = YES;
	[sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)_textField {
	[UIView beginAnimations:@"endEditing" context:textFieldBackground];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	table.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
	table.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 0, 0);
	textFieldBackground.frame = CGRectMake(0.0, self.view.frame.size.height - 40.0, self.view.frame.size.width, 40.0);
	textField.frame = CGRectMake(6.0, 381.5, self.view.frame.size.width - 75.0, 29.0);
	sendButton.frame = CGRectMake(self.view.frame.size.width - 65.0, 383, 59.0, 27.0);
	[sendButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark PTPusher

- (void)handlePusherEvent:(NSNotification *)note;
{
	NSLog(@"Received event: %@", note.object);
}

- (void)handleEvent:(PTPusherEvent *)event;
{
	NSLog(@"Received event %@ with data %@", event.name, event.data);
}

- (void)handleAlertEvent:(PTPusherEvent *)event;
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[event.data valueForKey:@"title"] 
														message:[event.data valueForKey:@"message"]
													   delegate:self
											  cancelButtonTitle:@"Close" 
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

-(void)stopListening:(NSNotification *)notification
{
	[eventsChannel stopListeningForEvents];
	listening = NO;
}
-(void)startListening:(NSNotification *)notification
{
	if (!listening) {
		[eventsChannel startListeningForEvents];
		listening = YES;
	}
	else {
		NSLog(@"Already listening for events");
	}
}

- (void)pusherWillConnect:(PTPusher *)_pusher;
{
	NSLog(@"Pusher %@ connecting...", _pusher);
}

- (void)pusherDidConnect:(PTPusher *)_pusher;
{
	NSLog(@"Pusher %@ connected", _pusher);
}

- (void)pusherDidDisconnect:(PTPusher *)_pusher;
{
	NSLog(@"Pusher %@ disconnected", _pusher);
}

- (void)pusherDidFailToConnect:(PTPusher *)_pusher withError:(NSError *)error;
{
	NSLog(@"Pusher %@ failed with error %@", _pusher, error);
}

- (void)pusherWillReconnect:(PTPusher *)_pusher afterDelay:(NSUInteger)delay;
{
	NSLog(@"Pusher %@ will reconnect after %d seconds", _pusher, delay);
}

- (void)channel:(PTPusherChannel *)channel didReceiveEvent:(PTPusherEvent *)event;
{
	if ([event.name isEqualToString:@"new_post"]) {
		[table beginUpdates];
		[messages insertObject:event atIndex:[messages count]];
		[attributedMessages insertObject:[TTStyledText textFromXHTML:[event.data valueForKey:@"body"]] atIndex:[attributedMessages count]];
		NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([messages count] - 1) inSection:0];
		[table insertRowsAtIndexPaths:[NSArray arrayWithObject:scrollIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2e9), dispatch_get_main_queue(), ^{
			if ([messages count] > 1) {
				[table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
			}
		});	
		[table endUpdates];
	}
	
}

- (void)channelDidConnect:(PTPusherChannel *)channel
{
	NSLog(@"Listening on channel %@", channel.name);
}

- (void)channelDidDisconnect:(PTPusherChannel *)channel
{
	NSLog(@"Stopped listening on channel %@", channel.name);
}

- (void)channelFailedToTriggerEvent:(PTPusherChannel *)channel error:(NSError *)error
{
	NSLog(@"Error triggering event on channel %@, error: %@", channel.name, error);
}

#pragma mark -
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

#pragma mark -

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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	PTPusherEvent *event = [messages objectAtIndex:indexPath.row];
	
	NSString *cellText = [event.data valueForKey:@"body"];
	CGSize constraintSize = CGSizeMake(body.frame.size.width, MAXFLOAT);
	CGSize labelSize = [cellText sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:16.0f]
							constrainedToSize:constraintSize 
								lineBreakMode:UILineBreakModeWordWrap];
	
	if (labelSize.height > 85) {
		return labelSize.height + 50;
	}
	else {
		return 85;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	PTPusherEvent *event = [messages objectAtIndex:indexPath.row];
    if (cell == nil) {
		if ([[event.data objectForKey:@"twitter_login"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"screen_name"]]) {
			[[NSBundle mainBundle] loadNibNamed:@"TableCellSelf" owner:self options:nil];
			cell = selfCell;
		}
		else {
			[[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
			cell = peerCell;
		}
        //self.selfCell = nil;
		//self.peerCell = nil;
		
		NSString *cellText = [event.data valueForKey:@"body"];
		CGSize constraintSize = CGSizeMake(message.frame.size.width, MAXFLOAT);
		CGSize labelSize = [cellText sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:16.0f]
								constrainedToSize:constraintSize 
									lineBreakMode:UILineBreakModeWordWrap];
		CGRect frame = CGRectMake(message.frame.origin.x, message.frame.origin.y, message.frame.size.width, labelSize.height);
		
		body = [[[TTStyledTextLabel alloc] initWithFrame:frame] autorelease];
		body.userInteractionEnabled = YES;
		body.textColor = [UIColor darkGrayColor];
		body.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0f];
		body.backgroundColor = [UIColor clearColor];
		body.tag = 9;
		[cell.contentView addSubview:body];
		
		name.tag = 10;
	}
    [(TTStyledTextLabel *)[cell.contentView viewWithTag:9] setTextAlignment:UITextAlignmentRight];
	[(TTStyledTextLabel *)[cell.contentView viewWithTag:9] setText:[attributedMessages objectAtIndex:indexPath.row]];
	[(UILabel *)[cell.contentView viewWithTag:10] setText:[event.data valueForKey:@"name"]];
	[(AsyncImageView *)[cell.contentView viewWithTag:104] setBackgroundColor:[UIColor clearColor]];
	[(AsyncImageView *)[cell.contentView viewWithTag:104] loadImageFromURL:[NSURL URLWithString:[event.data valueForKey:@"profile_image_url"]]];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
    return cell;
}

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

