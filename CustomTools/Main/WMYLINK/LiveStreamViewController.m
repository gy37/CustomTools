//
//  LiveStreamViewController.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/10.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "LiveStreamViewController.h"
#import "UIButton+Custom.h"
#import "CustomAlertView.h"
#import "LiveManager.h"
#import "LiveModel.h"
//#import <IQKeyboardManager.h>
#import "KeyboardAboveView.h"
//#import "LiveChatTableViewCell.h"
#import "CustomActionSheet.h"
#import "WebSocketManager.h"
#import <AFNetworkReachabilityManager.h>
#import "WeChatManager.h"
#import <CallKit/CallKit.h>

@interface LiveStreamViewController ()<UITableViewDelegate, UITableViewDataSource, CXCallObserverDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@property (strong, nonatomic) KeyboardAboveView *aboveView;

@property (strong, nonatomic) NSTimer *liveTimer;
@property (assign, nonatomic) NSTimeInterval timeInterval;
@property (strong, nonatomic) NSMutableArray *dataSource;
@end

@implementation LiveStreamViewController
CGFloat chatCellHeight = 32;

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
//    [[IQKeyboardManager sharedManager] setEnable:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
//    [[IQKeyboardManager sharedManager] setEnable:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

#pragma mark - set get

- (KeyboardAboveView *)aboveView {
    if (!_aboveView) {
        _aboveView = [[KeyboardAboveView alloc] initWithFrame:CGRectMake(0, COMMON_SCREEN_HEIGHT, COMMON_SCREEN_WIDTH, 84)];
        _aboveView.hidden = YES;
    }
    return _aboveView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - parivate

- (void)setupUI {
    //top
//    [self.topView updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeTop constant:COMMON_STATUS_BAR_HEIGHT + 15];
    [self.topView setCornerRadiusHalfHeight];
    [self.headImageView setCornerRadiusHalfHeight];
    [self.closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
    [self.closeButton setCornerRadiusHalfHeight];
    [self.cameraButton setupButtonWithIconName:@"\U0000e61d" iconSize:24 iconColor:[UIColor whiteColor]];
    
    //middle
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    
    //bottom
    self.bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.001];
//    [self.bottomView updateOtherViewRealtedNSLayoutConstraint:NSLayoutAttributeBottom constant:COMMON_SAFE_AREA_BOTTOM_HEIGHT + 12];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"   和朋友们聊聊吧~" attributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor] }];
    self.chatTextField.attributedPlaceholder = attrString;
    self.chatTextField.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    [self.chatTextField setCornerRadiusHalfHeight];
    [self.chatTextField addTarget:self action:@selector(emptyTextField:) forControlEvents:UIControlEventEditingChanged];
    
    [self.pauseButton setupButtonWithIconNames:@[@"\U0000e619", @"\U0000e670"] iconSize:24 iconColor:[[UIColor blackColor] colorWithAlphaComponent:0.45]];
    [self.shareButton setImage:[UIImage imageNamed:@"live_share"] forState:UIControlStateNormal];
    [self.shareButton setCornerRadiusHalfHeight];
    [self.likeButton setImage:[UIImage imageNamed:@"live_like"] forState:UIControlStateNormal];
    [self.likeButton setCornerRadiusHalfHeight];
    [self.likeCountLabel setCornerRadiusHalfHeight];
    
    //keyboard view
    [self.view addSubview:self.aboveView];
    [self.aboveView setCornerRadius:5 corners:UIRectCornerTopLeft | UIRectCornerTopRight];
    @weakify(self);
    self.aboveView.sendText = ^(NSString * _Nonnull text) {
        @strongify(self);
        NSDictionary *info = @{
            @"operateType": @1,
            @"bizType": @20,
            @"bizId": @(self.liveModel.ID),
            @"accountId": @(self.liveModel.accountId),
            @"subscribeDestination": SOCKET_SUBSCRIBE_URL(@(self.liveModel.ID)),
            @"content": [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]
        };
        [[WebSocketManager sharedManager] sendMessage:info];
    };
}

- (void)setupValue {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAboveView:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAboveView:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 监听电话
    CXCallObserver *callObserver = [[CXCallObserver alloc] init];
    [callObserver setDelegate:self queue:dispatch_get_main_queue()];
    
    //default value
    self.headImageView.image = [UIImage imageNamed:@"head"];
    self.titleLabel.text = @"直播标题";
    self.countLabel.text = [NSString stringWithFormat:@"%@人正在观看", [NSString getCountString:0]];
    self.timeLabel.text = @"00:00";

    [self.likeButton setImage:[UIImage imageNamed:@"live_like"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"live_liked"] forState:UIControlStateSelected];
    self.likeCountLabel.text = @"";

    [self setupLiveInfo];
    [self setupWebSocket];
    [self startNetwrokMonitoring];
}

- (void)setupLiveInfo {
//    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
    self.titleLabel.text = self.liveModel.title;
    
    if (!self.liveModel || !self.liveModel.pushUrl || [self.liveModel.pushUrl isEqualToString:@""]) {
        [CustomProgressHUD showTextHUD:@"获取推流地址失败"];
        return;
    }
    [[LiveManager sharedManager] startStreamingInController:self toPath:self.liveModel.pushUrl success:^{
        @weakify(self);
        self.liveTimer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"live timer start");
            @strongify(self);
            self.timeInterval ++;
            self.timeLabel.text = [NSString getTimeIntervalString:self.timeInterval];
            
            if ((int)self.timeInterval % 5 == 0) {
                [self getOnlineNumber];
                [self getLikeNumber];
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:self.liveTimer forMode:NSRunLoopCommonModes];
    }];
}

