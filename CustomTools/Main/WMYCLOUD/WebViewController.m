//
//  WebViewController.m
//  CustomTools
//
//  Created by yizhi on 2021/2/23.
//  Copyright © 2021 yuyuyu. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()<WKScriptMessageHandler>
@property (strong, nonatomic) WKWebView *contentWebView;

@end


@implementation WebViewController

- (WKWebView *)contentWebView {
    if (!_contentWebView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        [configuration.userContentController addScriptMessageHandler:self name:@"changeUIViewColor"];
        _contentWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 300, COMMON_SCREEN_WIDTH, self.view.frame.size.height - 300) configuration:configuration];
    }
    return _contentWebView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)dealloc {
    [self.contentWebView.configuration.userContentController removeScriptMessageHandlerForName:@"changeUIViewColor"];
}

- (void)setupUI {
    [self.view addSubview:self.contentWebView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    [self.contentWebView loadFileURL:url allowingReadAccessToURL:url];
}


- (IBAction)jsInHtml:(UIButton *)sender {
    [self.contentWebView evaluateJavaScript:@"changeBgColor('blue')" completionHandler:NULL];
}

- (IBAction)jsInComponent:(UIButton *)sender {
    [self.contentWebView evaluateJavaScript:@"functionInComponent()" completionHandler:NULL];
}

- (IBAction)originJs:(UIButton *)sender {
    [self.contentWebView evaluateJavaScript:@"sessionStorage.setItem('isAPPEnableSign', '1')" completionHandler:NULL];
}




- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"didReceiveScriptMessage: %@---%@", message.name, message.body);
    if ([message.name isEqualToString:@"changeUIViewColor"]) {
        self.view.backgroundColor = [UIColor redColor];
    }
}
@end
