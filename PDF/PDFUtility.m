
#import "PDFUtility.h"
#import "PDFObject.h"
#import "PDFDocument.h"


@implementation PDFUtility


#pragma mark - Memory Lifecycle
static PDFUtility* _sharedPDFUtility = nil;

-(void)dealloc
{
 
    _sharedPDFUtility= nil;
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if(self!=nil)
    {
    }
    
    return self;
}

+(PDFUtility*)sharedPDFUtility
{
	@synchronized([PDFUtility class])
	{
		if(!_sharedPDFUtility)
			[[self alloc] init];
        
		return _sharedPDFUtility;
	}
	return nil;
}

+(id)alloc
{
	@synchronized([PDFUtility class])
	{
		NSAssert(_sharedPDFUtility == nil, @"Attempted to allocate a second instance of a PDFUtility");
		_sharedPDFUtility = [super alloc];
		return _sharedPDFUtility;
	}
	return nil;
}


+(CGContextRef)outputPDFContextCreate:(const CGRect *)inMediaBox Path:(CFStringRef)path
{
    CGContextRef outContext = NULL;
    CFURLRef url;
    url = CFURLCreateWithFileSystemPath(NULL,path,kCFURLPOSIXPathStyle,false);
    if (url != NULL)
    {
        outContext = CGPDFContextCreateWithURL(url,inMediaBox,NULL);
        CFRelease(url);
        
    }
    return outContext;
}

+(CGPDFDocumentRef)createPDFDocumentRefFromData:(NSData*)data
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(dataProvider);
    CGDataProviderRelease(dataProvider);
    return pdf;
}

+(CGPDFDocumentRef)createPDFDocumentRefFromResource:(NSString*)name
{
    NSString *pathToPdfDoc = [[NSBundle mainBundle] pathForResource:name ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:pathToPdfDoc];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    return pdf;
}

+(CGPDFDocumentRef)createPDFDocumentRefFromPath:(NSString*)pathToPdfDoc
{
    NSURL *url = [NSURL fileURLWithPath:pathToPdfDoc];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    return pdf;
}


+(NSString*)pdfEncodedString:(NSString*)stringToEncode
{
    if([stringToEncode rangeOfString:@"%"].location!=NSNotFound)return NULL;
    CFStringRef encodedStr= CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)stringToEncode,NULL,(CFStringRef)@"!*()@$/?#[] \t\n\r",kCFStringEncodingUTF8);
    NSString* ret = [[[NSString alloc] initWithString:(NSString*)encodedStr] autorelease];
    CFRelease(encodedStr);
    return [ret stringByReplacingOccurrencesOfString:@"%" withString:@"#"];
}


+(NSString*)pdfObjectRepresentationFrom:(id)obj Type:(CGPDFObjectType)type
{
    NSString* objRepresentation = nil;
    
    if([obj isKindOfClass:[NSString class]])
    {
        if(type == kCGPDFObjectTypeName)
        {
            objRepresentation = [NSString stringWithFormat:@"/%@",[PDFUtility pdfEncodedString:obj]];
        }
        else
        {
            objRepresentation = [NSString stringWithFormat:@"(%@)",obj];
        }
    }
    else if([obj isKindOfClass:[NSData class]])
    {
        NSString* temp = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
            objRepresentation = [NSString stringWithFormat:@"<%@>",temp];
        [temp release];
    }
    else if([obj isKindOfClass:[NSNumber class]])
    {
        if(type == kCGPDFObjectTypeBoolean)
        {
            if([obj boolValue])objRepresentation = @"true";
            else objRepresentation = @"false";
        }
        else objRepresentation = [NSString stringWithFormat:@"%@",obj];
    }
    else if([obj isKindOfClass:[PDFObject class]])
    {
        objRepresentation = [obj pdfFileRepresentation];
    }
    else
    {
        objRepresentation = @"null";
    }
    
    return objRepresentation;

}


+(BOOL)isWhiteSpace:(char)c
{
    return c == 0 || c == 9 || c == 10 || c == 12 || c == 13 || c == 32;
}


+(NSCharacterSet*)whiteSpaceCharacterSet
{
    NSMutableCharacterSet* ret = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(0, 1)];
    [ret addCharactersInRange:NSMakeRange(9, 2)];
    [ret addCharactersInRange:NSMakeRange(12, 2)];
    [ret addCharactersInRange:NSMakeRange(32, 1)];
    
    return ret;
}


+(BOOL)isOpeningDelimeter:(char)c
{
    return  c == '(' ||  c == '<' ||  c == '[';
}

+(BOOL)isClosingDelimeter:(char)c
{
    return  c == ')' ||  c == '>' ||  c == ']';
}


+(BOOL)isDelimeter:(char)c
{
    return c == '(' || c == ')' || c == '<' || c == '>' || c == '[' || c == ']' || c == '{' || c == '}' || c == '/' ||  c == '%';
}




+(NSString*)stringReplacingWhiteSpaceWithSingleSpace:(NSString*)str
{

    NSString* ret = str;
    NSUInteger c;
    
    while((c=[ret rangeOfString:@"%"].location)!= NSNotFound)
    {
        
        NSUInteger end = c;
        while([ret characterAtIndex:end]!=13 && [ret characterAtIndex:end]!=10)end++;
        NSString* find = [ret substringWithRange:NSMakeRange(c, end-c)];
        ret = [ret stringByReplacingOccurrencesOfString:find withString:@" "];
    }
    
    ret = [str stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@" "];
    ret = [ret stringByReplacingCharactersInRange:NSMakeRange(9, 2) withString:@" "];
    ret = [ret stringByReplacingCharactersInRange:NSMakeRange(12, 2) withString:@" "];
    
    

    while ([ret rangeOfString:@"  "].location != NSNotFound)
    {
        ret = [ret stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    return ret;
}


+(NSString*)urlEncodeString:(NSString*)str
{
    if(str == nil)return nil;
    if([str isKindOfClass:[NSString class]]== NO)return str;
    if([str length]==0)return str;
    
    CFStringRef encodedStr= CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)str,NULL,(CFStringRef)@"!*()@,$^~/?%#[]'\" \t\n\r",kCFStringEncodingUTF8);
    
    NSString* ret = [[[NSString alloc] initWithString:(NSString*)encodedStr] autorelease];
    
    CFRelease(encodedStr);
    
    
    return ret;
}

+(NSString*)decodeURLEncodedString:(NSString*)str
{
    if(str == nil)return nil;
    if([str isKindOfClass:[NSString class]]== NO)return str;
    if([str length]==0)return str;
    
    CFStringRef decodedStr= CFURLCreateStringByReplacingPercentEscapes(NULL,(CFStringRef)str,CFSTR(""));
    
    NSString* ret = [[[NSString alloc] initWithString:(NSString*)decodedStr] autorelease];
    
    CFRelease(decodedStr);
    
    
    return ret;
}




+(NSString*)urlEncodeStringXML:(NSString*)str
{
    if(str == nil)return nil;
    if([str isKindOfClass:[NSString class]]== NO)return str;
    if([str length]==0)return str;
    
    return [[str stringByReplacingOccurrencesOfString:@"<" withString:@"&#60;"] stringByReplacingOccurrencesOfString:@">" withString:@"&#62;"] ;
    
}




@end
