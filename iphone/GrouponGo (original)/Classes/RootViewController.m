//
//  RootViewController.m
//  GrouponGo
//
//  Created by Jonah Grant on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "SA_OAuthTwitterEngine.h"  
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "MessageViewController.h"

#define kOAuthConsumerKey        @"StQR6yZ9xgRkqFHI8TO1w"
#define kOAuthConsumerSecret    @"byWDt5n6Z3RqHn9IcwPSGiABX0fiHdfqFmflwfLA"
#define FONT_SIZE 16.0
#define CELL_CONTENT_WIDTH 320.0
#define CELL_CONTENT_MARGIN 10.0

#define ROOM_NAME @"groupon_go_production"

@implementation UINavigationBar (CustomImage)

- (void)drawRect:(CGRect)rect {
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.text = self.topItem.title;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:19.0];
	label.shadowColor = [UIColor whiteColor];
	label.shadowOffset = CGSizeMake(0.0, 1.0);
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor colorWithRed:76.0/255.0
									  green:90.0/255.0
									   blue:99.0/255.0
									  alpha:1.0];
	
	CGRect labelFrame = label.frame;
	labelFrame.size = [label.text sizeWithFont:label.font];
	labelFrame.origin = CGPointMake((320.0 - labelFrame.size.width) / 2.0, (44.0 - labelFrame.size.height) / 2.0);
	
	label.frame = CGRectIntegral(labelFrame);
	
	self.topItem.titleView = label;
	[label release];
	
	[[UIImage imageNamed:@"navbar.png"] drawInRect:rect];
}

@end

@implementation RootViewController

@synthesize name;
@synthesize message;
@synthesize textFieldBackground;
@synthesize textField;
@synthesize send;
@synthesize table;
@synthesize tableCell;
@synthesize tableCellSelf;
@synthesize messages;
@synthesize pusher;
@synthesize eventsChannel;
@synthesize attributedMessages;
@synthesize time;
@synthesize headerView;
@synthesize roomName;
@synthesize roomCount;

#pragma mark -
#pragma mark View lifecycle

 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	 self = [super initWithNibName:@"RootViewController" bundle:nil];
		if (self) {
			// Custom initialization.
		}
	 return self;
}

- (id)initWithRoomName:(NSString *)room_name
{
	[self setRoomTitle:room_name];
	return self;
}

- (void)setRoomTitle:(NSString *)room_name
{
	NSLog(@"room is %@", room_name);
	room = room_name;	 
}
	 
- (void)viewDidLoad {
    [super viewDidLoad];
		
	if(!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey    = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
	}
	else {
		
	}

	if(![_engine isAuthorized]){
	    UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
	    if (controller){
		    [self presentModalViewController:controller animated:YES];
	    }
	}
		
	eventsChannel = [pusher subscribeToChannel:@"groupon_go_production" 
								 withAuthPoint:nil 
									  delegate:self];

	table.showsVerticalScrollIndicator = NO;
		
	TTURLMap *map = [TTNavigator navigator].URLMap; 
	[map from:@"*" toViewController:self selector:@selector(handleLink:)]; 
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopListening:) name:UIApplicationWillResignActiveNotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startListening:) name:UIApplicationWillEnterForegroundNotification object:NULL];

}

- (void)handleLink:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", sender]]];
	NSLog(@"%@", sender);
}

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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSLog(@"id is: %@", [prefs stringForKey:@"user_id"]);
	NSLog(@"oauth token is: %@", [prefs stringForKey:@"oauth_token"]);

	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, self.view.frame.size.height - 40.0)];
	table.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
	table.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 0, 0);
	table.dataSource = self;
	table.delegate = self;
	[self.view addSubview:table];
	[self.view addSubview:headerView];
	
	headerView.backgroundColor = [UIColor clearColor];
	
	/*
	if ([_engine isAuthorized]) {
		if (messages == nil) {
			messages = [[NSMutableArray alloc] init];
			attributedMessages = [[NSMutableArray alloc] init];
		}
		if (eventsChannel == nil) {
			eventsChannel = [PTPusher newChannel:room];
			eventsChannel.delegate = self;
		}
		[eventsChannel startListeningForEvents];
		
		roomName.text = room;
		roomCount.text = @"12 members";
		
		pusher = [[PTPusher alloc] initWithKey:@"534d197146cf867179ee" delegate:self];
		pusher.reconnect = YES;
		
		self.eventsChannel = [self.pusher subscribeToChannel:@"groupon_go_production" withAuthPoint:nil delegate:self];
		
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
	*/
	
	UIView *v = [UIView new];
	v.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg.png"]];
	table.backgroundView = v;
	
	table.separatorStyle = UITableViewCellSeparatorStyleNone;
	
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

- (void) OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)_username
{
	NSLog(@"authenticated user");
}

