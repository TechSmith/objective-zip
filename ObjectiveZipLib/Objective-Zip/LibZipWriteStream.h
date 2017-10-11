//
//  LibZipWriteStream.h
//  Objective-Zip
//
//  Created by Wagner, Stephen on 10/11/17.
//
//

#import <Foundation/Foundation.h>

#include <libzip/zip.h>

@interface LibZipWriteStream : NSObject

-(id) initWithZipFile:(zip_t *) zipFile
     internalFileName:(NSString *) internalFileName
     compressionLevel:(int)compressionLevel;


-(void) finishedWriting;

- (void) writeData:(NSData *)data;

@property NSString * name;

@end
