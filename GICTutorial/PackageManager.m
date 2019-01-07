#import "PackageManager.h"
#import <GICXMLLayout/GICXMLLayout.h>
#import <GICXMLLayout/GICRouter.h>
#import <ZipArchive/ZipArchive.h>

#if DEBUG
#import "GICXMLLayoutDevTools.h"
#endif

// 当前APP版本
#define APPVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
// 本地存储APP版本，用来判断是否版本更新后第一次启动的
#define APPVersionKey @"APPVersionKey"

// 热更新后包在本地文件中的路径
#define PackageLocalRootPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/project"]

// 用来临时保存热更新zip包的，主要是用来zip解压缩的。用完后删除
#define PackageRootPathTempFileName [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/project.zip"]

#warning 将地址改成实际的API地址
#define HotUpdateUrl @"http://localhost:8080/hotupdate.php"

#define mark 热重载相关宏
#warning 开发的时候修改如下配置
#define HotReloading YES
#define HotReloadUrl @"http://localhost:8080"

@implementation PackageManager
+(instancetype)manage{
    static dispatch_once_t once;
    static PackageManager * instance = nil;
    dispatch_once(&once, ^ {
        instance = [[PackageManager alloc] init];
    });
    return instance;
}

-(void)start{
    // 设置跟目录
    [GICXMLLayout setRootUrl:[self checkRootPath]];
    
    // 加载页面
#if HotReloading == YES
    [GICXMLLayoutDevTools loadAPPFromPath:@"/App.xml"];
#else
    [GICRouter loadAPPFromPath:@"/App.xml"];
#endif
}

-(void)restart{
    [self start];
}

// 判断是否是版本更新后的第一次启动
-(BOOL)isFirstLaunch{
    NSString *oldVersion = [[NSUserDefaults standardUserDefaults] objectForKey:APPVersionKey];
    if(oldVersion == nil){
        [[NSUserDefaults standardUserDefaults] setValue:APPVersion forKey:APPVersionKey];
        return true;
    }
    
    if(![oldVersion isEqualToString:APPVersion]){
        [[NSUserDefaults standardUserDefaults] setValue:APPVersion forKey:APPVersionKey];
        return true;
    }
    return NO;
}

-(NSString *)checkRootPath{
#if HotReloading == YES
    return HotReloadUrl;
#endif
    /**
     isFirstLaunch  是为了在app 首次安装或者更新后首次打开的情况下，将根目录强制替换成 ipa包本身的目录。
     因为当app更新后，默认ipad包本身自带的包是最新的版本。
     这个判断主要是避免，当app本体更新后，如果将目录还是设置为本地document中的目录的话，那么导致显示的页面反而不是最新的
     */
    if(![self isFirstLaunch] && [[NSFileManager defaultManager] fileExistsAtPath:PackageLocalRootPath isDirectory:nil]){
        return PackageLocalRootPath;
    }
    return [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"project"];
}

-(void)checkUpdate{
    // 获取package版本号
    NSData *jsonData = [GICXMLLayout loadDataFromPath:@"package.json"];
    if(!jsonData){
        return;
    }
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSString *currentPackageVersion = jsonDict[@"version"];
    
    // 从服务端API查询是否有最新的包需要更新
    NSString *apiUrl = [NSString stringWithFormat:@"%@?appVersion=%@&packgeVersion=%@",HotUpdateUrl,APPVersion,currentPackageVersion];
    NSData *apidata =  [NSData dataWithContentsOfURL:[NSURL URLWithString:apiUrl]];
    if(!apidata){
        return;
    }
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:apidata options:0 error:nil];
    if(result && [[result objectForKey:@"code"] integerValue] == 200){
        NSDictionary *data = [result objectForKey:@"data"];
        if(data){
            NSString *url = [data objectForKey:@"packageUrl"];
            [self updatePackage:url];
        }else{
            [self showAlert:@"没有可以更新的包"];
        }
    }
}

-(void)showAlert:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"了解" otherButtonTitles: nil];
        [alert show];
    });
}

// 更新包
-(void)updatePackage:(NSString *)url{
    NSData *zipData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if(zipData){
        // 将下载的临时保存到document中，为解压缩做准备
        [zipData writeToFile:PackageRootPathTempFileName atomically:YES];
        // 开始解压缩
        ZipArchive* zip = [[ZipArchive alloc] init];
        NSString* unZipTo = PackageLocalRootPath;
        if( [zip UnzipOpenFile:PackageRootPathTempFileName] ){
            // 解压缩，并且覆盖解压
            BOOL result = [zip UnzipFileTo:unZipTo overWrite:YES];
            if( NO==result ){
                // 解压缩失败
            }else{
                // 解压缩成功
                ASPerformBlockOnMainThread(^{
                    [self restart];
                });
                [self showAlert:@"更新成功"];
            }
            [zip UnzipCloseFile];
        }
        // 删除临时zip包
        if([[NSFileManager defaultManager] removeItemAtPath:PackageRootPathTempFileName error:nil]){
            // 删除成功
        }else{
            // 删除失败
        }
    }
}
@end