-(void)stopListening:(NSNotification *)notification
{
	[eventsChannel stopListeningForEvents];
}
-(void)startListening:(NSNotification *)notification
{
	[eventsChannel startListeningForEvents];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Presence Channel Delegate

- (void)presenceChannelSubscriptionSucceeded:(PTPusherChannel *)channel withUserInfo:(NSArray *)userList
{
	NSLog(@"pusher:subscription_succeeded received:\n%@", [userList description]);
}

- (void)presenceChannel:(PTPusherChannel *)channel memberAdded:(NSDictionary *)memberInfo
{
	NSLog(@"pusher:member_added received:\n%@", [memberInfo description]);
}

- (void)presenceChannel:(PTPusherChannel *)channel memberRemoved:(NSDictionary *)memberInfo
{
	NSLog(@"pusher:member_removed received:\n%@", [memberInfo description]);
}

#pragma mark -
#pragma mark Private Channel Delegate

- (void)channelAuthenticationStarted:(PTPusherChannel *)channel
{
	NSLog(@"Private Channel Authentication Started: %@", channel.name);
}

- (void)channelAuthenticationFailed:(PTPusherChannel *)channel withError:(NSError *)error
{
	NSLog(@"Private Channel Authentication Failed: %@", channel.name);
}

#pragma mark -
#pragma mark PTPusherDelegate methods

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
		
		//textField.text = @"No text!";
		//textField.textColor = [UIColor colorWithRed:255.0/255.0 green:108.0/255.0 blue:108.0/255.0 alpha:1];
		//textField.textAlignment = UITextAlignmentRight;
		
	}
	
	text = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self updatePosition];
}

- (void)updatePosition
{
	
	CGFloat offset = [table contentOffset].y;
    if (offset) {
    }
	
	NSLog(@"offset for y is: %f", offset);
}

- (void)textFieldDidBeginEditing:(UITextField *)_textField {
	[UIView beginAnimations:@"beginEditing" context:textFieldBackground];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	table.contentInset = UIEdgeInsetsMake(30.0, 0.0, self.view.frame.size.height/2 + 5, 0.0);
	table.scrollIndicatorInsets = table.contentInset;
	textFieldBackground.frame = CGRectMake(0.0, 160.0, self.view.frame.size.width, 40.0);
	textField.frame = CGRectMake(6.0, 165.0, self.view.frame.size.width - 75.0, 29.0);
	send.frame = CGRectMake(256.0, 165.0, 59.0, 27.0);
	[UIView commitAnimations];
	
	if ([messages count] > 0) {
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
	[send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
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


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	PTPusherEvent *event = [messages objectAtIndex:indexPath.row];

	NSString *cellText = [event.data valueForKey:@"body"];
	CGSize constraintSize = CGSizeMake(message.frame.size.width, MAXFLOAT);
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	PTPusherEvent *event = [messages objectAtIndex:indexPath.row];
    if (cell == nil) {
		if ([[event.data objectForKey:@"twitter_login"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"screen_name"]]) {
			[[NSBundle mainBundle] loadNibNamed:@"TableCellSelf" owner:self options:nil];
			cell = tableCellSelf;
		}
		else {
			[[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
			cell = tableCell;
		}
        self.tableCell = nil;
	}
	NSString *cellText = [event.data valueForKey:@"body"];
	CGSize constraintSize = CGSizeMake(message.frame.size.width, MAXFLOAT);
	CGSize labelSize = [cellText sizeWithFont:[UIFont fontWithName:@"Helvetica Neue" size:16.0f]
							constrainedToSize:constraintSize 
								lineBreakMode:UILineBreakModeWordWrap];
	CGRect frame = CGRectMake(message.frame.origin.x, message.frame.origin.y, message.frame.size.width, labelSize.height);
	
	TTStyledTextLabel *htmlLabel = [[[TTStyledTextLabel alloc] initWithFrame:frame] autorelease];
	htmlLabel.userInteractionEnabled = YES;
	htmlLabel.textColor = [UIColor darkGrayColor];
	htmlLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0f];
	htmlLabel.backgroundColor = [UIColor clearColor];
	htmlLabel.text = [attributedMessages objectAtIndex:indexPath.row];
	if ([[event.data objectForKey:@"twitter_login"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"screen_name"]]) {
		htmlLabel.textAlignment = UITextAlignmentRight;
	}
	else {
		htmlLabel.textAlignment = UITextAlignmentLeft;
	}
	[cell addSubview:htmlLabel];
	
	if (labelSize.height > 85) {
		lineView = [[SSLineView alloc] initWithFrame:CGRectMake(10, labelSize.height + 44, 300, 2)];
	}
	else {
		lineView = [[SSLineView alloc] initWithFrame:CGRectMake(10, 85, 300, 2)];
	}
	lineView.tag = 101;
	[lineView setLineColor:[UIColor colorWithRed:186.0/255.0 
										   green:185.0/255.0 
											blue:185.0/255.0 
										   alpha:1.0]];
	[cell addSubview:lineView];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	time.text = nil;
	name.text = [event.data objectForKey:@"name"];

	[(AsyncImageView *)[cell.contentView viewWithTag:104] setBackgroundColor:[UIColor clearColor]];
	[(AsyncImageView *)[cell.contentView viewWithTag:104] loadImageFromURL:[NSURL URLWithString:[event.data valueForKey:@"profile_image_url"]]];

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [textField resignFirstResponder];
	
	PTPusherEvent *event = [messages objectAtIndex:indexPath.row];
	
	MessageViewController *vc = [[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil];
	//[self presentModalViewController:vc animated:YES];
	//[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[_engine release];
	[eventsChannel release];
    [super dealloc];
}


@end

