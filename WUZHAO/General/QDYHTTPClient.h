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
#import "Feeds.h"
#import "SuggestAddress.h"
#import "PrivateLetter.h"
#import "AddressPhotos.h"


@interface QDYHTTPClient :AFHTTPAPIClient

@property (nonatomic,strong) User *currentUser;


+(QDYHTTPClient*)sharedInstance;

-(BOOL)IsAuthenticated;
-(void)updateLocalUserInfo;
-(void)setDefaultUserInfoWithUser:(User *)user;

#pragma mark ===login and register====

//login with userName and password
-(NSURLSessionDataTask *)LoginWithUserName:(NSString *)UserName password:(NSString *)Password loginType:(NSString *)type complete:(void (^)(NSDictionary *result ,NSError *error))complete;

//register with nickName phoneNumber and Password
- (NSURLSessionDataTask *) RegisterWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password complete:(void (^)(NSDictionary *result ,NSError *error))complete;

-(void) UpdatePwdWithUserId:(NSInteger)userId password:(NSString *)password newpassword:(NSString *)newPwd whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

-(void)logOutWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;


#pragma mark - baidu push register
-(void)registerBPushWithBpUserId:(NSString *)bpUserId bpChannelId:(NSString *)bpChannelId deviceToken:(NSString *)deviceToken whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

#pragma mark - personal info
//get personal info with userId
-(void)GetPersonalSimpleInfoWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

- (void)GetPersonalInfoWithUserId:(NSInteger)userId currentUserId:(NSInteger)currentUserId page:(NSInteger)page whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//get current user photo follows list
-(void)GetPersonalFollowsListWithUserId:(NSInteger)userId currentUserId:(NSInteger)currentUserId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get current user photo followers list
-(void)GetPersonalFollowersListWithUserId:(NSInteger)userId currentUserId:(NSInteger)currentUserId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

#pragma mark - edit personal info
//edit personal info with userinfo
- (void)UpdatePersonalInfoWithUser:(User *)user oldNick:(NSString *)oldNick whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

-(void)PostAvatorWithUserId:(NSInteger)userId avatorName:(NSString *)avatarName whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//update personal background image
-(void)PostBackGroundImageWithUserId:(NSInteger)userId backgroundName:(NSString *)backgroundName whenComplete:(void (^)(NSDictionary *))whenComplete;



#pragma mark - post related
//get qiniu uploadToken with userId
- (void) GetQiNiuTokenWithUserId:(NSInteger)userId type:(NSInteger)type whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//post the image info to server
- (void) PostPhotoInfomationWithUserId:(NSInteger)userId photo:(NSString *)photoName thought:(NSString *)thought haspoi:(BOOL)haspoi  provider:(NSInteger)provider uid:(NSString *)uid name:(NSString *)name classify:(NSString *)classify location:(NSString *)location address:(NSString *)address province:(NSString *)province city:(NSString *)city district:(NSString *)district stamp:(NSString *)stamp whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//delete image by postid and userid
-(void) deletePhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//get whats going on with userId
-(void) GetWhatsGoingOnWithUserId:(NSInteger)userId page:(NSInteger)page whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get home address list
-(void)GetHomeAddressWithLocation:(NSString *)location whenComplete:(void (^) (NSDictionary *returnData))whenComplete;
//get home recommend list
-(void)GetHomeRecommendListWithPageNum:(NSInteger)page whenComplete:(void (^)(NSDictionary * returnData))whenComplete;

//get recommend userList
-(void)GetRecommendUserListWhenComplete:(void (^)(NSDictionary *returnData))whenComplete;

//get address info with POI id
-(void)GetPOIInfoWithPoiId:(NSInteger)poiId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
-(void)GetPOIInfoWithPoiId:(NSInteger)poiId recommendFirstPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete;

//get photo info with userId or photo post Id
-(void) GetPhotoInfoWithPostId:(NSInteger)postId userId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

#pragma mark - comment, zan post
//get photo comment list with photo post Id
-(void) GetPhotoCommentsWithPostId:(NSInteger)postId comment:(NSString *)comment whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//zan photo with userId and photo post Id
-(void) ZanPhotoWithUserId:(NSInteger )userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
-(void) CancelZanPhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
-(void)GetPhotoZanUserListWithPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//get comment list with postId
-(void) GetCommentListWithPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//comment with userId and photo PostId
-(void) CommentPhotoWithUserId:(NSInteger )userId postId:(NSInteger)postId comment:(NSString *)comment replyUserId:(NSInteger)replyUserId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;
//delete comment with commentId
-(void) DeleteCommentPhotoWithCommentId:(NSInteger)commentId whenComplete:(void (^)(NSDictionary *returnData))whenComplete;

#pragma mark - follow and unfollow
-(void)followUser:(NSInteger)userIdToFollow withUserId:(NSInteger)myUserId whenComplete:(void (^)(NSDictionary *))whenComplete;
-(void)unFollowUser:(NSInteger)userIdToUnFollow withUserId:(NSInteger)myUserId whenComplete:(void (^)(NSDictionary *))whenComplete;

#pragma mark - search 
//search content with type 0 -用户 1 - 地点
-(void)searchWithType:(NSString *)type keyword:(NSString *)keyword whenComplete:(void (^)(NSDictionary *))whenComplete;

//search photo
-(void)explorephotoWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete;
//search user
-(void)exploreUserWhenComplete:(void (^)(NSDictionary *))whenComplete;
//search place
-(void)explorePlaceWhenComplete:(void (^)(NSDictionary *))whenComplete;

#pragma mark - notice and private letter
//get system notice list
-(void)getNoticeWithUserId:(NSInteger)userId  whenComplete:(void (^)(NSDictionary *))whenComplete;
-(void)getNoticeNumWithUserId:(NSInteger)userId  whenComplete:(void (^)(NSDictionary *))whenComplete;

//get system recommend list
-(void)getSystemNoticeWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete;

//private letter
-(void)getLetterListWithUserId:(NSInteger)myUserId whenComplete:(void (^)(NSDictionary *))whenComplete;

-(void)getConversationWithUserId:(NSInteger)myUserId otherUserId:(NSInteger)otherUserId  whenComplete:(void (^)(NSDictionary *))whenComplete;

-(void)sendMessageWithMyUserId:(NSInteger)myUserId toUserId:(NSInteger)toUserId content:(NSString *)content whenComplete:(void (^)(NSDictionary *))whenComplete;

-(void)deleteMessageWithMyUserId:(NSInteger)myUserId toUserId:(NSInteger)toUserId whenComplete:(void (^)(NSDictionary *))whenComplete;


#pragma mark - feed back
-(void)feedBackWithUserId:(NSInteger)userId content:(NSString *)content contact:(NSString *)contact whenComplete:(void (^)(NSDictionary *))whenComplete;

#pragma mark - get notice number
-(void)getLatestNoticeNumber;
@end
