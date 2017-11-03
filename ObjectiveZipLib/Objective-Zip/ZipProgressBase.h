//
//  ZipProgressBase.h
//

#import <Foundation/Foundation.h>
#import "OZProgressDelegate.h"

#include <map>
#include <string>


// forward declarations
@class OZZipFile;


//
// ZipProgressBase
//
@interface ZipProgressBase : NSObject
{
@protected
   NSURL *              _zipFileURL;
   NSError *            _zipFileError;
   OZZipFile *          _zipTool;
   
   __weak id<OZProgressDelegate> _zipDelegate;
   
   unsigned long long   _totalFileSize;
   unsigned long long   _totalDestinationBytesWritten;
}

// ideally, protected methods
- (id) initWithZipFile:(NSURL *)zipFileURL
               forMode:(unsigned) mode
          withDelegate:(id<OZProgressDelegate>)delegate;

- (BOOL) createZipToolIfNeeded;
- (void) performZipToolCleanup;

- (BOOL) prepareForOperation;

- (void) addToFilesCreated:(NSURL *) url;
- (void) performFileCleanup;

- (void) notifyError:(NSError *)error;
- (void) setError:(NSError *)error andNotify:(BOOL)notify;
- (void) setErrorCode:(NSInteger)code errorMessage:(NSString *)message andNotify:(BOOL)notify;

- (void) setCancelError;
- (void) setCancelErrorAndCleanup;

- (BOOL) insureAdequateDiskSpaceInFolder:(NSURL *)location
                                 forSize:(unsigned long long) spaceNeeded
                      andFreeSpaceBuffer:(unsigned long long) bufferSpaceRemaining;

// public methods
- (void) setProgressDelegate:(id<OZProgressDelegate>)delegate;

@property (assign, atomic) BOOL cancelOperation;

@end
