//
//  QDYHTTPClient.h
//  WUZHAO
//
//  Created by yiyi on 15/2/11.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPAPIClient.h"

#import "User.h"
#import "WhatsGoingOn.h"


@interface QDYHTTPClient :AFHTTPAPIClient

@property (nonatomic,strong) User *currentUser;

+(QDYHTTPClient*)sharedInstance;

-(BOOL)IsAuthenticated;


#pragma mark ===login and register====
//login with userName and password
-(NSURLSessionDataTask *)LoginWithUserName:(NSString *)UserName password:(NSString *)Password complete:(void (^)(NSDictionary *result ,NSError *error))complete;

//register with nickName phoneNumber and Password
- (NSURLSessionDataTask *) RegisterWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password complete:(void (^)(NSDictionary *result ,NSError *error))complete;

-(NSURLSessionDataTask *) UpdatePwdWithUserId:(NSInteger)userId password:(NSString *)password newpassword:(NSString *)newPwd whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

#pragma mark ====personal info
//get personal info with userId
- (void)GetPersonalInfoWithUserId:(NSInteger)userId page:(NSInteger)page whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//edit personal info with userinfo
- (void)PostPersonalInfoWithUser:(User *)user whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get current user photo list
-(void)GetPersonalPhotosListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get current user photo address list
-(void)GetPersonalAddressListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get current user photo follows list
-(void)GetPersonalFollowsListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get current user photo followers list
-(void)GetPersonalFollowersListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
-(void)PostAvatorWithUserId:(NSInteger)userId avatorName:(NSString *)avatarName whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//get photo list with userId
-(void) GetPersonalPhotosListWithUserId:(NSInteger )userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get photo address list with userId
-(void) GetPersonalAddressListWithUserId:(NSInteger )userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get follows with userId
-(void) GetPersonalFollowsListWithUserId:(NSInteger )userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get followers with userId
-(void) GetPersonalFollowersListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

#pragma mark =====photos info
//get qiniu uploadToken with userId
- (void) GetQiNiuTokenWithUserId:(NSInteger)userId type:(NSInteger)type whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//post the image info to server
- (void) PostPhotoInfomationWithUserId:(NSInteger)userId photo:(NSString *)photoName thought:(NSString *)thought haspoi:(BOOL)haspoi  provider:(NSInteger)provider uid:(NSString *)uid name:(NSString *)name classify:(NSString *)classify location:(NSString *)location address:(NSString *)address province:(NSString *)province city:(NSString *)city district:(NSString *)district stamp:(NSString *)stamp whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//delete image by postid and userid
-(void) deletePhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//get whats going on with userId
-(void) GetWhatsGoingOnWithUserId:(NSInteger)userId page:(NSInteger)page whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//get photo info with userId or photo post Id
-(void) GetPhotoInfoWithPostId:(NSInteger)postId userId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get photo comment list with photo post Id
-(void) GetPhotoCommentsWithPostId:(NSInteger)postId comment:(NSString *)comment whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//zan photo with userId and photo post Id
-(void) ZanPhotoWithUserId:(NSInteger )userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
-(void) CancelZanPhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
-(void)GetPhotoZanUserListWithPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//comment with userId and photo PostId
-(void) CommentPhotoWithUserId:(NSInteger )userId postId:(NSInteger)postId comment:(NSString *)comment whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

#pragma mark ===== follow
-(void)followUser:(NSInteger)userIdToFollow withUserId:(NSInteger)myUserId whenComplete:(void (^)(NSDictionary *))whenComplete;
-(void)unFollowUser:(NSInteger)userIdToUnFollow withUserId:(NSInteger)myUserId whenComplete:(void (^)(NSDictionary *))whenComplete;

#pragma mark =====search
-(void)searchWithType:(NSString *)type keyword:(NSString *)keyword whenComplete:(void (^)(NSDictionary *))whenComplete;
#pragma mark =====notice
//get system notice list

//get relative item list


//
@end
