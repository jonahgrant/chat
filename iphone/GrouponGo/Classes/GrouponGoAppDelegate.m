//
//  GrouponGoAppDelegate.m
//  GrouponGo
//
//  Created by Jonah Grant on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrouponGoAppDelegate.h"
#import "ChatViewController.h"

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


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
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
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

