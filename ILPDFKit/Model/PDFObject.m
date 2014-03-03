//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFObject.h"
#import "PDFUtility.h"
#import "PDFDictionary.h"
#import "PDFArray.h"
#import "PDFDocument.h"

#import <objc/runtime.h>


@implementation NSString(PDF)

-(BOOL)isName
{
    return [objc_getAssociatedObject(self, @selector(isName)) isKindOfClass:[NSNull class]];
}

-(void)setAsName:(BOOL)isName
{
    if(isName)
    {
        objc_setAssociatedObject(self, @selector(isName), [NSNull null], OBJC_ASSOCIATION_ASSIGN);
    }
    else
    {
         objc_setAssociatedObject(self, @selector(isName), nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

@end

@implementation PDFObject
{
    NSString* _representation;
}

-(NSString*)pdfFileRepresentation
{
    return _representation;
}

#pragma mark - Object Creation


+(PDFObject*)createWithPDFRepresentation:(NSString*)rep
{
    NSString* test = [rep stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
    if(test.length>=2)
    {
        if([test characterAtIndex:0] == '<' && [test characterAtIndex:1] == '<')
            return [[PDFDictionary alloc] initWithPDFRepresentation:rep ];
        if([test characterAtIndex:0] == '[')
            return [[PDFArray alloc] initWithPDFRepresentation:rep ];
    }
    
    return [[PDFObject alloc] initWithPDFRepresentation:rep];
}


-(id)initWithPDFRepresentation:(NSString*)rep
{
    self = [super init];
    if(self != nil)
    {
        NSString* temp = [rep stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
        _representation = temp;
      
    }
    
    return self;
}


-(id)initWithPDFObject:(CGPDFObjectRef)obj
{
    self = [super init];
    if(self != nil)
    {
    }
    return self;
}



@end
