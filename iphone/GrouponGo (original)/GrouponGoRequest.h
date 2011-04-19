//
//  GrouponGoRequest.h
//  Bellyflop
//
//  Created by Jonah Grant on 4/9/11.
//  Copyright 2011 Groupon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "Constants.h"

@interface GrouponGoRequest : ASIFormDataRequest {
	GrouponGoRequestType requestType;
}
@property (readwrite) GrouponGoRequestType requestType;

@end
