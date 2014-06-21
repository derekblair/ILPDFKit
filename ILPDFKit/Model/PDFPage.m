//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFPage.h"
#import "PDFDictionary.h"
#import "PDFAnnotation.h"
#import "PDFDocument.h"

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

#pragma mark - Annotations

-(NSMutableArray *)showAnnotationsForPageWithWidth:(CGFloat)vwidth XMargin:(CGFloat)xmargin YMargin:(CGFloat)ymargin{
    
    CGPDFPageRef pPage=self.page;
    
    NSMutableArray* pdfAnnots = [[NSMutableArray alloc] init];
    
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pPage);
    CGPDFArrayRef outputArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
        return nil;
    }
    else{
        int arrayCount = CGPDFArrayGetCount( outputArray );
        for( int j = 0; j < arrayCount; ++j ) {
            CGPDFObjectRef aDictObj;
            if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
                break;
            }
            
            CGPDFDictionaryRef annotDict;
            if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
                break;
            }
            
            const char *annotationType;
            CGPDFDictionaryGetName(annotDict, "Subtype", &annotationType);
            
            NSString* type = [NSString stringWithUTF8String:annotationType];
            
            BOOL freeTextCustomAnotToShow=YES;
            CGPDFDictionaryRef apDict;
            if(CGPDFDictionaryGetDictionary(annotDict, "AP", &apDict)){
                int count = CGPDFDictionaryGetCount(apDict);
                if(count>0 && [type isEqualToString:FREE_TEXT_ANNOTATION])
                    freeTextCustomAnotToShow=NO;
            }
            
            CGPDFArrayRef rectArray;
            if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
                break;
            }
            
            int arrayCount = CGPDFArrayGetCount( rectArray );
            CGPDFReal coords[4];
            for( int k = 0; k < arrayCount; ++k ) {
                CGPDFObjectRef rectObj;
                if(!CGPDFArrayGetObject(rectArray, k, &rectObj)) {
                    break;
                }
                
                CGPDFReal coord;
                if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
                    break;
                }
                
                coords[k] = coord;
            }
            
            CGRect rect = CGRectMake(coords[0],coords[1],coords[2],coords[3]);
            
            UIColor *annotColor = [UIColor blackColor];
            CGPDFArrayRef colorArray;
            if(CGPDFDictionaryGetArray(annotDict, "C", &colorArray)) {
                int cArrayCount = CGPDFArrayGetCount( colorArray );
                CGPDFReal colors[3];
                for( int k = 0; k < cArrayCount; ++k ) {
                    CGPDFObjectRef colorObj;
                    if(!CGPDFArrayGetObject(colorArray, k, &colorObj)) {
                        break;
                    }
                    CGPDFReal color;
                    if(!CGPDFObjectGetValue(colorObj, kCGPDFObjectTypeReal, &color)) {
                        break;
                    }
                    colors[k] = color;
                }
                annotColor=[UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:1];
                
            }
            rect.size.width -= rect.origin.x;
            rect.size.height -= rect.origin.y;
            
            //to show the annotation on the right position a +5 is needed. It may
            //be needed because the content inset Top of the ResizableTextView is set
            //to -5 ?Dont know why this effects the y value of the frame?
            rect.origin.y +=5;
            CGRect cropBox=[self cropBox];
            CGFloat width = cropBox.size.width;
            CGFloat maxWidth = width;
            for(PDFPage* pg in self.document.pages)
            {
                if([pg cropBox].size.width > maxWidth)maxWidth = [pg cropBox].size.width;
            }
            
            CGFloat hmargin = ((maxWidth-width)/2)*((vwidth-2*xmargin)/maxWidth)+xmargin;
            
            
            
            CGFloat height = cropBox.size.height;
            CGRect correctedFrame = CGRectMake(rect.origin.x-cropBox.origin.x, height-rect.origin.y-rect.size.height-cropBox.origin.y, rect.size.width, rect.size.height);
            
            CGFloat realWidth = vwidth-2*hmargin;
            
            CGFloat factor = realWidth/width;
            
            CGFloat pageOffset = 0;
            
            for(NSUInteger c = 0; c < self.pageNumber-1;c++)
            {
                PDFPage* pg = [self.document.pages objectAtIndex:c];
                CGFloat iwidth = [pg cropBox].size.width;
                CGFloat ihmargin = ((maxWidth-iwidth)/2)*((vwidth-2*xmargin)/maxWidth)+xmargin;
                CGFloat iheight = [pg cropBox].size.height;
                CGFloat irealWidth = vwidth-2*ihmargin;
                CGFloat ifactor = irealWidth/iwidth;
                pageOffset+= iheight*ifactor+ymargin;
            }
            
            
            CGRect pageRect =  CGRectIntegral(CGRectMake(correctedFrame.origin.x*factor+hmargin, correctedFrame.origin.y*factor+ymargin, correctedFrame.size.width*factor, correctedFrame.size.height*factor));
            
            
            
            CGRect uiBaseRect = CGRectIntegral(CGRectMake(pageRect.origin.x, pageRect.origin.y+pageOffset, pageRect.size.width, pageRect.size.height));
            
            
            PDFAnnotation *annotation = [[PDFAnnotation alloc] initWithPDFDictionary:annotDict andType:type];
            
            
            CGSize strSize=[annotation.textString sizeWithFont:annotation.font];
            
            if(uiBaseRect.size.width<strSize.width)
                uiBaseRect.size.width=strSize.width+30.0;
            else
                uiBaseRect.size.width+=50.0;
            
            if(uiBaseRect.size.height<strSize.height){
                uiBaseRect.size.height=strSize.height+30.0;
            }else
                uiBaseRect.size.height+=50.0;
            
            // FreeText annotations are identified by FreeText name stored in Subtype key in annotation dictionary.
            if ([type isEqualToString:FREE_TEXT_ANNOTATION] && freeTextCustomAnotToShow){
                UITextView *annotationView = [[UITextView alloc] initWithFrame:uiBaseRect];
                annotationView.font = annotation.font;
                annotationView.text = annotation.textString;
                annotationView.textColor = annotation.textColor;
                annotationView.backgroundColor = [UIColor clearColor];
                annotationView.textAlignment = annotation.textAlignment;
                [annotationView setEditable:NO];
                annotationView.scrollEnabled=NO;
                
                if (annotation.borderWidth != 0) {
                    annotationView.layer.borderColor = annotation.textColor.CGColor;
                    annotationView.layer.borderWidth = annotation.borderWidth;
                }
                
                annotation.annotationView = annotationView;
                [pdfAnnots addObject:annotation];
                
            }else{
                // you may support more annotations
            }
        }
    }
    return pdfAnnots;
}

@end
