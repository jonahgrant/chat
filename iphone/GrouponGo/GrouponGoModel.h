//
//  GrouponGoModel.h
//  GrouponGo
//
//  Created by Jonah Grant on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GrouponGoModel : NSObject {
	id delegate;
}
@property (nonatomic, retain) id delegate;

+ (GrouponGoModel *)sharedModel;

- (void)refreshChat;
- (void)postWithBody:(NSString *)body;
- (void)addUserToDatabase;
- (void)joinRoomWithKeyname:(NSString *)name;

@end
