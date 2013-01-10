//
//  BTNewStoryListController.m
//  AABabyTing3
//
//  Created by Neo Wang on 12-8-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BTNewStoryListController.h"
#import "BTNewStoryAction.h"
#import "BTStoryCell.h"
#import "BTStory.h"
#import "BTNewStoryInfoView.h"
#import "BTStoryPlayerController.h"
#import "ParabolaView.h"
#import "BTDownLoadAlertView.h"
@interface BTNewStoryListController ()

@end
@implementation BTNewStoryListController
@synthesize listInfo = _listInfo,lastestStoryAction = _lastestStoryAction,headerAction = _headerAction;
-(void)dealloc{
    [_lastestStoryAction release];
    [_headerAction release];
    [_listInfo release];
    _listInfo = nil;
    [_headerView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithHomeData:(NSInteger)dataID{
    self = [super init];
    if(self){
        _homeID  = dataID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _doubleActionState = noRequest;
    _loadMoreFooterView.visible = YES;
	// Do any additional setup after loading the view.
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
//    view.backgroundColor = [UIColor redColor];
//    self.tableView.tableHeaderView =view;
//    [view release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated{
    //[super viewWillAppear:animated];
    if(actionState != ACTION_REQUESTFINISH &&actionState != ACTION_NOTNEED&&[self.tableView.visibleCells count]==0){
        //_waitingHUB = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _waitingHUB = [[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES] retain];
        _waitingHUB.frame = CGRectMake(self.navigationController.view.bounds.origin.x, self.navigationController.view.bounds.origin.y+61, self.navigationController.view.bounds.size.width,self.navigationController.view.bounds.size.height-61);
        [self.navigationController.view addSubview:_waitingHUB];
        _waitingHUB.delegate = self;
        _doubleActionState = noRequest;
        actionState = ACTION_SENDING;
        [self.headerAction start];
        [self.lastestStoryAction start];
        
    }
    [self.tableView reloadData];
    //刷新全部下载按钮状态
    [self checkAllDownLoadButtonEnable];
    [self willAppearDid];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyPlayStoryPlayingStatus:) name:NOTIFICATION_PLAY_STORY object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAY_STORY object:nil];
}

-(void)modifyPlayStoryPlayingStatus:(NSNotification *)sender {
    [self.tableView reloadData];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57.0f;
}
// 重写父类的方法（点击）
- (void)didSelectedAtObject:(id)object {
//    DLog(@"进入到播放界面555");
    BTStoryPlayerController *playerCtr = [BTPlayerManager sharedInstance].storyPlayer;
    BOOL bIsExist = [[self.navigationController viewControllers] containsObject:playerCtr];
    if (bIsExist) {
        CDLog(BTDFLAG_PRESS_PLAYING_CRASH,@"防止重复push");
        return;
    }
    playerCtr.bIsBackToCurrentPlayingLayer = NO;
    playerCtr.playList = self.itemArray;
    playerCtr.playingStoryIndex = [self.itemArray indexOfObject:object];
    playerCtr.storyType = StoryType_Net;
    [self.navigationController pushViewController:playerCtr animated:YES];
    [playerCtr playStory];
    BTStory *story = (BTStory *)object;
    story.isNew = NO;
}
- (void)doCell:(UITableViewCell *)cell {
    UIView *view = [cell viewWithTag:TAG_NEW_FLAG];
    if (view) {
        view.hidden = YES;
    }
}
// 重写父类的方法（更新cell）
- (void)updateTableViewCell:(UITableViewCell *)cell withObject:(id)object {
    BTStoryCell *storyCell = (BTStoryCell *)cell;
    BTStory *storyData = (BTStory *)object;
    storyCell.storyData = storyData;
    storyCell.storyDelegate=self;
    storyCell.isShowCategory = NO;
    [storyCell setCellData];
    [storyCell setImageController:self];
    if(storyCell.tag == TAG_Last_Cell){
        [storyCell.backButton setImage:[UIImage imageNamed:@"myStory_cell_last_bg.png"] forState:UIControlStateNormal];
    }else {
        [storyCell.backButton setImage:[UIImage imageNamed:@"myStory_cell_bg.png"] forState:UIControlStateNormal];
    }
}
//单个故事下载动画
-(void)stroyDownloadAnimation:(BTStory *)storyData{
    int index = [self.itemArray indexOfObject:storyData];
    CGPoint point = [_tableView contentOffset];
    CGPoint startPoint = CGPointMake(32, index * 57 - point.y + 200);
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@_storyIcon",THREE20_DIRECTORY,storyData.storyId];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (!image) {

        NSString *path = [NSString stringWithFormat:@"bundle://story_cell_default.png"];
        image = TTIMAGE(path);
    }
    if (image) {
        ParabolaView *parabola = [[ParabolaView alloc]initWithImg:image size:CGSizeMake(41, 41) start:startPoint];
        [self.view addSubview:parabola];
        [parabola release];
        [parabola startRuning];
    }
}
//storyCell的下载回调函数
- (void)storyDownLoad:(BTStory *)storyData{
//    DLog(@"开始下载%@故事",storyData.title);
    
    if ([BTUtilityClass isNetWorkNotAvailable]) {
        [[BTDownLoadManager sharedInstance] showNoNetWorkAlert];
        return;
    }
    
    if ([[BTDownLoadManager sharedInstance] showDownloadAlert]) {
        return;
    }
    
    storyData.bIsInLocal = YES;
    [self.tableView reloadData];
    
    if (![[BTDownLoadManager sharedInstance] isInMyStoryList:storyData]) {
        [[BTDownLoadManager sharedInstance] addNewDownLoadTask:storyData];
        [BTUtilityClass setTabBarBadgeNumber:1];
        [self stroyDownloadAnimation:storyData]; 
        //刷新全部下载按钮状态
        [self checkAllDownLoadButtonEnable];
    }

}

