//
//  UnzipFileDelegate.h
//  Objective-Zip
//
//  Created by Wagner, Stephen on 9/25/17.
//
//

#pragma once

@protocol UnzipFileDelegate <NSObject>
@required
-(BOOL) includeFileWithName:(NSString *) filename forDestinationURL:(NSURL*) destinationURL error:(NSError * __autoreleasing * ) error;
-(NSString *) modifiedNameForFileName:(NSString *) filename;
@end
