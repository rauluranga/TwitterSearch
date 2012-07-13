//
//  Tweet.h
//  TwitterSearch
//
//  Created by Raul Uranga on 7/12/12.
//  Copyright (c) 2012 GrupoW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

@property (strong, nonatomic) NSString *from_user;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *from_user_name;
@property (strong, nonatomic) NSString *profile_image_url;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *id_str;

@end