- (void)retryAction:(id)sender{
    if(sender){
        UIButton *btn = (UIButton *)sender;
        [btn removeFromSuperview];
    }
    _waitingHUB = [[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES] retain];
    [self.navigationController.view addSubview:_waitingHUB];
    _waitingHUB.delegate = self;
    _doubleActionState = noRequest;
    [self.lastestStoryAction start];
    [self.headerAction start];
    actionState = ACTION_SENDING;
}

//全部下载点取消的回调
-(void)cancelAllDownloadRequest{
    [self releaseAction];
    bIsAllStoriesDownload = NO;
}

//上面的View上button点击全部下载的回调函数
- (void)newStoryAllDownload:(id)data{
//    DLog(@"新故事首发全部下载");
    
    if ([BTUtilityClass isNetWorkNotAvailable]) {
        [[BTDownLoadManager sharedInstance] showNoNetWorkAlert];
        return;
    }
    
    if ([[BTDownLoadManager sharedInstance] showDownloadAlert]) {
        return;
    }
    
    [self performSelectorOnMainThread:@selector(showDownloadProgressAlert) withObject:nil waitUntilDone:NO];
    
    bIsAllStoriesDownload = YES;
    [self reloadTableViewDataSource];
    
}
//全部下载动画
-(void)allStroiesDownloadAnimation{
    
    CGPoint point = [_tableView contentOffset];
    CGPoint startPoint = CGPointMake(57,point.y + 100);
    
    UIView *headerView = [_tableView tableHeaderView];
    UIImageView *headerImageView = (UIImageView *)[headerView viewWithTag:TAG_HeaderNetImage];
    
    UIImage *image = headerImageView.image;
    if (image) {
        ParabolaView *parabola = [[ParabolaView alloc]initWithImg:image size:headerImageView.frame.size start:startPoint];
        [self.view addSubview:parabola];
        [parabola release];
        [parabola startRuning];
    }
}

//获取全部下载的故事信息
-(void)getDownloadAllStoriesInfo{

    if (bIsAllStoriesDownload) {
        [self reloadTableViewDataSource];
        float percent = [self.itemArray count]*1.0/self.countInNet;
        [[BTShowAllDownloaAlert sharedInstance] setDownloadProgress:percent];        
    }
    
    if([self.itemArray count]>=self.countInNet){
        if (bIsAllStoriesDownload) {
            int downLoadCount = 0;
            for (int i = 0; i < [_itemArray count]; i++) {
                BTStory *story = (BTStory *)[_itemArray objectAtIndex:i];
                if (![[BTDownLoadManager sharedInstance] isInMyStoryList:story] ) {
                    if([[BTDownLoadManager sharedInstance] isReachMaxLocalStoryCount]){
                        downLoadCount++;
                        [[BTDownLoadManager sharedInstance] addNewDownLoadTask:story];
                    }else{
                        [[BTDownLoadManager sharedInstance]showDownloadAlert];
                        break;
                    }
                }
            }
            [BTUtilityClass setTabBarBadgeNumber:downLoadCount];
            bIsAllStoriesDownload = NO;
            
            UIView *headerView = [_tableView tableHeaderView];
            UIButton *btn = (UIButton *)[headerView viewWithTag:TAG_ALL_STORY_DOWNLOAD_BUTTON];
            [btn setImage:[UIImage imageNamed:@"allHasDownloadBtn.png"] forState:UIControlStateNormal];
            [btn setEnabled:NO];
            
            [self allStroiesDownloadAnimation];
            [_tableView reloadData];
        }
    }
}

