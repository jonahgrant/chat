//
//  Constants.h
//  Bellyflop
//
//  Created by Jonah Grant on 3/21/11.
//  Copyright 2011 Groupon. All rights reserved.
//

extern NSString * const API_BASE_PATH;
extern NSString * const API_GET_POSTS;
extern NSString * const API_POST;

typedef enum _GrouponGoRequestType {
	GrouponGoRequestTypePost         = 1,  
	GrouponGoRequestTypeGetPosts     = 2,
	GrouponGoRequestTypeAddUser      = 3,
	GrouponGoRequestTypeJoinRoom	 = 4
} GrouponGoRequestType;
