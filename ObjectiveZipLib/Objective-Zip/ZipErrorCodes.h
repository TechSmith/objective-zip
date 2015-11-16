//
//  ZipErrorCodes.h
//

#import <Foundation/Foundation.h>

#define NEVER_TRANSLATE(x) x

// kOZCEC_ - konstant Objective-Zip Common Error Code
// kOZCEM_ - konstant Objective-Zip Common Error Message

// kOZEC_ - konstant Objective-Zip Error Code
// kOZEM_ - konstant Objective-Zip Error Message

// kOUZEC_ - konstant Objective-(Un)Zip Error Code
// kOUZEM_ - konstant Objective-(Un)Zip Error Message


// common error codes
extern NSString * kOZCEM_ZipErrorDomain;

static NSInteger  kOZCEC_UserCancelledError = -128;
extern NSString * kOZCEM_UserCancelledError;

static NSInteger  kOZCEC_IndeterminateError = 90;
extern NSString * kOZCEM_IndeterminateError;

static NSInteger  kOZCEC_NotEnoughDiskSpace = 98;
extern NSString * kOZCEM_NotEnoughDiskSpace;

static NSInteger  kOZCEC_CannotReadSystemFolderAttributes = 99;
extern NSString * kOZCEM_CannotReadSystemFolderAttributes;



// zip error codes

static NSInteger  kOZEC_WriteStreamCreationError = 100;
extern NSString * kOZEM_WriteStreamCreationError;

static NSInteger  kOZEC_ZeroLengthFileNames = 101;
extern NSString * kOZEM_ZeroLengthFileNames;

static NSInteger  kOZEC_DuplicateFileNames = 102;
extern NSString * kOZEM_DuplicateFileNames;

static NSInteger  kOZEC_ZipLocationIsFile = 103;
extern NSString * kOZEM_ZipLocationIsFile;

static NSInteger  kOZEC_ZipLocationDoesNotExist = 104;
extern NSString * kOZEM_ZipLocationDoesNotExist;

static NSInteger  kOZEC_ZipLocationReadOnly = 105;
extern NSString * kOZEM_ZipLocationReadOnly;

static NSInteger  kOZEC_ReadDataFailure = 106;
extern NSString * kOZEM_ReadDataFailure;

static NSInteger  kOZEC_fileCouldNotBeOpenedForReading = 107;
extern NSString * kOZEM_fileCouldNotBeOpenedForReading;



// unzip error codes

static NSInteger  kOUZEC_PathDoesNotExist = 120;
extern NSString * kOUZEM_PathDoesNotExist;

static NSInteger  kOUZEC_CannotCreateFolder = 121;
extern NSString * kOUZEM_CannotCreateFolder;

static NSInteger  kOUZEC_CannotCreateExtractionQueue = 122;
extern NSString * kOUZEM_CannotCreateExtractionQueue;

static NSInteger  kOUZEC_CannotFindInfoForFileInArchive = 123;
extern NSString * kOUZEM_CannotFindInfoForFileInArchive;

static NSInteger  kOUZEC_fileAlreadyExists = 124;
extern NSString * kOUZEM_fileAlreadyExists;

static NSInteger  kOUZEC_fileCouldNotBeOpenedForWriting = 125;
extern NSString * kOUZEM_fileCouldNotBeOpenedForWriting;


