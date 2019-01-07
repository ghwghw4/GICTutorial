#import "JSAPIExtension.h"
#import "PackageManager.h"
#import <GICXMLLayout/GICXMLLayout.h>

@implementation JSAPIExtension
+ (void)registeJSAPIToJSContext:(JSContext *)context{
   // 检查包更新
    context[@"CheckPackageUpdate"] = ^(){
        ASPerformBlockOnBackgroundThread(^{
            [[PackageManager manage] checkUpdate];
        });
    };
}
@end