- (void)setupWebSocket {
    if (!self.liveModel) {
        NSLog(@"请先开启直播");
        return;
    }
    WebSocketManager *manager = [WebSocketManager sharedManager];
    [manager openWebSocketWithId:self.liveModel.ID];
    [manager setReceiveMessage:^(NSDictionary *message) {
        NSString *content = [[message[@"content"] getSafetyObject] stringByRemovingPercentEncoding];
        [self.dataSource addObject:@{@"nickName": [message[@"nickName"] getSafetyObject], @"content": content}];
        [self refreshChatTableView];
    }];
}

- (void)startNetwrokMonitoring {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"网络类型：未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"网络类型：断网");
                [CustomProgressHUD showTextHUD:@"网络连接不可用"];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"网络类型：数据流量");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"网络类型：WIFI");
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)getOnlineNumber {
//    NSDictionary *parameters = @{
//        @"channelId": @(self.liveModel.channelId),
//        @"id": @(self.liveModel.ID)
//    };
//    [NetWorkTool postUrlPath:LIVE_ONLINE_NUMBER parameters:parameters success:^(NSDictionary * _Nonnull response) {
//        if ([response[@"code"] integerValue] == 1000) {
//            self.countLabel.text = [NSString stringWithFormat:@"%@人正在观看", [NSString getCountString:[response[@"data"] integerValue]]];
//        }
//    } failed:^(NSError * _Nonnull error) {
//    }];
}

- (void)getLikeNumber {
//    NSDictionary *parameters = @{
//        @"bizAccountId": @(self.liveModel.accountId),
//        @"bizId": @(self.liveModel.ID),
//        @"bizType": @20
//    };
//    [NetWorkTool postUrlPath:COMMON_LIKE_COUNT parameters:parameters success:^(NSDictionary * _Nonnull response) {
//        if ([response[@"code"] integerValue] == 1000) {
//            NSInteger count = [response[@"data"][@"count"] integerValue];
//            self.likeCountLabel.text = count == 0 ? @"" : [NSString getCountString:count];
//        }
//    } failed:^(NSError * _Nonnull error) {
//    }];
}

#pragma mark - selector

- (IBAction)closeLiveStream:(UIButton *)sender {
    [CustomAlertView showConfirm:@"关闭直播后将无法进入\n确定关闭吗？" confirmBlock:^{
        [[LiveManager sharedManager] stopStreaming];
        [self.liveTimer invalidate];
        self.liveTimer = nil;
        [[WebSocketManager sharedManager] closeWebSocket];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [(UINavigationController *)KEY_WINDOW.rootViewController popToRootViewControllerAnimated:NO];
            [self dismissViewControllerAnimated:YES completion:NULL];
        });
    }];
}

