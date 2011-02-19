//
//  TWURLFetcher.m
//
//  Copyright 2010 Trollwerks Inc. All rights reserved.
//

#import "TWURLFetcher.h"

static NSMutableArray *sActiveFetchers = nil;

@implementation TWURLFetcher

@synthesize requestString;
@synthesize request;
@synthesize connection;
@synthesize connectionData;
@synthesize completionTarget;
@synthesize completionSelector;
@synthesize contextInfo;
@synthesize succeeded;
@synthesize retries;

#pragma mark -
#pragma mark Utilities

+ (TWURLFetcher *)urlFetcher:(NSString *)urlLink target:(id)target selector:(SEL)selector
{
   if (!urlLink || !urlLink.length)
      return nil;
   
	TWURLFetcher *fetcher = [[TWURLFetcher alloc]
      initWithRequestString:urlLink
      target:target
      selector:selector
   ];
   twcheck(fetcher);
   
   if (fetcher)
   {
      if (!sActiveFetchers)
         sActiveFetchers = [[NSMutableArray alloc] init];
      
      [sActiveFetchers addObject:fetcher];
   }
   
   return [fetcher autorelease];
}

+ (TWURLFetcher *)urlFetcherRetry:(TWURLFetcher *)failure
{
   if (!failure)
      return nil;
   
	TWURLFetcher *fetcher = [[TWURLFetcher alloc]
      initWithRequestString:failure.requestString
      target:failure.completionTarget
      selector:failure.completionSelector
   ];
   twcheck(fetcher);
   
   if (fetcher)
   {
      fetcher.contextInfo = failure.contextInfo;
      fetcher.retries = failure.retries + 1;
      
      if (!sActiveFetchers)
         sActiveFetchers = [[NSMutableArray alloc] init];
      
      [sActiveFetchers addObject:fetcher];
   }
   
   return [fetcher autorelease];
}

#pragma mark -
#pragma mark Life cycle

 - (id)initWithRequestString:(NSString *)urlLink target:(id)target selector:(SEL)selector
{
   if ( (self = [super init]) )
   {
      self.completionTarget = target;
      twcheck(self.completionTarget);
      self.completionSelector = selector;
      twcheck(self.completionSelector);

      self.requestString = urlLink;
      twcheck(self.requestString);
      //self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlLink]];
      NSURL* theURL = [NSURL URLWithString:urlLink];
      self.request = [NSMutableURLRequest requestWithURL:theURL
         cachePolicy:NSURLRequestReloadIgnoringCacheData
         timeoutInterval:180
      ];
      twcheck(self.request);
      self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
      twcheck(self.connection);
   }
   return self;
}

- (void)dealloc
{
   //twlog("TWURLFetcher dealloc");
   self.completionTarget = nil;
   self.completionSelector = nil;
	twrelease(requestString);
	twrelease(request);
	twrelease(connection);
	twrelease(connectionData);
	twrelease(contextInfo);
  
   [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (BOOL)retry:(NSInteger)maxRetries
{
   if (maxRetries < retries)
      return NO;
   
   /*
   [self.connection cancel];
   self.connection = nil;
   self.connectionData = nil;
   self.succeeded = NO;
   
   twcheck(self.request);
   self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
   twcheck(self.connection);
   
   retries++;
   twlog("retrying, attempt %i...", retries);
    */
   TWURLFetcher *poseFetcher = [TWURLFetcher urlFetcherRetry:self];
   twcheck(poseFetcher); (void)poseFetcher;
   
   return YES;
}

- (void)cancel
{
   twlog("TWURLFetcher cancelling!");
   self.completionTarget = nil;
   self.completionSelector = nil;
   [self.connection cancel];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connect didReceiveResponse:(NSURLResponse *)response
{
   if ([response respondsToSelector:@selector(statusCode)])
   {
      expectedContentLength = [((NSHTTPURLResponse *)response) expectedContentLength];
      if (0 > expectedContentLength)
         expectedContentLength = 0;
      // lacking this isn't fatal, but it should be there we'd hope
      twlogif(!expectedContentLength, "TWURLFetcher WARNING: no expectedContentLength for %@", self.requestString);
      statusCode = [((NSHTTPURLResponse *)response) statusCode];
      if ( (400 <= statusCode) && (599 >= statusCode) )
      {
         twlog("TWURLFetcher didReceiveResponse cancelling...");
         
         [connect cancel];  // stop connecting; no more delegate messages

         twlog("TWURLFetcher response FAIL (%i) for query: %@", statusCode, self.requestString);

         succeeded = NO;
         
         twlog("TWURLFetcher didReceiveResponse calling complete...");

         [self complete];
      }
      else if (200 != statusCode)
      {
         twlog("TWURLFetcher suspicious status response code (%i) for query: %@", statusCode, self.requestString);
      }
   }
}

- (void)connection:(NSURLConnection *)connect didReceiveData:(NSData *)data
{
   (void)connect;
   
   if (nil == self.connectionData)
   {
      self.connectionData = [NSMutableData data];
      [self.connectionData setLength:0];
   }
   [self.connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connect
{
   (void)connect;

   /*
   NSString *resultString = [[NSString alloc] initWithData:self.connectionData encoding:NSUTF8StringEncoding];
   NSData *jsonData = [resultString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
   
	NSError *error = nil;
   self.resultDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
   twlogif(nil != error, "TWURLFetcher deserialize FAIL for query: %@\ndeserializeAsDictionary error: %@", self.requestString, error);
   */
   
   if (!self.connectionData)
   {
      twlog("TWURLFetcher connectionData nil in connectionDidFinishLoading?? Really?");
   }
   else if (expectedContentLength && (self.connectionData.length != expectedContentLength))
   {
      twlog("TWURLFetcher connectionDidFinishLoading warning: actual size (%u) != expected size (%lli)!!", self.connectionData.length, expectedContentLength);
   }
   succeeded = YES;
   
   [self complete];
}

- (void)connection:(NSURLConnection *)connect didFailWithError:(NSError *)error
{
   (void)connect;
   (void)error;
   
   twlog("TWURLFetcher connection FAIL (%@) for query: %@", error.localizedDescription, self.requestString);
   
   succeeded = NO;
   
   [self complete];
}

- (void)complete
{
   //NSInteger retried = retries;
   if (self.completionTarget)
   {
      [self.completionTarget performSelector:self.completionSelector withObject:self];
      // in case complete gets called twice, as it appears may happen from didReceiveResponse and connectionDidFinishLoading?
      self.completionTarget = nil;
      self.completionSelector = nil;
   }
   else
   {
      twlog("TWURLFetcher complete called when completed!!");
   }
   
   //if (retried == retries)
   {
   twlogif(10 < sActiveFetchers.count, "TWURLFetchers (count:%i) not getting completed??", sActiveFetchers.count);
   [sActiveFetchers removeObjectIdenticalTo:self];
   }
}

@end
