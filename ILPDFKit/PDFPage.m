
#import "PDFPage.h"
#import "PDFDictionary.h"


@interface PDFPage()

-(CGRect)rotateBox:(CGRect)box;


@end

@implementation PDFPage

@synthesize dictionary;
@synthesize pageNumber;
@synthesize rotationAngle;
@synthesize mediaBox;
@synthesize cropBox;
@synthesize bleedBox;
@synthesize trimBox;
@synthesize artBox;
@synthesize page;
@synthesize resources;

-(void)dealloc
{
    [dictionary release];
    [super dealloc];
}

-(id)initWithPage:(CGPDFPageRef)pg
{
    self = [super init];
    if(self != nil)
    {
        page = pg;
    }
    
    return self;
}

#pragma mark - Getter

-(PDFDictionary*)dictionary
{
    if(dictionary == nil)
    {
        dictionary = [[PDFDictionary alloc] initWithDictionary: CGPDFPageGetDictionary(page)];
    }
    
    return dictionary;
}

-(PDFDictionary*)resources
{
    if(resources == nil)
    {
        PDFDictionary* iter = self.dictionary;
        PDFDictionary* res = nil;
        while((res = [iter objectForKey:@"Resources"]) == nil)
        {
            iter = [iter objectForKey:@"Parent"];
            if(iter == nil)break;
        }
        resources = res;
    }
    
    return resources;
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
    return CGPDFPageGetPageNumber(page);
}

-(NSInteger)rotationAngle
{
    return CGPDFPageGetRotationAngle(page);
}

-(CGRect)mediaBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(page, kCGPDFMediaBox)];
}

-(CGRect)cropBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(page, kCGPDFCropBox)];
}

-(CGRect)bleedBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(page, kCGPDFBleedBox)];
}

-(CGRect)trimBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(page, kCGPDFTrimBox)];
}

-(CGRect)artBox
{
    return [self rotateBox:CGPDFPageGetBoxRect(page, kCGPDFArtBox)];
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
