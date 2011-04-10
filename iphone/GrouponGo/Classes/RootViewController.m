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
#import "Three20/Three20.h"

#define kOAuthConsumerKey        @"StQR6yZ9xgRkqFHI8TO1w"
#define kOAuthConsumerSecret    @"byWDt5n6Z3RqHn9IcwPSGiABX0fiHdfqFmflwfLA"
#define FONT_SIZE 16.0
#define CELL_CONTENT_WIDTH 320.0
#define CELL_CONTENT_MARGIN 10.0


@implementation UINavigationBar (CustomImage)

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"navbar.png"];
    [image drawInRect:rect];
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
@synthesize messages;
@synthesize pusher;
@synthesize eventsChannel;
@synthesize attributedMessages;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (messages == nil) {
		messages = [[NSMutableArray alloc] init];
		attributedMessages = [[NSMutableArray alloc] init];
	}
	if (eventsChannel == nil) {
		eventsChannel = [PTPusher newChannel:@"groupon_go"];
		eventsChannel.delegate = self;
	}
	[eventsChannel startListeningForEvents];
		
	pusher = [[PTPusher alloc] initWithKey:@"534d197146cf867179ee" 
								   channel:@"groupon_go"];
	pusher.delegate = self;
	
	[PTPusher setKey:@"534d197146cf867179ee"];
	[PTPusher setSecret:@"4a0cf79a75eaff29cfc7"];
	[PTPusher setAppID:@"3638"];
		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:nil];
	[pusher addEventListener:@"alert" target:self selector:@selector(handleAlertEvent:)];
	
	table.showsVerticalScrollIndicator = NO;
	
	table.showsVerticalScrollIndicator = NO;
	
	TTURLMap* map = [TTNavigator navigator].URLMap; 
	[map from:@"*" toViewController:self selector:@selector(handleLink:)]; 
}

- (void)handleLink:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", sender]]];
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
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[event.data valueForKey:@"title"] message:[event.data valueForKey:@"message"] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSLog(@"id is: %@", [prefs stringForKey:@"user_id"]);
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, self.view.frame.size.height - 40.0)];
	table.dataSource = self;
	table.delegate = self;
	[self.view addSubview:table];
	
	
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
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
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

