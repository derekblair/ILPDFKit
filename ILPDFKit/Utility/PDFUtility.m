//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFUtility.h"
#import "PDFObject.h"
#import "PDFDocument.h"
#import <zlib.h>

@implementation PDFUtility

#pragma mark - Shared Instance

+ (instancetype)sharedPDFUtility
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Utility Functions


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
    NSString* ret = [[NSString alloc] initWithString:(__bridge NSString*)encodedStr];
    CFRelease(encodedStr);
    return [ret stringByReplacingOccurrencesOfString:@"%" withString:@"#"];
}


+(NSString*)pdfObjectRepresentationFrom:(id)obj
{
    NSString* objRepresentation = nil;
    
    if([obj isKindOfClass:[NSString class]])
    {
        
        if([obj rangeOfString:@"ioref"].location!=NSNotFound)
        {
            NSArray* tokens = [obj componentsSeparatedByString:@","];
            objRepresentation = [NSString stringWithFormat:@"%ld %ld R",(long)[[tokens objectAtIndex:0] integerValue],(long)[[tokens objectAtIndex:1] integerValue]];
            
        }
        else if([obj isName])
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
    }
    else if([obj isKindOfClass:[NSNumber class]])
    {
        if (strcmp([obj objCType], @encode(BOOL)) == 0)
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

+(NSCharacterSet*)whiteSpaceCharacterSet
{
    NSMutableCharacterSet* ret = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(0, 1)];
    [ret addCharactersInRange:NSMakeRange(9, 2)];
    [ret addCharactersInRange:NSMakeRange(12, 2)];
    [ret addCharactersInRange:NSMakeRange(32, 1)];
    
    return ret;
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
    
    NSString* ret = [[NSString alloc] initWithString:(__bridge NSString*)encodedStr];
    
    CFRelease(encodedStr);
    
    
    return ret;
}

+(NSString*)decodeURLEncodedString:(NSString*)str
{
    if(str == nil)return nil;
    if([str isKindOfClass:[NSString class]]== NO)return str;
    if([str length]==0)return str;
    
    CFStringRef decodedStr= CFURLCreateStringByReplacingPercentEscapes(NULL,(CFStringRef)str,CFSTR(""));
    
    NSString* ret = [[NSString alloc] initWithString:(__bridge NSString*)decodedStr];
    
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
