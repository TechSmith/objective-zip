//
//  ZipFile.m
//  Objective-Zip v. 0.7.2
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright 2009-10 Flying Dolphin Studio. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions 
//  are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of Gianluca Bertani nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "ZipFile.h"

#import "FileInZipInfo.h"
#import "LibZipReadStream.h"
#import "ZipErrorCodes.h"
#import "ZipException.h"
#import "ZipReadStream.h"
#import "ZipWriteStream.h"

#include <libzip/zip.h>

#define FILE_IN_ZIP_MAX_NAME_LENGTH (4096)


@implementation ZipFile


- (id) initWithFileName:(NSString *)fileName mode:(ZipFileMode)mode {
   int libzipError;
	if ((self= [super init])) {
		_fileName= fileName;
		_mode= mode;
		
		switch (mode) {
			case ZipFileModeUnzip:
				_libZipFile= zip_open([_fileName cStringUsingEncoding:NSUTF8StringEncoding], ZIP_RDONLY, &libzipError);
				if (_libZipFile == NULL) {
					NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotOpenZipFile,
                                  _fileName];
					@throw [[ZipException alloc] initWithReason:reason];
				}
				break;
				
			case ZipFileModeCreate:
				_zipFile= zipOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_CREATE);
				if (_zipFile == NULL) {
					NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotCreateZipFile,
                                  _fileName];
					@throw [[ZipException alloc] initWithReason:reason];
				}
				break;
				
			case ZipFileModeAppend:
				_zipFile= zipOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_ADDINZIP);
				if (_zipFile == NULL) {
					NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotOpenZipFile,
                                  _fileName];
					@throw [[ZipException alloc] initWithReason:reason];
				}
				break;
				
			default: {
				NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_UnknownZipFileMode,
                               _mode];
				@throw [[ZipException alloc] initWithReason:reason];
			}
		}
	}
	
	return self;
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip compressionLevel:(ZipCompressionLevel)compressionLevel {
	if (_mode == ZipFileModeUnzip) {
		NSString *reason= ZipErrorCodes.OUZEM_OperationNotPermitted;
		@throw [[ZipException alloc] initWithReason:reason];
	}
	
	NSDate *now= [NSDate date];
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute |
                                                 NSCalendarUnitHour | NSCalendarUnitDay |
                                                 NSCalendarUnitMonth | NSCalendarUnitYear)
                                       fromDate:now];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= (uInt)[date second];
	zi.tmz_date.tm_min= (uInt)[date minute];
	zi.tmz_date.tm_hour= (uInt)[date hour];
	zi.tmz_date.tm_mday= (uInt)[date day];
	zi.tmz_date.tm_mon= (uInt)[date month] -1;
	zi.tmz_date.tm_year= (uInt)[date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
   int err= zipOpenNewFileInZip3_64(_zipFile,
                                    [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
                                    &zi,
                                    NULL, 0, NULL, 0, NULL,
                                    (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
                                    compressionLevel, 0,
                                    -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                    NULL, 0, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotOpenFileInArchive,
                         fileNameInZip];
		@throw [[ZipException alloc] initWithError:err reason:reason];
	}
	
	return [[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(ZipCompressionLevel)compressionLevel {
	if (_mode == ZipFileModeUnzip) {
      NSString *reason= ZipErrorCodes.OUZEM_OperationNotPermitted;
		@throw [[ZipException alloc] initWithReason:reason];
	}
	
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:fileDate];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= (uInt)[date second];
	zi.tmz_date.tm_min= (uInt)[date minute];
	zi.tmz_date.tm_hour= (uInt)[date hour];
	zi.tmz_date.tm_mday= (uInt)[date day];
	zi.tmz_date.tm_mon= (uInt)[date month] -1;
	zi.tmz_date.tm_year= (uInt)[date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
   int err= zipOpenNewFileInZip3_64(_zipFile,
                                    [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
                                    &zi,
                                    NULL, 0, NULL, 0, NULL,
                                    (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
                                    compressionLevel, 0,
                                    -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                    NULL, 0, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotOpenFileInArchive,
                         fileNameInZip];
		@throw [[ZipException alloc] initWithError:err reason:reason];
	}
	
	return [[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(ZipCompressionLevel)compressionLevel password:(NSString *)password crc32:(NSUInteger)crc32 {
	if (_mode == ZipFileModeUnzip) {
		NSString *reason= ZipErrorCodes.OUZEM_OperationNotPermitted;
		@throw [[ZipException alloc] initWithReason:reason];
	}
	
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:fileDate];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= (uInt)[date second];
	zi.tmz_date.tm_min= (uInt)[date minute];
	zi.tmz_date.tm_hour= (uInt)[date hour];
	zi.tmz_date.tm_mday= (uInt)[date day];
	zi.tmz_date.tm_mon= (uInt)[date month] -1;
	zi.tmz_date.tm_year= (uInt)[date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
   int err= zipOpenNewFileInZip3_64(_zipFile,
                                    [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
                                    &zi,
                                    NULL, 0, NULL, 0, NULL,
                                    (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
                                    compressionLevel, 0,
                                    -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                    [password cStringUsingEncoding:NSUTF8StringEncoding], crc32, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotOpenFileInArchive, fileNameInZip];
		@throw [[ZipException alloc] initWithError:err reason:reason];
	}
	
	return [[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}

- (NSUInteger) numFilesInZip {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= ZipErrorCodes.OZEM_OperationNotPermitted;
		@throw [[ZipException alloc] initWithReason:reason];
	}
	
   return zip_get_num_files(_libZipFile);
}

- (NSArray *) listFileInZipInfos {
	int num= (uInt)[self numFilesInZip];
	if (num < 1)
      return @[];
	
	NSMutableArray *files= [[NSMutableArray alloc] initWithCapacity:num];

   for ( int index = 0; index < num; ++index )
   {
      zip_stat_t stats;
      zip_stat_index(_libZipFile, index, 0, &stats);
      
      ZipCompressionLevel level= ZipCompressionLevelNone;
      if (stats.comp_method != 0) {
         switch ((stats.comp_method & 0x6) / 2) {
            case 0:
               level= ZipCompressionLevelDefault;
               break;
               
            case 1:
               level= ZipCompressionLevelBest;
               break;
               
            default:
               level= ZipCompressionLevelFastest;
               break;
         }
      }

      BOOL crypted= NO;

      FileInZipInfo *info= [[FileInZipInfo alloc] initWithName:[NSString stringWithUTF8String:stats.name]
                                                        length:stats.size
                                                         level:level
                                                       crypted:crypted
                                                          size:stats.comp_size
                                                          date:[NSDate date]
                                                         crc32:stats.crc];

      [files addObject:info];

   }

	return files;
}

- (BOOL) locateFileInZip:(NSString *)fileNameInZip {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= ZipErrorCodes.OZEM_OperationNotPermitted;
		@throw [[ZipException alloc] initWithReason:reason];
	}
	
   zip_error_clear(_libZipFile);
	zip_int64_t index = zip_name_locate(_libZipFile, [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding], 0);
	if (index == -1 )
		return NO;

   zip_error_t * error = zip_get_error(_libZipFile);
	if (  error != nil )
   {
		NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OUZEM_CannotGoToNextFileInArchive,
                         _fileName];
		@throw [[ZipException alloc] initWithError:zip_error_code_zip(error) reason:reason];
	}
	
	return YES;
}

//- (FileInZipInfo *) getCurrentFileInZipInfo {
//	if (_mode != ZipFileModeUnzip) {
//		NSString *reason= ZipErrorCodes.OZEM_OperationNotPermitted;
//		@throw [[ZipException alloc] initWithReason:reason];
//	}
//
//	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
//	unz_file_info file_info;
//	
//	int err= unzGetCurrentFileInfo(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
//	if (err != UNZ_OK) {
//		NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OUZEM_CannotGetCurrentFileInfoInArchive,
//                         _fileName];
//		@throw [[ZipException alloc] initWithError:err reason:reason];
//	}
//	
//	NSString *name= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
//	
//	ZipCompressionLevel level= ZipCompressionLevelNone;
//	if (file_info.compression_method != 0) {
//		switch ((file_info.flag & 0x6) / 2) {
//			case 0:
//				level= ZipCompressionLevelDefault;
//				break;
//				
//			case 1:
//				level= ZipCompressionLevelBest;
//				break;
//				
//			default:
//				level= ZipCompressionLevelFastest;
//				break;
//		}
//	}
//	
//	BOOL crypted= ((file_info.flag & 1) != 0);
//	
//	NSDateComponents *components= [[NSDateComponents alloc] init];
//	[components setDay:file_info.tmu_date.tm_mday];
//	[components setMonth:file_info.tmu_date.tm_mon +1];
//	[components setYear:file_info.tmu_date.tm_year];
//	[components setHour:file_info.tmu_date.tm_hour];
//	[components setMinute:file_info.tmu_date.tm_min];
//	[components setSecond:file_info.tmu_date.tm_sec];
//	NSCalendar *calendar= [NSCalendar currentCalendar];
//	NSDate *date= [calendar dateFromComponents:components];
//	
//	return [[FileInZipInfo alloc] initWithName:name length:file_info.uncompressed_size
//                                        level:level
//                                      crypted:crypted size:file_info.compressed_size
//                                         date:date
//                                        crc32:file_info.crc];
//}

- (void) close {
	switch (_mode) {
		case ZipFileModeUnzip: {

         int err = zip_close(_libZipFile);
			if (err != UNZ_OK)
         {
				NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotCloseZipFile,
                               _fileName];
				@throw [[ZipException alloc] initWithError:err reason:reason];
			}
			break;
		}
			
		case ZipFileModeCreate: {
			int err= zipClose(_zipFile, NULL);
			if (err != ZIP_OK) {
				NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotCloseZipFile,
                               _fileName];
				@throw [[ZipException alloc] initWithError:err reason:reason];
			}
			break;
		}
			
		case ZipFileModeAppend: {
			int err= zipClose(_zipFile, NULL);
			if (err != ZIP_OK) {
            NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_CannotCloseZipFile,
                               _fileName];
				@throw [[ZipException alloc] initWithError:err reason:reason];
			}
			break;
		}

		default: {
			NSString *reason= [NSString stringWithFormat:ZipErrorCodes.OZCEM_UnknownZipFileMode,
                            _mode];
			@throw [[ZipException alloc] initWithReason:reason];
		}
	}
}

- (LibZipReadStream *) openReadStreamForName:(NSString *) filename
{
   return [[LibZipReadStream alloc] initWithZipFile:_libZipFile
                                            internalFileName:filename];
}

- (LibZipReadStream *) openReadStreamForIndex:(int) index;
{
   return [[LibZipReadStream alloc] initWithZipFile:_libZipFile
                                   index:index];
}
@end
