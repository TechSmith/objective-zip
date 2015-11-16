//
//  ZipErrorCodes.m
//

#import "ZipErrorCodes.h"


// kOZCEC_ - konstant Objective-Zip Common Error Code
// kOZCEM_ - konstant Objective-Zip Common Error Message

// kOZEC_ - konstant Objective-Zip Error Code
// kOZEM_ - konstant Objective-Zip Error Message

// kOUZEC_ - konstant Objective-(Un)Zip Error Code
// kOUZEM_ - konstant Objective-(Un)Zip Error Message


// common error codes
NSString * kOZCEM_ZipErrorDomain = NEVER_TRANSLATE(@"ZipErrorDomain");

NSString * kOZCEM_UserCancelledError = NSLocalizedString(@"User cancelled error", @"Message for user cancelled");

NSString * kOZCEM_IndeterminateError = NSLocalizedString(@"Unknown failure", @"Message for indeterminate error");

NSString * kOZCEM_NotEnoughDiskSpace = NSLocalizedString(@"Not enough disk space at requested location", @"Message for not enough disk space");

NSString * kOZCEM_CannotReadSystemFolderAttributes = NSLocalizedString(@"Cannot read folder attributes to verify disk space", @"Message for cannot read system folder attributes");



// zip error codes

NSString * kOZEM_WriteStreamCreationError = NSLocalizedString(@"Failed to create write stream for zip file", @"Message for write stream creation error");

NSString * kOZEM_ZeroLengthFileNames = NSLocalizedString(@"Cannot create a zip file with file names of zero length", @"Message for zero length filenames");

NSString * kOZEM_DuplicateFileNames = NSLocalizedString(@"Cannot create a zip file with duplicate file names", @"Message for duplicate filenames");

NSString * kOZEM_ZipLocationIsFile = NSLocalizedString(@"Cannot create a zip file at requested location (is a file, not a folder)", @"Message for zip location is file");

NSString * kOZEM_ZipLocationDoesNotExist = NSLocalizedString(@"Requested location for zip file does not exist", @"Message for zip location does not exist");

NSString * kOZEM_ZipLocationReadOnly = NSLocalizedString(@"Requested location for zip file is read only", @"Message for zip location read only");

NSString * kOZEM_ReadDataFailure = NSLocalizedString(@"Failed to read data to add to zip file", @"Message for read data failure");

NSString * kOZEM_fileCouldNotBeOpenedForReading = NSLocalizedString(@"A file to be added to the zip file could not be opened for reading", @"Message for file could not be opened for reading");



// unzip error codes

NSString * kOUZEM_PathDoesNotExist = NSLocalizedString(@"Extraction path does not exist", @"Message for path does not exist");

NSString * kOUZEM_CannotCreateFolder = NSLocalizedString(@"Could not create folder to extract files into", @"Message for when cannot create folder");

NSString * kOUZEM_CannotCreateExtractionQueue = NSLocalizedString(@"Failed to get a system queue to extract data from zip file", @"Error from when cannot create extraction queue");

NSString * kOUZEM_CannotFindInfoForFileInArchive = NSLocalizedString(@"File does not exist in archive", @"Message for when cannot find info file in archive");

NSString * kOUZEM_fileAlreadyExists = NSLocalizedString(@"During file extraction the file to be written already exists", @"Message for when file already exists");

NSString * kOUZEM_fileCouldNotBeOpenedForWriting = NSLocalizedString(@"During file extraction the file to be written could not be opened for writing", @"Message for when file could not be opened for writing");


