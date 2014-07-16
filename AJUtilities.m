//
//  AJUtilities.m
//  AJzUtilities
//
//  Created by Ajith R Nayak on 01/07/14.
//  Copyright (c) 2014 Ajith R Nayak. All rights reserved.
//

#import "AJUtilities.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

id _castIf(Class requiredClass, id object) {
  if (object && ![object isKindOfClass:requiredClass])
    object = nil;
  return object;
}

id _castIfNotNSNull(id object) {
  return (!object && [object isKindOfClass:[NSNull class]]) ? nil : object;
}

dispatch_queue_t backgroundQueue() {
  static dispatch_once_t queueCreationGuard;
  static dispatch_queue_t queue;
  dispatch_once(&queueCreationGuard, ^{
      queue =
          dispatch_queue_create("com.companyName.myAppName.backgroundQueue", 0);
  });
  return queue;
}

@implementation NSObject (AJUtils)

+ (instancetype)instance {
  return [[self alloc] init];
}

- (BOOL)isEqualToNull {
  return (self == [NSNull null]);
}

+ (id)cast:(Class)requiredClass forObject:(id)object {
  if (object && ![object isKindOfClass:requiredClass])
    object = nil;
  return object;
}

+ (dispatch_queue_t)backgroundQueue {
  static dispatch_once_t queueCreationGuard;
  static dispatch_queue_t queue;
  dispatch_once(&queueCreationGuard, ^{
      // Rename the queue like "com.companyName.myAppName.backgroundQueueName"
      queue = dispatch_queue_create("BackgroundQueue", 0);
  });
  return queue;
}

@end

@implementation NSArray (AJUtils)

- (NSArray *)arrayWithObjectsCollectedFromBlock:(id (^)(id object))block {

  __block NSMutableArray *collector =
      [[NSMutableArray alloc] initWithCapacity:self.count];

  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [collector addObject:block(obj)];
  }];

  return collector;
}
@end

@implementation NSMutableArray (AJUtils)

- (void)shuffleMe {
  for (NSInteger i = [self count] - 1; i > 0; i--) {
    [self exchangeObjectAtIndex:arc4random_uniform((u_int32_t)i + 1)
              withObjectAtIndex:i];
  }
}

@end

@implementation NSDate (AJUtils)

+ (NSDate *)dateFromISO8601String:(NSString *)iso8601 {
  // Return nil if nil is given
  if (!iso8601 || [iso8601 isEqual:[NSNull null]]) {
    return nil;
  }

  // Parse number
  if ([iso8601 isKindOfClass:[NSNumber class]]) {
    return [NSDate
        dateWithTimeIntervalSince1970:[(NSNumber *)iso8601 doubleValue]];
  }

  // Parse string
  else if ([iso8601 isKindOfClass:[NSString class]]) {
    const char *str = [iso8601 cStringUsingEncoding:NSUTF8StringEncoding];
    size_t len = strlen(str);
    if (len == 0) {
      return nil;
    }

    struct tm tm;
    char newStr[25] = "";
    BOOL hasTimezone = NO;

    // 2014-03-30T09:13:00Z
    if (len == 20 && str[len - 1] == 'Z') {
      strncpy(newStr, str, len - 1);
    }

    // 2014-03-30T09:13:00-07:00
    else if (len == 25 && str[22] == ':') {
      strncpy(newStr, str, 19);
      hasTimezone = YES;
    }

    // 2014-03-30T09:13:00.000Z
    else if (len == 24 && str[len - 1] == 'Z') {
      strncpy(newStr, str, 19);
    }

    // 2014-03-30T09:13:00.000-07:00
    else if (len == 29 && str[26] == ':') {
      strncpy(newStr, str, 19);
      hasTimezone = YES;
    }

    // Poorly formatted timezone
    else {
      strncpy(newStr, str, len > 24 ? 24 : len);
    }

    // Timezone
    size_t l = strlen(newStr);
    if (hasTimezone) {
      strncpy(newStr + l, str + len - 6, 3);
      strncpy(newStr + l + 3, str + len - 2, 2);
    } else {
      strncpy(newStr + l, "+0000", 5);
    }

    // Add null terminator
    newStr[sizeof(newStr) - 1] = 0;

    if (strptime(newStr, "%FT%T%z", &tm) == NULL) {
      return nil;
    }

    time_t t;
    t = mktime(&tm);

    return [NSDate dateWithTimeIntervalSince1970:t];
  }

  NSAssert1(NO, @"Failed to parse date: %@", iso8601);
  return nil;
}

- (NSString *)stringInISO8601Format {
  struct tm *timeinfo;
  char buffer[80];

  time_t rawtime = (time_t)[self timeIntervalSince1970];
  timeinfo = gmtime(&rawtime);

  strftime(buffer, 80, "%Y-%m-%dT%H:%M:%SZ", timeinfo);

  return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

@end

@implementation NSString (AJUtils)

- (BOOL)containsString:(NSString *)string {
  return !NSEqualRanges([self rangeOfString:string],
                        NSMakeRange(NSNotFound, 0));
}

+ (NSString *)stringWithUUID {
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);
  return (__bridge_transfer NSString *)string;
}

@end

#pragma mark---### UIKit ###---

