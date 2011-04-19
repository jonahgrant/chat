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
	[request setPostValue:[prefs stringForKey:@"oauth_token"] forKey:@"oauth_token"];

	[request setDelegate:self];
	[request setRequestType:GrouponGoRequestTypePost];
	[request startAsynchronous];
	
	NSLog(@"posting: %@", request);
}

- (void)userLoggedIn
{
	GrouponGoRequest *request = [GrouponGoRequest requestWithURL:[NSURL URLWithString:@"http://go.groupon.com/login"]];

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

	}
}
@end
