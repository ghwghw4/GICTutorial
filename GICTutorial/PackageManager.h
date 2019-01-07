#import <Foundation/Foundation.h>

@interface PackageManager : NSObject
+(instancetype)manage;
-(void)start;
-(void)restart;
-(void)checkUpdate;
@end
