//
//  GrouponGoAppDelegate.m
//  GrouponGo
//
//  Created by Jonah Grant on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrouponGoAppDelegate.h"
#import "RoomViewController.h"
#import "RoomPicker.h"

#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"

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

@implementation GrouponGoAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize pusher;
@synthesize chatViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[PTPusher setKey:@"534d197146cf867179ee"];
	[PTPusher setSecret:@"4a0cf79a75eaff29cfc7"];
	[PTPusher setAppID:@"3638"];	
	
	pusher = [[PTPusher alloc] initWithKey:@"534d197146cf867179ee" delegate:self];
	pusher.reconnect = YES;
	
	[pusher addEventListener:@"test-global-event" block:^(PTPusherEvent *event) {
		NSLog(@"Received Global Event!! : %@", [event description]);
	}];

	self.chatViewController = [RoomViewController controller];
	self.chatViewController.pusher = pusher;
		
	[self.navigationController pushViewController:self.chatViewController animated:NO];
	//[self.chatViewController joinRoom:@"sd"];
	
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark Private/Presence Channel Delegate

- (NSDictionary *)extraParamsForChannelAuthentication:(PTPusherChannel *)channel
{
	// This is for sending additional parameters to Authentication server for further validation
	return nil;
}

- (BOOL)privateChannelShouldContinueWithAuthResponse:(NSData *)data
{
	// This method should check the response from the Authentication server and see if it's valid
	return YES;
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

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



- (void)dealloc {
	[navigationController release];
	[window release];
	[pusher release];
	[super dealloc];
}


@end