@implementation UIApplication (AJUtils)
- (NSURL *)documentDirectoryURL {
  return [[[NSFileManager defaultManager]
      URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)cachesDirectoryURL {
  return [[[NSFileManager defaultManager]
      URLsForDirectory:NSCachesDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)downloadsDirectoryURL {
  return [[[NSFileManager defaultManager]
      URLsForDirectory:NSDownloadsDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)libraryDirectoryURL {
  return [[[NSFileManager defaultManager]
      URLsForDirectory:NSLibraryDirectory
             inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationSupportDirectoryURL {
  return [[[NSFileManager defaultManager]
      URLsForDirectory:NSApplicationSupportDirectory
             inDomains:NSUserDomainMask] lastObject];
}

@end

@implementation UIControl (AJUtils)

- (void)removeAllTargets {
  [[self allTargets] enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
      [self removeTarget:object
                    action:NULL
          forControlEvents:UIControlEventAllEvents];
  }];
}

@end

@implementation UIDevice (AJUtils)

- (BOOL)isSimulator {
  static NSString *simulatorModel = @"iPhone Simulator";
  return [[self model] isEqualToString:simulatorModel];
}

@end

@implementation UIScreen (AJUtils)

- (BOOL)isRetina {
  static dispatch_once_t predicate;
  static BOOL answer;

  dispatch_once(&predicate, ^{
      answer =
          ([self respondsToSelector:@selector(scale)] && [self scale] == 2.0f);
  });
  return answer;
}

@end

@implementation UIScrollView (AJUtils)

- (void)scrollToTopAnimated:(BOOL)animated {
  [self setContentOffset:CGPointMake(0.0f, 0.0f) animated:animated];
}

@end

@implementation UIView (AJUtils)

- (UIImage *)screenShot {
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
  [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

- (CGPoint)centerOfScreen {
  UIInterfaceOrientation orientation =
      [UIApplication sharedApplication].statusBarOrientation;
  return UIInterfaceOrientationIsLandscape(orientation)
             ? CGPointMake(self.center.y, self.center.x)
             : self.center;
}

- (void)fadeOut {
  UIView *view = self;
  [UIView animateWithDuration:0.2
                        delay:0.0
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{ view.alpha = 0.0f; }
                   completion:nil];
}

- (void)fadeOutAndRemoveFromSuperview {
  UIView *view = self;
  [UIView animateWithDuration:0.2
      delay:0.0
      options:UIViewAnimationOptionAllowUserInteraction
      animations:^{ view.alpha = 0.0f; }
      completion:^(BOOL finished) { [view removeFromSuperview]; }];
}

- (void)fadeIn {
  UIView *view = self;
  [UIView animateWithDuration:0.2
                        delay:0.0
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{ view.alpha = 1.0f; }
                   completion:nil];
}
@end

@implementation UIViewController (AJUtils)

- (void)showAlertWithError:(NSError *)error {
  if (!error)
    return;
  UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:@"Error"
                                 message:[error localizedDescription]
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil];
  [alert show];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)string {
  if (!string)
    return;
  UIAlertView *anAlert =
      [[UIAlertView alloc] initWithTitle:title ? title : @"Alert"
                                 message:string
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil];
  [anAlert show];
}
@end

@implementation AJUtilities

+ (NSString *)nameFromEmail:(NSString *)email {

  if (email) {
    // create components of email separating by |@|
    NSArray *emailComponents = [email componentsSeparatedByString:@"@"];
    if (emailComponents.count)
      // pick the first part
      return emailComponents[0];
  }
  return nil;
}

+ (BOOL)validateEmailWithString:(NSString *)email {
  BOOL stricterFilter = YES;
  NSString *stricterFilterString =
      @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
  NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
  NSPredicate *emailTest =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
  return [emailTest evaluateWithObject:email];
}

+ (NSString *)ipAddress {

  NSString *address = @"error";
  struct ifaddrs *interfaces = NULL;
  struct ifaddrs *temp_addr = NULL;
  int success = 0;
  // retrieve the current interfaces - returns 0 on success
  success = getifaddrs(&interfaces);
  if (success == 0) {
    // Loop through linked list of interfaces
    temp_addr = interfaces;
    while (temp_addr != NULL) {
      if (temp_addr->ifa_addr->sa_family == AF_INET) {
        // Check if interface is en0 which is the wifi connection on the iPhone
        if ([[NSString stringWithUTF8String:temp_addr->ifa_name]
                isEqualToString:@"en0"]) {
          // Get NSString from C String
          address = [NSString
              stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)
                                              temp_addr->ifa_addr)->sin_addr)];
        }
      }
      temp_addr = temp_addr->ifa_next;
    }
  }
  // Free memory
  freeifaddrs(interfaces);
  return address;
}

// TODO: returns ~200 MB more than the iOS calculation
+ (uint64_t)availableDiskSpace {

  uint64_t totalSpace = 0;
  uint64_t totalFreeSpace = 0;
  NSError *error;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSDictionary *dictionary = [[NSFileManager defaultManager]
      attributesOfFileSystemForPath:[paths lastObject]
                              error:&error];

  if (dictionary) {
    NSNumber *fileSystemSizeInBytes = dictionary[NSFileSystemSize];
    NSNumber *freeFileSystemSizeInBytes = dictionary[NSFileSystemFreeSize];
    totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
    totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    NSLog(@"Memory Capacity of %llu MB with %llu MB Free memory available.",
          ((totalSpace / 1024ll) / 1024ll),
          ((totalFreeSpace / 1024ll) / 1024ll));
  } else {
    NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld",
          [error domain], (long)[error code]);
  }

  return ((totalFreeSpace / 1024ll) / 1024ll);
}

+ (float)freeDiskSpace {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  struct statfs tStats;
  statfs([[paths lastObject] cString], &tStats);
  float total_space = (float)(tStats.f_bavail * tStats.f_bsize);

  return ((total_space / 1024) / 1024);
}

@end
