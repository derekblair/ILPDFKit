

#import "PDFStream.h"
#import "PDFDictionary.h"

@implementation PDFStream

@synthesize data;
@synthesize dictionary;
@synthesize dataFormat;

-(void)dealloc
{
    [data release];
    [dictionary release];
    [super dealloc];
}

-(id)initWithStream:(CGPDFStreamRef)pstrm
{
    self = [super init];
    if(self != nil)
    {
        strm = pstrm;
    }
    
    return self;
}

#pragma mark - Getter

-(PDFDictionary*)dictionary
{
    if(dictionary == nil)
    {
        CGPDFDictionaryRef dict = CGPDFStreamGetDictionary(strm);
        if(dict)
        {
            dictionary = [[PDFDictionary alloc] initWithDictionary:dict];
        }
    }
    
    return dictionary;
}


-(CGPDFDataFormat)dataFormat
{
    if(data == nil)
    {
        NSData* temp = self.data;
        temp = nil;
    }
    
    return dataFormat;
}

-(NSData*)data
{
    if(data == nil)
    {
        CFDataRef dat = CGPDFStreamCopyData(strm, &dataFormat);
        data = [((NSData*)dat) retain];
        CFRelease(dat);
    }
    
    return data;
}

@end
