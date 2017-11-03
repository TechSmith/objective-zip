//
//  ZipProgressBase.mm
//

#import "ZipProgressBase.h"

#import "OZZipException.h"
#import "OZZipErrorCodes.h"
#import "OZZipFile+Standard.h"


//
// ZipProgressBase private interface
//
@interface ZipProgressBase()
{
   NSMutableArray *  _filesCreated;
   OZZipFileMode       _zipFileMode;
}

@end


//
// ZipProgressBase   
//
@implementation ZipProgressBase

- (id) initWithZipFile:(NSURL *)zipFileURL
               forMode:(unsigned) mode
          withDelegate:(id<OZProgressDelegate>)delegate;
{
   if (self = [self init])
   {
      [self setProgressDelegate:delegate];
      
      _zipFileURL = [zipFileURL copy];
      _zipFileMode = (OZZipFileMode)mode;
      
      if (![self createZipToolIfNeeded]) return nil;
   }
   
   return self;
}

- (void)dealloc
{
   @try
   {
      [self performZipToolCleanup];
   }
   @catch ( NSException * e )
   {
      NSLog(@"Exception thrown deallocing ZipProgressBase %@", e);
   }
   @catch ( id )
   {
      NSLog(@"Exception thrown deallocing ZipProgressBase");
   }
}

- (void) setProgressDelegate:(id<OZProgressDelegate>)delegate
{
   _zipDelegate = delegate;
}

#pragma mark helpers
// protected methods

- (BOOL) createZipToolIfNeeded
{
   if (_zipTool == nil)
   {
      @try
      {
         _zipTool = [[OZZipFile alloc] initWithFileName:[_zipFileURL path] mode:_zipFileMode];
      }
      @catch (OZZipException * exception)
      {
         [self setErrorCode:exception.error errorMessage:exception.reason andNotify:YES];
         _zipTool = nil;   // something failed during initialization
      }
   }
   
   return (_zipTool != nil);
}

- (void) performZipToolCleanup
{
   if (_zipTool)
   {
      // make sure we only ever call close once.  close can throw, leaving us in a weird state.
      OZZipFile * tempZipTool = _zipTool;
      _zipTool = nil;
      [tempZipTool close];
   }
}

- (BOOL) prepareForOperation
{
   _totalDestinationBytesWritten = 0;
   [_filesCreated removeAllObjects];
   [self createZipToolIfNeeded];
   
   return (_zipTool == nil)? NO : YES;
}

- (void) addToFilesCreated:(NSURL *) url
{
   if (_filesCreated == nil)
      _filesCreated = [NSMutableArray new];
   
   if (url)
      [_filesCreated addObject:url];
}

- (void) performFileCleanup
{
   // release the zip tool so it is not hanging onto any files
   [self performZipToolCleanup];
   
   // clean up all of the files we have created
   for (NSURL * url in _filesCreated)
   {
      NSError * error = nil;
      BOOL result = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
      if (result == NO || error != nil)
         [self notifyError:error];
   }
}

- (void) notifyError:(NSError *)error
{
   if (_zipDelegate && error)
   {
      [_zipDelegate updateError:error];
   }
}

- (void) setError:(NSError *)error andNotify:(BOOL)notify
{
   if (error)
   {
      _zipFileError = error;
      if (notify) [self notifyError:_zipFileError];
   }
}

- (void) setErrorCode:(NSInteger)code errorMessage:(NSString *)message andNotify:(BOOL)notify
{
   if (message == nil) message = ZipErrorCodes.OZCEM_Indeterminate;
   
   [self setError:[NSError errorWithDomain:ZipErrorCodes.OZCEM_ZipErrorDomain
                                      code:code
                                  userInfo:[NSDictionary
                                            dictionaryWithObject:message
                                            forKey:NSLocalizedDescriptionKey]]
        andNotify:notify];
}

- (void) setCancelError
{
   [self setErrorCode:ZipErrorCodes.OZCEC_UserCancelled
         errorMessage:ZipErrorCodes.OZCEM_UserCancelled
            andNotify:YES];
}

- (void) setCancelErrorAndCleanup
{
   [self setCancelError];
   [self performFileCleanup];
}

- (BOOL) insureAdequateDiskSpaceInFolder:(NSURL *)location
                                 forSize:(unsigned long long) spaceNeeded
                      andFreeSpaceBuffer:(unsigned long long) bufferSpaceRemaining
{
   if (spaceNeeded)
   {
      NSError * error = nil;
      NSDictionary * dict = [[NSFileManager defaultManager]
                             attributesOfFileSystemForPath:[location path] error:&error];
      
      if (dict == nil || error != nil)
      {
         [self setErrorCode:ZipErrorCodes.OZCEC_CannotReadSystemFolderAttributes
               errorMessage:ZipErrorCodes.OZCEM_CannotReadSystemFolderAttributes
                  andNotify:YES];
         return NO;
      }
      
      unsigned long long freeSpace =
         [[dict objectForKey: NSFileSystemFreeSize] unsignedLongLongValue];
      
      if (freeSpace < bufferSpaceRemaining)
      {
         [self setErrorCode:ZipErrorCodes.OZCEC_NotEnoughDiskSpace
               errorMessage:ZipErrorCodes.OZCEM_NotEnoughDiskSpace
                  andNotify:YES];
         return NO;
      }
      
      if (spaceNeeded >= (freeSpace - bufferSpaceRemaining))
      {
         [self setErrorCode:ZipErrorCodes.OZCEC_NotEnoughDiskSpace
               errorMessage:ZipErrorCodes.OZCEM_NotEnoughDiskSpace
                  andNotify:YES];
         return NO;
      }
   }
   
   return YES;
}

@end
