//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFPage.h"
#import "PDFDictionary.h"


@interface PDFPage()

-(CGRect)rotateBox:(CGRect)box;


@end

@implementation PDFPage
{
    CGPDFPageRef _page;
    PDFDictionary* _dictionary;
    PDFDictionary* _resources;
}

#pragma mark - Initialization

-(id)initWithPage:(CGPDFPageRef)pg
{
    self = [super init];
    if(self != nil)
    {
        _page = pg;
    }
    
    return self;
}

#pragma mark - Getter

-(PDFDictionary*)dictionary
{
    if(_dictionary == nil)
    {
        _dictionary = [[PDFDictionary alloc] initWithDictionary: CGPDFPageGetDictionary(_page)];
    }
    
    return _dictionary;
}

-(PDFDictionary*)resources
{
    if(_resources == nil)
    {
        PDFDictionary* iter = self.dictionary;
        PDFDictionary* res = nil;
        while((res = [iter objectForKey:@"Resources"]) == nil)
        {
            iter = [iter objectForKey:@"Parent"];
            if(iter == nil)break;
        }
        _resources = res;
    }
    
    return _resources;
}

-(UIImage*)thumbNailImage
{
    NSData* dat = [[self.dictionary objectForKey:@"Thumb"] data];
    if(dat)
    {
        return [UIImage imageWithData:dat];
    }
    return nil;
}

-(NSUInteger)pageNumber
{
    return CGPDFPageGetPageNumber(_page);
}

-(NSInteger)rotationAngle
{
    return CGPDFPageGetRotationAngle(_page);
}

-(CGRect)mediaBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFMediaBox)];
}

-(CGRect)cropBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFCropBox)];
}

-(CGRect)bleedBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFBleedBox)];
}

-(CGRect)trimBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFTrimBox)];
}

-(CGRect)artBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFArtBox)];
}


#pragma mark - Hidden


-(CGRect)rotateBox:(CGRect)box
{
    
    CGRect ret= box;
    
    switch([self rotationAngle]%360) {
        case 0:
            break;
        case 90:
            ret = CGRectMake(ret.origin.x,ret.origin.y,ret.size.height,ret.size.width);
            
            break;
        case 180:
            
            break;
        case 270:
            ret = CGRectMake(ret.origin.x,ret.origin.y,ret.size.height,ret.size.width);
            
        default:
            break;
    }
    
    return ret;
}

@end
