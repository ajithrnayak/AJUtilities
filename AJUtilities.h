//
//  AJUtilities.h
//  AJzUtilities
//
//  Created by Ajith R Nayak on 01/07/14.
//  Copyright (c) 2014 Ajith R Nayak. All rights reserved.
//

#import <Foundation/Foundation.h>

#define castIf(CLASSNAME, OBJ)                                                 \
  ((CLASSNAME *)([NSObject cast:[CLASSNAME class] forObject:OBJ]))
#define RGB(r, g, b)                                                           \
  [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:1]
#define RGBA(r, g, b, a)                                                       \
  [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:a]


#pragma mark - ###--- NSFoundation ---###

@interface NSObject (AJUtils)

+ (instancetype)instance;

- (BOOL)isEqualToNull;

+ (id)cast:(Class)requiredClass forObject:(id)object;

+ (dispatch_queue_t)backgroundQueue;

@end

@interface NSArray (AJUtils)

- (NSArray *)arrayWithObjectsCollectedFromBlock:(id (^)(id object))block;

@end

@interface NSMutableArray (AJUtils)

- (void)shuffleMe;

@end

@interface NSDate (AJUtils)

+ (NSDate *)dateFromISO8601String:(NSString *)iso8601String;

- (NSString *)stringInISO8601Format;

@end

@interface NSString (AJUtils)
// Returns a Boolean if the receiver contains the given `string`.
- (BOOL)containsString:(NSString *)string;

+ (NSString *)stringWithUUID;
@end

#pragma mark - ###--- UIKit ---###

@interface UIApplication (AJUtils)

- (NSURL *)documentDirectoryURL;
- (NSURL *)downloadsDirectoryURL;
- (NSURL *)libraryDirectoryURL;
- (NSURL *)cachesDirectoryURL;
- (NSURL *)applicationSupportDirectoryURL;

@end

@interface UIControl (AJUtils)

- (void)removeAllTargets;

@end

@interface UIDevice (AJUtils)

- (BOOL)isSimulator;

@end

@interface UIScreen (AJUtils)

- (BOOL)isRetina;

@end

@interface UIScrollView (AJUtils)

- (void)scrollToTopAnimated:(BOOL)animated;

@end

@interface UIView (AJUtils)
/**Takes a screenshot of the underlying `CALayer` of the receiver and
 returns a `UIImage` object representation. */
- (UIImage *)screenShot;

- (CGPoint)centerOfScreen;

- (void)fadeOut;
- (void)fadeOutAndRemoveFromSuperview;
- (void)fadeIn;
@end

@interface UIViewController (AJUtils)

- (void)showAlertWithError:(NSError *)error;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)string;

@end

#pragma mark - Some love for 'C'

dispatch_queue_t backgroundQueue();

/*** USAGE: $_castIf. . . . .(Autocomplete should do the rest) ****/
id _castIf(Class, id);
id _castIfNotNSNull(id);

#pragma mark - ###--- Utilities ---###

@interface AJUtilities : NSObject

+ (NSString *)nameFromEmail:(NSString *)email;

+ (BOOL)validateEmailWithString:(NSString *)email;

+ (NSString *)ipAddress;

+ (uint64_t)availableDiskSpace;
+ (float)freeDiskSpace;

@end