- (IBAction)changeCamera:(UIButton *)sender {
    [[LiveManager sharedManager] toggleCamera];
}

- (IBAction)pause:(UIButton *)sender {
//    sender.selected = !sender.selected;
//    NSDictionary *parameters = @{
//        @"channelId": @(self.liveModel.channelId),
//        @"id": @(self.liveModel.ID)
//    };
//    [NetWorkTool postUrlPath:sender.selected ? LIVE_RESUME : LIVE_PAUSE parameters:parameters success:^(NSDictionary * _Nonnull response) {
//
//    } failed:^(NSError * _Nonnull error) {
//    }];
}

- (IBAction)share:(UIButton *)sender {
    [CustomActionSheet showActionSheet:CustomActionSheetTypeHorizontal images:@[@"wechat"] titles:@[@"分享给好友"] clickedAt:^(NSInteger index) {
        NSString *desc = [NSString stringWithFormat:@"%@的直播", @"测试测试测试"];
        [[WeChatManager sharedManager] shareToWeChatWithType:WeChatTypeFriends title:self.liveModel.title desc:desc image:self.liveModel.logoImage link:self.liveModel.pullUrl];
    }];
}

- (IBAction)like:(UIButton *)sender {
    sender.selected = !sender.selected;
//    NSString *url = sender.selected ? COMMON_LIKE_ADD : COMMON_LIKE_REDUCE;
//    NSDictionary *parameters = @{
//        @"bizAccountId": @(self.liveModel.accountId),
//        @"bizId": @(self.liveModel.ID),
//        @"bizType": @20
//    };
//    [NetWorkTool postUrlPath:url parameters:parameters success:^(NSDictionary * _Nonnull response) {
//        if ([response[@"code"] integerValue] == 1000) {
//            NSInteger count = [response[@"data"][@"count"] integerValue];
//            self.likeCountLabel.text = count == 0 ? @"" : [NSString getCountString:count];
//        }
//    } failed:^(NSError * _Nonnull error) {
//    }];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = self.dataSource[indexPath.row];
    CGFloat width = [[info[@"nickName"] getSafetyObject] getTextWidthWithHeight:20 fontSize:12] + 4;
    width = MIN(width, tableView.width / 2);
    CGFloat height = [[info[@"content"] getSafetyObject] getTextHeightWithWidth:tableView.width - 10 * 3 - width fontSize:14] + 4;
    height = MAX(height, chatCellHeight);
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = self.dataSource[indexPath.row][@"content"];
    return cell;
}

#pragma mark - private

- (void)emptyTextField:(UITextField *)textField {
    textField.text = @"";
}

- (void)showAboveView:(NSNotification *)notification {
    self.aboveView.hidden = NO;
    CGPoint origin = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    self.aboveView.x = origin.x;
    self.aboveView.y = origin.y - self.aboveView.height;
}

- (void)hideAboveView:(NSNotification *)notification {
    CGPoint origin = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    self.aboveView.x = origin.x;
    self.aboveView.y = COMMON_SCREEN_HEIGHT;
    self.aboveView.hidden = YES;
    [self.chatTextField resignFirstResponder];
}


- (void)refreshChatTableView {
    [self.chatTableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//0.01s延时，直接执行没效果
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

- (void)didEnterBackground:(NSNotification *)notification {
    NSLog(@"didEnterBackground pauseStreaming");
    [[LiveManager sharedManager] pauseStreaming];
}

- (void)willEnterForeground:(NSNotification *)notification {
    NSLog(@"willEnterForeground resumeStreaming");
    [[LiveManager sharedManager] resumeStreaming];
}

#pragma mark - cxobserverdelegate

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    if (call.hasEnded) {
        NSLog(@"挂断电话Call has been disconnected");
        [[LiveManager sharedManager] startPushWithUrl:self.liveModel.pushUrl];
    } else if (call.hasConnected) {
        NSLog(@"电话通了Call has just been connected");
        [[LiveManager sharedManager] stopPush];
    }
}

@end
