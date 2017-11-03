//
//  UnzipWithProgress.h
//

#import <Foundation/Foundation.h>

#import "OZProgressDelegate.h"
#import "UnzipFileDelegate.h"
#import "ZipProgressBase.h"

#include <map>
#include <string>


//
// UnzipWithProgress
//
@interface UnzipWithProgress : ZipProgressBase
{
}

// zipFilePath - the path and file name of the zipfile
// requiredFiles  - an array of strings of filenames required to be in the archive (can be nil)
- (id) initWithZipFilePath:(NSURL *)zipFileURL
             requiredFiles:(NSArray *)requiredFiles
               andDelegate:()delegate;

- (NSArray *) zipFileList;

- (BOOL) unzipOneFile:(NSString *)fileNameInArchive toLocation:(NSURL *)unzipToFolder;

- (BOOL) canUnzipToLocation:(NSURL *)unzipToFolder;
- (void) unzipToURL:(NSURL *) destinationFolder
    createNewFolder:(BOOL) createNewFolder
     withCompletionBlock:(void(^)(NSURL * extractionFolder, NSError * error))completion;

- (void) unzipToURL:(NSURL *) destinationFolder
   withCompletionBlock:(void(^)(NSURL * extractionFolder, NSError * error))completion;


@property (weak) NSObject<UnzipFileDelegate> * unzipFileDelegate;

@end
