

#import <Foundation/Foundation.h>



/** The PDFObjectParser class converts a string representation of a PDF object into
a series of tokens representing object components of the represented object. The tokens may be 
keys and values in the case of a dictionary or elements of an array, for example. PDFObjectParser makes no assumptions
about, the type of the PDF object represented in str.
As an example:
 
     NSString* dictionaryString = @"<</Key1 (value1) /Key2 (value2) /Key3 [32 /aname]>>"
     PDFObjectParser* parser = [PDFObjectParser parserWithString:dictionaryString Parent:parentDocument];
     NSMutableArray* keysAndValues = [NSMutableArray array];
     
     for(id token in parser)
     {
        [keysAndValues addObject:token];
     }
     // From here we can extract all keys and corresponding values using the NSArray
 
 
 */

@interface PDFObjectParser : NSObject<NSFastEnumeration>
{
    
    NSString* str;
}

-(id)initWithString:(NSString*)strg;
+(PDFObjectParser*)parserWithString:(NSString*)strg;

@end
