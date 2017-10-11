//
//  LibZipReadStream.h
//  Objective-Zip
//
//  Created by Wagner, Stephen on 10/10/17.
//
//

#import <Foundation/Foundation.h>

#include <libzip/zip.h>

@interface LibZipReadStream : NSObject

-(id) initWithZipFile:(zip_t *) zipFile
     internalFileName:(NSString *) internalFileName;

-(id) initWithZipFile:(zip_t *) zipFile
                index:(int) index;

-(void) finishedReading;
-(NSData *) readDataOfLength:(NSUInteger)length;

@property NSString * name;
@property (nonatomic, readonly) NSUInteger length;

@end
