//
//  GrouponGoModel.m
//  GrouponGo
//
//  Created by Jonah Grant on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrouponGoModel.h"
#import "Constants.h"
#import "GrouponGoRequest.h"

@interface GrouponGoModel (PrivateMethods)

- (BOOL) isValidDelegateForSelector:(SEL)selector;

@end

@implementation GrouponGoModel

@synthesize delegate;

static GrouponGoModel *sharedModel = nil;

+ (GrouponGoModel *) sharedModel {
    @synchronized(self) {
        if (sharedModel == nil) {
            sharedModel = [[GrouponGoModel alloc] init];
        }
    }
    return sharedModel;
}

- (id)init {
    self = [super init];
    if (self) {
		
    }
    return self;
}

- (void)refreshChat
{
	GrouponGoRequest *request = [GrouponGoRequest requestWithURL:[NSURL URLWithString:@"http://go.groupon.com/posts"]];
	[request setDelegate:self];
	[request setRequestType:GrouponGoRequestTypeGetPosts];
	[request startAsynchronous];
}

- (void)postWithBody:(NSString *)body
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	GrouponGoRequest *request = [GrouponGoRequest requestWithURL:[NSURL URLWithString:@"http://go.groupon.com/posts"]];
	[request setPostValue:[prefs stringForKey:@"user_id"] forKey:@"user_id"];
	[request setPostValue:body forKey:@"message"];
	[request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token"] forKey:@"oauth_token"];
	
	[request setDelegate:self];
	[request setRequestType:GrouponGoRequestTypePost];
	[request startAsynchronous];
	
	NSLog(@"posted %@", body);
}

- (void)addUserToDatabase
{
	GrouponGoRequest *request = [GrouponGoRequest requestWithURL:[NSURL URLWithString:@"http://go.groupon.com/users"]];
	[request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token"] forKey:@"oauth_token"];
	[request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token_secret"] forKey:@"oauth_secret"];

	[request setDelegate:self];
	[request setRequestType:GrouponGoRequestTypeAddUser];
	[request startAsynchronous];
}

- (void)joinRoomWithKeyname:(NSString *)name
{
	GrouponGoRequest *request = [GrouponGoRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://go.groupon.com/rooms/%@.json", name]]];
	[request setRequestType:GrouponGoRequestTypeJoinRoom];
	[request setDelegate:self];
	[request startAsynchronous];
}

#pragma mark Delegate methods

- (BOOL) isValidDelegateForSelector:(SEL)selector {
	return ((delegate != nil) && [delegate respondsToSelector:selector]);
}

- (void)requestFinished:(GrouponGoRequest *)request {
	NSLog(@"request feedback: %@", [request responseString]);
	if ([self isValidDelegateForSelector:@selector(requestFinished:)])
		[delegate requestFinished:request];
	
	switch ([request requestType]) {
		case GrouponGoRequestTypePost:
			NSLog(@"posting successful");
			[delegate performSelector:@selector(messagePosted) withObject:nil];
		break;
		case GrouponGoRequestTypeGetPosts:
			NSLog(@"Getting posts successful");
			NSLog(@"GrouponGoRequestTypeGetPosts: %@", [request responseString]);
		break;
			case GrouponGoRequestTypeAddUser:
			NSLog(@"GrouponGoRequestTypeAddUser: %@", [request responseString]);
		break;
			case GrouponGoRequestTypeJoinRoom:
			NSLog(@"GrouponGoRequestTypeJoinRoom %@", [[request responseString] JSONValue]);
			//[delegate performSelector:@selector(
			break;



	}
}
@end
