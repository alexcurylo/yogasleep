//
//  TWXNSString.m
//
//  Copyright 2010 Trollwerks Inc. All rights reserved.
//

#import "TWXNSString.h"

@implementation NSString (TWXNSString)

+ (id)stringWithUUID
{
   CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
   CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
   NSString *uuidString = [NSString stringWithString:(NSString*)strRef];
   CFRelease(strRef);
   CFRelease(uuidRef);
   return uuidString;
}

- (BOOL)contains:(NSString *)substring
{
   NSRange range = [self rangeOfString:substring];
   
   return NSNotFound != range.location;
}

// from GTMNSString+URLArguments.m
- (NSString *)stringByEscapingForURLArgument
{
   // Encode all the reserved characters, per RFC 3986
   // (<http://www.ietf.org/rfc/rfc3986.txt>)
   CFStringRef escaped =  CFURLCreateStringByAddingPercentEscapes
      (kCFAllocatorDefault,
      (CFStringRef)self,
      NULL,
      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
      kCFStringEncodingUTF8
   );
   return [(NSString *)escaped autorelease];
}

// suitable for [NSArray sortedArrayUsingSelector:]
- (NSComparisonResult)compareByValue:(NSString *)otherString
{	
   NSNumber *myNID = [NSNumber numberWithFloat:[self floatValue]];
   NSNumber *otherNID = [NSNumber numberWithFloat:[otherString floatValue]];
   return [myNID compare:otherNID];
}

- (NSString *) stringWithSentenceCapitalization
{
   NSString *firstCharacterInString = [[self substringToIndex:1] capitalizedString];
   NSString *sentenceString = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString: firstCharacterInString];
   
   return sentenceString;
}

#define ellipsis @"…"

// http://iphonedevelopertips.com/cocoa/truncate-an-nsstring-and-append-an-ellipsis-respecting-the-font-size.html
- (NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont *)font
{
   // Create copy that will be the returned result
   NSMutableString *truncatedString = [[self mutableCopy] autorelease];
   
   // Make sure string is longer than requested width
   if ([self sizeWithFont:font].width > width)
   {
      // Accommodate for ellipsis we'll tack on the end
      width -= [ellipsis sizeWithFont:font].width;
      
      // Get range for last character in string
      NSRange range = {truncatedString.length - 1, 1};
      
      // Loop, deleting characters until string fits within width
      while ([truncatedString sizeWithFont:font].width > width) 
      {
         // Delete character at end
         [truncatedString deleteCharactersInRange:range];
         
         // Move back another character
         range.location--;
      }
      
      // Append ellipsis
      [truncatedString replaceCharactersInRange:range withString:ellipsis];
   }
   
   return truncatedString;
}

   /*
+ (id)stringWithUUID
{
   CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
   CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
   NSString *uuidString = [NSString stringWithString:(NSString*)strRef];
   CFRelease(strRef);
   CFRelease(uuidRef);
   return uuidString;
}

+ (id)stringWithMachineSerialNumber
{
   NSString* result = nil;
   
#if TARGET_OS_IPHONE
   result = [[UIDevice currentDevice] uniqueIdentifier];
#else
   CFStringRef serialNumber = NULL;
   
   io_service_t platformExpert = IOServiceGetMatchingService(
      kIOMasterPortDefault,
      IOServiceMatching("IOPlatformExpertDevice")
   );
   
   if (platformExpert)
   {
      CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(
         platformExpert,
         CFSTR(kIOPlatformSerialNumberKey),
         kCFAllocatorDefault,
         0
      );
      serialNumber = (CFStringRef)serialNumberAsCFString;
      IOObjectRelease(platformExpert);
   }
   
   if (serialNumber)
      result = [(NSString*)serialNumber autorelease];
   else
      result = @"unknown";
#endif TARGET_OS_IPHONE
   
   return result;
}

- (NSUInteger)lineCount
{
   NSUInteger count = 0;
   NSUInteger location = 0;
   
   while (location < [self length])
   {
      // get next line start and set current location to it
      [self getLineStart:nil end:&location contentsEnd:nil forRange:NSMakeRange(location,1)];
      count += 1;
   }
   
   return count;
}

- (void)revealInFinder
{
   NSString *scriptText = @"set posixpath to \"%@\"\n"
                           "set finderpath to (get POSIX file posixpath as string)\n"
                           "tell application \"Finder\"\n"
                           "   activate\n"
                           "   reveal alias finderpath\n"
                           "end tell";
   NSString *script = [NSString stringWithFormat:scriptText, self];
   [script executeAppleScript];
}

- (void)openInFinder
{
   NSString *scriptText = @"set posixpath to \"%@\"\n"
   "set finderpath to (get POSIX file posixpath as string)\n"
   "tell application \"Finder\"\n"
   "   activate\n"
   "   open alias finderpath\n"
   "end tell";
   NSString *script = [NSString stringWithFormat:scriptText, self];
   [script executeAppleScript];
}

- (NSAppleEventDescriptor *)executeAppleScript
{
   NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithSource:self];
   NSDictionary* errorDict = nil;
   NSAppleEventDescriptor* returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
   [scriptObject release];
   
   //twlogif(nil != returnDescriptor, "AppleScript returnDescriptor: %@", returnDescriptor); 
   twlogif(nil != errorDict, "AppleScript FAIL: %@", errorDict); 

   return returnDescriptor;
}
 */

@end

/*
 
 @implementation NSAttributedString (TWXNSAttributedString)
 
 + (id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
 {
 NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
 NSRange range = NSMakeRange(0, [attrString length]);
 
 [attrString beginEditing];
 [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
 
 // make the text appear in blue
 [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
 
 // next make the text appear with an underline
 [attrString addAttribute:
 NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
 
 [attrString endEditing];
 
 return [attrString autorelease];
 }

*/
