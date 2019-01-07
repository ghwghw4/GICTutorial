#import "GICXMLLayoutDevTools.h"
#import "GICRouter.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface GICXMLLayoutDevTools()<UIWebViewDelegate>

@end

@implementation GICXMLLayoutDevTools

+(void)loadPage:(NSString *)path{
    [GICRouter loadAPPFromPath:path];
//    UIWindow *w = [UIApplication sharedApplication].delegate.window;
//    UIButton *btnReload = [[UIButton alloc] initWithFrame:CGRectMake(w.bounds.size.width-60 -15, w.bounds.size.height-44-40, 60, 44)];
//    [btnReload setTitle:@"reload" forState:UIControlStateNormal];
//    [btnReload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    btnReload.layer.borderColor = [UIColor blackColor].CGColor;
//    btnReload.layer.borderWidth = 1;
//    [w addSubview:btnReload];
//    [[btnReload rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//        [btnReload removeFromSuperview];
//        [self loadAPPFromPath:path];
//    }];
}
static UIWebView *websocketWebview = nil;
static NSString *_rootPath= nil;
+(void)loadAPPFromPath:(NSString *)path{
    _rootPath = path;
    [self loadPage:path];
    if(websocketWebview==nil){
         NSURL *rootUrl = [NSURL URLWithString:[GICXMLLayout rootUrl]];
        if([rootUrl.scheme hasPrefix:@"http"]){
            websocketWebview = [[UIWebView alloc] init];
            websocketWebview.delegate = self;
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"GICFileWatcher.html"]];
            [websocketWebview loadHTMLString:[[NSString alloc] initWithData:data encoding:4] baseURL:nil];
        }
    }
}

+ (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSURL *rootUrl = [NSURL URLWithString:[GICXMLLayout rootUrl]];
     NSString *wsurl = [NSString stringWithFormat:@"ws://%@:%@/",rootUrl.host,rootUrl.port];
    
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"onmessage"] = ^(NSString *msg){
        dispatch_async(dispatch_get_main_queue(), ^{
            [GICXMLLayoutDevTools loadPage:_rootPath];
        });
    };
    [context[@"beginConnect"] callWithArguments:@[wsurl]];
}
@end
