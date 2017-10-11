//
//  LibZipWriteStream.m
//  Objective-Zip
//
//  Created by Wagner, Stephen on 10/10/17.
//
//

#import "LibZipWriteStream.h"

#import "ZipErrorCodes.h"
#import "ZipException.h"

@interface LibZipWriteStream()
{
   zip_stat_t _zipStats;
}

@property zip_file_t * internalFile;
@end

@implementation LibZipWriteStream

-(id) initWithZipFile:(zip_t *) zipFile
     internalFileName:(NSString *) internalFileName
compressionLevel:(int)compressionLevel
{
   if ( self = [super init] )
   {
      _internalFile = zip_fopen(zipFile, [internalFileName UTF8String], 0);

      _name = internalFileName;
   }
   return self;
}

-(void) finishedWriting
{
   
}

- (void) writeData:(NSData *)data
{
}

@end