- (void)viewDidAppear: (BOOL)animated {
	[super viewDidAppear:animated];
	
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refresh
{
	NSLog(@"refreshing");	
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

#pragma mark -
#pragma mark PTPusherChannel delegate

- (void)channel:(PTPusherChannel *)channel didReceiveEvent:(PTPusherEvent *)event;
{
	if ([event.name isEqualToString:@"new_post"]) {
		[table beginUpdates];
		[messages insertObject:event atIndex:[messages count]];
		
		/*NSString *html = [NSString stringWithContentsOfFile:[event.data valueForKey:@"body"] encoding:NSUTF8StringEncoding error:NULL];
		NSData *data = [[event.data valueForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding];
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.3], NSTextSizeMultiplierDocumentOption, 
								 @"Verdana", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, nil]; // @"green",DTDefaultTextColor,
		NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data options:options documentAttributes:NULL];
		[attributedMessages insertObject:string atIndex:[attributedMessages count]];
		 */
		
		NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([messages count] - 1) inSection:0];
		[table insertRowsAtIndexPaths:[NSArray arrayWithObject:scrollIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2e9), dispatch_get_main_queue(), ^{
				[table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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


 - (void)sendMessage
{

	if (text) {
		//NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"body", @"Jonah Grant",  @"name", nil];
		//NSLog(@"sending data: %@", payload);
		//[self performSelector:@selector(sendEvent:) withObject:payload afterDelay:0.3];
		textField.text = nil;
		textField.placeholder = @"Enter your message...";
	}
	else if(!text) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"No text entered"
													   delegate:nil
											  cancelButtonTitle:@"Close" 
											  otherButtonTitles:nil];
		[alert show];
	}
	
	text = NO;
	[textField resignFirstResponder];
}

- (void)sendEventWithMessage:(NSString *)_message;
{
	NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:_message, @"title", @"Sent from libPusher", @"description", nil];
	[self performSelector:@selector(sendEvent:) withObject:payload afterDelay:0.3];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)sendEvent:(id)payload;
{
	[self.eventsChannel triggerEvent:@"new-event" data:payload];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self updatePosition];
}

- (void)updatePosition
{
	/*
	 CGFloat offset = [table contentOffset].y;
    if (suggestedHeaderHeight < maximumHeaderHeight || (offset > suggestedHeaderHeight - maximumHeaderHeight || offset <= 0)) {
        CGRect frame = [headerContainerView frame];
        if (suggestedHeaderHeight - maximumHeaderHeight > 0 && offset > 0) offset -= suggestedHeaderHeight - maximumHeaderHeight;
        frame.origin.y = offset;
        frame.size.height = suggestedHeaderHeight - offset;
        [headerContainerView setFrame:frame];
    }
	*/
}

- (void)textFieldDidBeginEditing:(UITextField *)_textField {
	[UIView beginAnimations:@"beginEditing" context:textFieldBackground];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	table.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height/2 + 5, 0.0);
	table.scrollIndicatorInsets = table.contentInset;
	textFieldBackground.frame = CGRectMake(0.0, 160.0, self.view.frame.size.width, 40.0);
	textField.frame = CGRectMake(6.0, 165.0, self.view.frame.size.width - 75.0, 29.0);
	send.frame = CGRectMake(256.0, 165.0, 59.0, 27.0);
	[UIView commitAnimations];

	if ([messages count] > 0) {
		[table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
	
}

-(BOOL)textFieldShouldReturn:(UITextField *)_textField
{
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
	table.contentInset = UIEdgeInsetsZero;
	table.scrollIndicatorInsets = UIEdgeInsetsZero;
	textFieldBackground.frame = CGRectMake(0.0, self.view.frame.size.height - 40.0, self.view.frame.size.width, 40.0);
	textField.frame = CGRectMake(6.0, 376, self.view.frame.size.width - 75.0, 37.0);
	send.frame = CGRectMake(self.view.frame.size.width - 65.0, 383, 59.0, 27.0);
	[send setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
	[UIView commitAnimations];
}

#pragma mark SA_OAuthTwitterEngineDelegate

- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:data forKey:@"authData"];
	[defaults setObject:username forKey:@"username"];
	[defaults synchronize];
	
	
	/*
	 
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Authenticated"
													message:[NSString stringWithFormat:@"id: %@", [data JSONValue]] 
												   delegate:nil 
										  cancelButtonTitle:@"Close" 
										  otherButtonTitles:nil];
	[alert show];
	
	*/
	 
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
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
	return 85;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
        cell = tableCell;
        self.tableCell = nil;
	}
	
	/*
	messageView = [[UITextView alloc] initWithFrame:frame];
	messageView.editable = NO;
	messageView.backgroundColor = [UIColor clearColor];
	messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[cell addSubview:messageView];
	 */
	
	
	PTPusherEvent *event = [messages objectAtIndex:indexPath.row];
	
	CGRect frame = CGRectMake(message.frame.origin.x, message.frame.origin.y, message.frame.size.width, message.frame.size.height);
	TTStyledTextLabel *htmlLabel = [[[TTStyledTextLabel alloc] initWithFrame:frame] autorelease];
	htmlLabel.userInteractionEnabled = YES;
	htmlLabel.textColor = [UIColor darkGrayColor];
	htmlLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0f];
	htmlLabel.backgroundColor = [UIColor clearColor];
	htmlLabel.text = [TTStyledText textFromXHTML:[event.data valueForKey:@"body"] lineBreaks:YES URLs:YES];
	[cell addSubview:htmlLabel];
	
	lineView = [[SSLineView alloc] initWithFrame:CGRectMake(10, 79, 300, 2)];
	lineView.tag = 101;
	[lineView setLineColor:[UIColor colorWithRed:186.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0]];
	[cell addSubview:lineView];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	message.text = nil;
	name.text = [event.data valueForKey:@"name"];

	[(AsyncImageView *)[cell.contentView viewWithTag:104] setBackgroundColor:[UIColor clearColor]];
	[(AsyncImageView *)[cell.contentView viewWithTag:104] loadImageFromURL:[NSURL URLWithString:[event.data valueForKey:@"profile_image_url"]]];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [textField resignFirstResponder];
	
	PTPusherEvent *event = [messages objectAtIndex:indexPath.row];
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