//如果有自定义的Cell，子类需要重写这个方法
- (UITableViewCell*) tableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath cellIdentifier:(NSString*)identifier {
    UITableViewCell *cell = nil;
    if (cell == nil) {
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"BTStoryCell" owner:nil options:nil];
        cell = [objs lastObject];
    }
    return cell;
}

- (void)onAction:(BTBaseAction *)action withData:(id)data{
    if([action isKindOfClass:[BTNewStoryAction class]]){
        _doubleActionState++;
        if([data isKindOfClass:[NSMutableArray class]]){
            //self.itemArray = data;
            [self.itemArray addObjectsFromArray:data];
        }
        if([data isKindOfClass:[BTListInfo class]]){
            BTListInfo *info = (BTListInfo*)data;
            self.itemArray = info.result;
            self.countInNet = info.countInNet;
        }
    }else if([action isKindOfClass:[BTNewStoryHeaderAction class]]){
        _doubleActionState++;
        self.listInfo = data;
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"BTNewStoryInfoView" owner:nil options:nil];
        BTNewStoryInfoView *view = [objs lastObject];
        view.lastestStoryInfo = self.listInfo;
        view.allDownloadDelegate = self;
        [view drawView];
        [view setImageViewController:self];
        _headerView = [view retain];
    }
    if(_doubleActionState >= twoRequest){
        actionState = ACTION_REQUESTFINISH;
        [self.view insertSubview:_ropeView belowSubview:self.tableView];
        self.tableView.tableHeaderView = _headerView;
        [self doneLoadingTableViewData];
        [self.tableView reloadData];
        [self releaseAction];
        [_waitingHUB hide:YES];
        
        if([self.itemArray count]>=self.countInNet){
            //_loadMoreFooterView.visible = NO;
            [_loadMoreFooterView removeFromSuperview];
            [self doneLoadingTableViewData];
            _loadMoreFooterView = nil;
        }
        
        if(bIsAllStoriesDownload){
            [self getDownloadAllStoriesInfo];
        }
        
        if ([[BTDownLoadManager sharedInstance] bIsLimitDownload] &&
            [[[[BTDownLoadManager sharedInstance] queue] operations] count]) {
            [ASIHTTPRequest setMaxBandwidthPerSecond:MAX_DOWNLOAD_BANDWIDTH_PER_SECOND];
        }
    }
    //刷新全部下载按钮状态
    [self checkAllDownLoadButtonEnable];
}

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    [self.lastestStoryAction start];
	_reloading = YES;
	
}

- (void)releaseAction{
    if (_lastestStoryAction) {
        _lastestStoryAction.actionDelegate = nil;
        [_lastestStoryAction cancel];
        [_lastestStoryAction release];
        _lastestStoryAction = nil;
        
    }
    if(_headerAction){
        _headerAction.actionDelegate = nil;
        [_headerAction cancel];
        [_headerAction release];
        _headerAction = nil;
    }
    if (_waitingHUB != nil) {
        [_waitingHUB hide:YES];
    }
    if(actionState == ACTION_SENDING){
        actionState = ACTION_NOT_BEGIN;
    }
}

- (BTNewStoryAction *)lastestStoryAction{
    if (_lastestStoryAction == nil) {
        NSInteger lastID = 0;
        if([self.itemArray count]>0){
            BTStory *data = [self.itemArray lastObject];
            lastID = [data.storyId integerValue];
        }
        _lastestStoryAction = [[BTNewStoryAction alloc] initWithListId:_homeID visibleLen:[self.itemArray count] lastID:lastID];
        _lastestStoryAction.actionDelegate = self;
    }
    return _lastestStoryAction;
}


- (BTNewStoryHeaderAction *)headerAction{
    if (_headerAction == nil) {
        _headerAction = [[BTNewStoryHeaderAction alloc] initWithListId:_homeID];
        _headerAction.actionDelegate = self;
    }
    return _headerAction;
}
@end
