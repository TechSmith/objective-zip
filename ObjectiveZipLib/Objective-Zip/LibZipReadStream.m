//
//  LibZipReadStream.m
//  Objective-Zip
//
//  Created by Wagner, Stephen on 10/10/17.
//
//

#import "LibZipReadStream.h"

#import "ZipErrorCodes.h"
#import "ZipException.h"

@interface LibZipReadStream()
{
   zip_stat_t _zipStats;
}

@property zip_file_t * internalFile;
@end

@implementation LibZipReadStream

-(id) initWithZipFile:(zip_t *) zipFile
     internalFileName:(NSString *) internalFileName
{
   if ( self = [super init] )
   {
      zip_int64_t index = zip_name_locate(zipFile, internalFileName.UTF8String, ZIP_FL_ENC_GUESS);
      if ( index < 0 )
      {
         return nil;
      }
      _internalFile = zip_fopen_index(zipFile, index, 0);

      zip_stat_index(zipFile, index, ZIP_FL_ENC_GUESS, &_zipStats);
      _name = internalFileName;
   }
   return self;
}

-(id) initWithZipFile:(zip_t *) zipFile
                index:(int) index
{
   if ( self = [super init] )
   {
      _internalFile = zip_fopen_index(zipFile, index, 0);
      
      zip_stat_index(zipFile, index, ZIP_FL_ENC_GUESS, &_zipStats);
      _name = [NSString stringWithUTF8String:_zipStats.name];
   }
   return self;
}

-(void) dealloc
{
   if ( _internalFile != nil )
   {
      zip_fclose(_internalFile);
   }
}

-(void) finishedReading
{
   
}

-(NSData *) readDataOfLength:(NSUInteger)length
{
   NSMutableData *data = [NSMutableData dataWithLength:length];
   zip_fseek(_internalFile, 0, 0);
   zip_int64_t bytes = zip_fread(_internalFile, [data mutableBytes], length);
   if (bytes < 0) {
      NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OUZEM_CannotReadFileInArchive,
                         _name];
      @throw [[ZipException alloc] initWithError:bytes reason:reason];
   }
   
   [data setLength:bytes];
   return data;
}

-(NSUInteger) length
{
   return _zipStats.comp_size;
}
@end
