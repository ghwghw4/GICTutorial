#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

static double MainLaunchTime;
void BeginLaunch(){
    MainLaunchTime = CFAbsoluteTimeGetCurrent();
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    double endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"LaunchTime:%@",@(endTime - MainLaunchTime));
}

@end
