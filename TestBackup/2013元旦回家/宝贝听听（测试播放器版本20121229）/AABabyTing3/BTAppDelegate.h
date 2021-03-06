//
//  BTAppDelegate.h
//  AABabyTing3
//
//  Created by Neo Wang on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCustomTabBarController.h"
#import "BTCheckinAction.h"
#import "BTSplashView.h"
#import "BTSplashAction.h"
#import "BTSourceUpdateAction.h"
#import "WXApi.h"
#import "RMConnectCenter+Share.h"
#import "BTNavView.h"
#import "BTSplashAction.h"
#import "BTNecessarySoftAction.h"
#import "BTFeedbackSingletonAction.h"


#define navViewTag    85214

@interface BTAppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,BTBaseActionDelegate,
WXApiDelegate,RenrenMobileDelegate,BTSplashActionnDelegate,BTFeedbackSingletonActionDelegate>{
    BTCustomTabBarController                *_tabCtr;
    BTCheckinAction                         *checkinAction;
    BTSourceUpdateAction                    *sourceUpdateAction;
    double									_dataStartTime;    //dataManger清空时间
    BTNavView                               *_navView;
    BTSplashAction                          *_splashAction;
    BTNecessarySoftAction                   *softAction;
    NSMutableArray                     *testArray;
    double                                  _splashAddTime;
    
    BOOL                                    isFromBackground;
    BOOL                                    isRenrenShareShowing;
	
	UIWindow *_zwindow;
}
@property(strong,nonatomic) UIWindow *zwindow;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic ,retain)BTCustomTabBarController *tabCtr;
@property (nonatomic,retain)BTNavView    *navView;
@property (nonatomic,assign) BOOL      isFromBackground;
@property (nonatomic,assign) BOOL      isRenrenShareShowing;

-(void)initUIControllers;
-(void)hideTabBar:(BOOL)hidden;
-(void)initData;
-(void)sendCheckinRequest;
-(void)loadingSplashViewDidShown;
-(void)goToHomePage;
-(void) sendAppContent:(WXMediaMessage *)message isMulti:(BOOL)isMulti;
-(void)versionCompatible;
- (void)savePopularizesInfoToLocal:(NSArray *)popularizes;
- (NSArray *)testData;
- (void)jumpToSetUpController;
@end
