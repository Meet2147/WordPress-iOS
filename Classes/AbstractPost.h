//
//  AbstractPost.h
//  WordPress
//
//  Created by Jorge Bernal on 12/27/10.
//  Copyright 2010 WordPress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blog.h"

@interface AbstractPost : NSManagedObject {

}

// Attributes
@property (nonatomic, retain) NSNumber * postID;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * postTitle;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, assign) NSString * statusTitle;
@property (nonatomic) BOOL local;
// Transient attribute for sorting/grouping.
// Can be "Local Drafts" or "Posts/Pages"
@property (nonatomic,retain) NSString * localType;

// Relationships
@property (nonatomic, retain) Blog * blog;
@property (nonatomic, retain) NSMutableSet * media;

@end