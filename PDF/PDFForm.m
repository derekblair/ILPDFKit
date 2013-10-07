
#import "PDFForm.h"
#import "PDFFormButtonField.h"
#import "PDFFormTextField.h"
#import "PDFFormChoiceField.h"
#import "PDFFormContainer.h"
#import "PDFFormAction.h"
#import "PDFFormSignatureField.h"
#import "PDFViewController.h"
#import "PDFDictionary.h"
#import "PDFPage.h"
#import "PDFArray.h"
#import "PDFStream.h"
#import "PDFDocument.h"

#import <QuartzCore/QuartzCore.h>


@interface PDFForm() 

    -(id)getAttributeFromLeaf:(PDFDictionary*)leaf Name:(NSString*)nme Inheritable:(BOOL)inheritable;
    -(NSString*)getFormNameFromLeaf:(PDFDictionary*)leaf;
    -(NSMutableDictionary*)getActionsFromLeaf:(PDFDictionary*)leaf;
    -(NSString*)getExportValueFrom:(PDFDictionary*)leaf;
    -(NSString*)getSetAppearanceStreamFromLeaf:(PDFDictionary*)leaf;
    -(void)updateFlagsString;

@end

@implementation PDFForm

@synthesize value;
@synthesize frame;
@synthesize page;
@synthesize formType;
@synthesize cropBox;
@synthesize mediaBox;
@synthesize name;
@synthesize defaultValue;
@synthesize flagsString;
@synthesize options;
@synthesize textAlignment;
@synthesize setAppearanceStream;

@synthesize pageFrame;
@synthesize uiBaseFrame;
@synthesize parent;
@synthesize actions;
@synthesize modified;
@synthesize exportValue;
@synthesize imageSize;
@synthesize imageLocation;
@synthesize imageFilename;

-(id)initWithFieldDictionary:(PDFDictionary*)leaf Page:(PDFPage*)pg Parent:(PDFFormContainer*)p
{
    self = [super init];
    if(self != nil)
    {
        value = [[self getAttributeFromLeaf:leaf Name:@"V" Inheritable:YES] retain];
        self.name = [self getFormNameFromLeaf:leaf ];
        NSString* formTypeString = [self getAttributeFromLeaf:leaf Name:@"FT"  Inheritable:YES];
        self.defaultValue = [self getAttributeFromLeaf:leaf Name:@"DV"  Inheritable:YES];
       flags = [[self getAttributeFromLeaf:leaf Name:@"Ff"  Inheritable:YES] unsignedIntegerValue];
        NSNumber* formTextAlignment = [self getAttributeFromLeaf:leaf Name:@"Q" Inheritable:YES];
        self.actions = [self getActionsFromLeaf:leaf];
        self.exportValue = [self getExportValueFrom:leaf];
        self.setAppearanceStream = [self getSetAppearanceStreamFromLeaf:leaf];
        
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        NSArray* arr = [[self getAttributeFromLeaf:leaf Name:@"Opt" Inheritable:YES] nsa];
        
        NSMutableArray* temp = [NSMutableArray array];
        
        for(id obj in arr)
        {
            if([obj isKindOfClass:[PDFArray class]])
            {
                [temp addObject:[obj objectAtIndex:0]];
            }
            else 
            {
                [temp addObject:obj];
            }
        }
       
        self.options = [NSArray arrayWithArray:temp];
        
        [pool drain];
        
        if([formTypeString isEqualToString:@"Btn"])
        {
            self.formType = PDFFormTypeButton;
        }
        else if([formTypeString isEqualToString:@"Tx"])
        {
            self.formType = PDFFormTypeText;
        }
        else if([formTypeString isEqualToString:@"Ch"])
        {
            self.formType = PDFFormTypeChoice;
        }
        else if([formTypeString isEqualToString:@"Sig"])
        {
            self.formType = PDFFormTypeSignature;
        }
        
        self.frame = [[leaf objectForKey:@"Rect"] rect];
        
 
        
        self.page = pg.pageNumber;
        self.mediaBox = pg.mediaBox;
        self.cropBox =  pg.cropBox;
     
        if([leaf objectForKey:@"F"])
        {
            annotFlags = [[leaf objectForKey:@"F"] unsignedIntegerValue];
        }
        
        [[self.actions allValues] makeObjectsPerformSelector:@selector(setParent:) withObject:self];
        
        if(formTextAlignment)
        {
            self.textAlignment = [formTextAlignment unsignedIntegerValue];
        }
        
        [self updateFlagsString];
        self.parent = p;
        
        {
            BOOL noRotate = [flagsString rangeOfString:@"NoRotate"].location!=NSNotFound;
 
            NSUInteger rotation = [(PDFPage*)[self.parent.document.pages objectAtIndex:page-1] rotationAngle];
            if(noRotate)rotation = 0;
            CGFloat a = self.frame.size.width;
            CGFloat b = self.frame.size.height;
            
            CGFloat fx = self.frame.origin.x;
            CGFloat fy = self.frame.origin.y;
            CGFloat tw = self.cropBox.size.width;
            CGFloat th = self.cropBox.size.height;

            switch(rotation%360) {
                case 0:
                  
                    break;
                case 90:
                    self.frame = CGRectMake(fy,th-fx-a, b, a);
                    break;
                case 180:
                    self.frame = CGRectMake(tw-fx-a, th-fy-b, a, b);
                    break;
                case 270:
                    self.frame = CGRectMake(tw-fy-b,fx, b, a);
                default:
                    break;
            }
        }
        
        
    }
    
    return self;
}

-(void)dealloc
{
    
    self.value = nil;
    self.options = nil;
    self.name = nil;
    self.actions = nil;
    self.exportValue = nil;
    self.defaultValue = nil;
    self.setAppearanceStream = nil;
    self.imageLocation = nil;
    self.imageFilename = nil;
    self.flagsString = nil;
    [super dealloc];
}

-(void)setOptions:(NSArray *)opt
{
    if([opt isKindOfClass:[NSNull class]])
    {
        self.options = nil;
        return;
    }
    [options release];
    options = [opt retain];
}


-(void)setValue:(NSString*)val
{
    if([val isKindOfClass:[NSNull class]] == YES)
    {
        [self setValue:nil];
        return;
    }
    
    if([val isEqualToString:value] == NO && (val||value))
    {
        self.modified = YES;
    }
    
    if(value!=val)
    {
        [value release];
        value = [val retain];
    }
}


-(void)updateFlagsString
{
    NSString* temp = @"";
    
    if(BIT(0, flags))
    {
        temp = [temp stringByAppendingString:@"-ReadOnly"];
    }
    if(BIT(1, flags))
    {
        temp = [temp stringByAppendingString:@"-Required"];
    }
    if(BIT(2, flags))
    {
        temp = [temp stringByAppendingString:@"-NoExport"];
    }
    
    if(formType == PDFFormTypeButton)
    {
    
        if(BIT(14, flags))
        {
            temp = [temp stringByAppendingString:@"-NoToggleToOff"];
        }
        if(BIT(15, flags))
        {
            temp = [temp stringByAppendingString:@"-Radio"];
        }
        if(BIT(16, flags))
        {
            temp = [temp stringByAppendingString:@"-Pushbutton"];
        }
        
    }
    else if(formType == PDFFormTypeChoice)
    {
        if(BIT(17, flags))
        {
            temp = [temp stringByAppendingString:@"-Combo"];
        }
        if(BIT(18, flags))
        {
            temp = [temp stringByAppendingString:@"-Edit"];
        }
        if(BIT(19, flags))
        {
            temp = [temp stringByAppendingString:@"-Sort"];
        }             
    }
    else if(formType == PDFFormTypeText)
    {   
        if(BIT(12, flags))
        {
            temp = [temp stringByAppendingString:@"-Multiline"];
        }
        if(BIT(13, flags))
        {
            temp = [temp stringByAppendingString:@"-Password"];
        }
    }
    
    
    if(BIT(0, annotFlags))
    {
        temp = [temp stringByAppendingString:@"-Invisible"];
    }
    if(BIT(1, annotFlags))
    {
        temp = [temp stringByAppendingString:@"-Hidden"];
    }
    if(BIT(2, annotFlags))
    {
        temp = [temp stringByAppendingString:@"-Print"];
    }
    if(BIT(3, annotFlags))
    {
        temp = [temp stringByAppendingString:@"-NoZoom"];
    }
    if(BIT(4, annotFlags))
    {
        temp = [temp stringByAppendingString:@"-NoRotate"];
    }
    if(BIT(5, annotFlags))
    {
        temp = [temp stringByAppendingString:@"-NoView"];
    }
    
    
    self.flagsString = temp;

}


-(PDFUIAdditionElementView*)createUIAdditionViewForSuperviewWithWidth:(CGFloat)vwidth Margin:(CGFloat)margin
{
    if([flagsString rangeOfString:@"Hidden"].location != NSNotFound)return nil;
    if([flagsString rangeOfString:@"Invisible"].location != NSNotFound)return nil;
    if([flagsString rangeOfString:@"NoView"].location != NSNotFound)return nil;
    
    CGFloat width = cropBox.size.width;
    CGFloat maxWidth = width;
    
    for(PDFPage* pg in self.parent.document.pages)
    {
        if([pg cropBox].size.width > maxWidth)maxWidth = [pg cropBox].size.width;
    }
    
    CGFloat hmargin = ((maxWidth-width)/2)*((768.0f-2*margin)/maxWidth)+margin;
    
    CGFloat height = cropBox.size.height;
    CGRect correctedFrame = CGRectMake(frame.origin.x-cropBox.origin.x, height-frame.origin.y-frame.size.height-cropBox.origin.y, frame.size.width, frame.size.height);
    CGFloat realWidth = vwidth-2*hmargin;
    CGFloat factor = realWidth/width;
    
    CGFloat pageOffset = 0;
    for(NSUInteger c = 0; c < self.page-1;c++)
    {
        PDFPage* pg = [self.parent.document.pages objectAtIndex:c];
        
        CGFloat iwidth = [pg cropBox].size.width;
        
        CGFloat ihmargin = ((maxWidth-iwidth)/2)*((768.0f-2*margin)/maxWidth)+margin;
        
        CGFloat iheight = [pg cropBox].size.height;
        CGFloat irealWidth = vwidth-2*ihmargin;
        CGFloat ifactor = irealWidth/iwidth;
        
        pageOffset+= ((iheight*ifactor)+margin);
    }
    
    pageFrame = CGRectMake(correctedFrame.origin.x*factor+hmargin, correctedFrame.origin.y*factor+margin, correctedFrame.size.width*factor, correctedFrame.size.height*factor);
    PDFUIAdditionElementView* formUIElement = nil;
     uiBaseFrame = CGRectMake(pageFrame.origin.x, pageFrame.origin.y+pageOffset, pageFrame.size.width, pageFrame.size.height);
    
    switch (formType)
    {
        case PDFFormTypeText:
        {
            PDFFormTextField* temp = [[PDFFormTextField alloc] initWithFrame:uiBaseFrame Multiline:([flagsString rangeOfString:@"-Multiline"].location != NSNotFound) Alignment:textAlignment SecureEntry:([flagsString rangeOfString:@"-Password"].location != NSNotFound) ReadOnly:([flagsString rangeOfString:@"-ReadOnly"].location != NSNotFound)];
            formUIElement = temp;
        }
            break;
        case PDFFormTypeButton:
        {
            BOOL radio = ([flagsString rangeOfString:@"-Radio"].location != NSNotFound);
            
            if(setAppearanceStream)
            {
                if([setAppearanceStream rangeOfString:@"ZaDb"].location!=NSNotFound && [setAppearanceStream rangeOfString:@"(l)"].location!=NSNotFound)radio = YES;
            }
            
            
            PDFFormButtonField* temp = [[PDFFormButtonField alloc] initWithFrame:uiBaseFrame Radio:radio ];
            temp.noOff = ([flagsString rangeOfString:@"-NoToggleToOff"].location != NSNotFound);
            temp.name = self.name;
            temp.pushButton = ([flagsString rangeOfString:@"Pushbutton"].location != NSNotFound);
            temp.exportValue = self.exportValue;
            formUIElement = temp;
        }
            break;
        case PDFFormTypeChoice:
        {
            PDFFormChoiceField* temp = [[PDFFormChoiceField alloc] initWithFrame:uiBaseFrame Options:options];
            formUIElement = temp;
        }
            break;
        case PDFFormTypeSignature:
        {
            PDFFormSignatureField* temp = [[PDFFormSignatureField alloc] initWithFrame:uiBaseFrame];
            formUIElement = temp;
        }
            break;
        case PDFFormTypeNone:
        default:
            break;
    }
    
    [formUIElement setValue:self.value];
    formUIElement.delegate = self;
    [self addObserver:formUIElement forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:formUIElement forKeyPath:@"options" options:NSKeyValueObservingOptionNew context:NULL];
    return formUIElement;
}


#pragma mark - PDFUIAdditionElementViewDelegate

-(void)uiAdditionEntered:(PDFUIAdditionElementView *)sender
{
    [[actions objectForKey:@"E"] execute];
    [[actions objectForKey:@"A"] execute];
}

-(void)uiAdditionValueChanged:(PDFUIAdditionElementView *)sender
{
    
    self.modified = YES;
    PDFUIAdditionElementView* v = ((PDFUIAdditionElementView *)sender);
    
    if([v isKindOfClass:[PDFFormButtonField class]])
    {
        
        PDFFormButtonField* button =  (PDFFormButtonField*)v;
        BOOL set = [button.exportValue isEqualToString:button.value];
        
        if(button.pushButton == NO)
        {
            if(button.noOff && set == YES)
            {
                return;
            }
            else
            {
                [parent setValue:set?nil:exportValue ForFormWithName:self.name];
            }
        }
        else
        {
            self.modified = NO;
            // disable execution of pushbuttons
            //[[actions objectForKey:@"A"] execute];
            return;
        }
    }
    else
    {
        [parent setValue:[v value] ForFormWithName:self.name];
        [parent setHTML5StorageValue:self.value ForKey:@"EventValue"];
        ((PDFFormAction*)[actions objectForKey:@"K"]).prefix = ((PDFFormAction*)[actions objectForKey:@"E"]).string;
        [[actions objectForKey:@"K"] execute];
        [[actions objectForKey:@"K"] execute];
    }
}

-(void)uiAdditionOptionsChanged:(PDFUIAdditionElementView *)sender
{
    self.options = ((PDFUIAdditionElementView*)sender).options;
}

-(void)reset
{
    self.value = self.defaultValue;
}

#pragma mark - Hidden

-(id)getAttributeFromLeaf:(PDFDictionary*)leaf Name:(NSString*)nme  Inheritable:(BOOL)inheritable 
{
   
    PDFDictionary* iter = nil;
    PDFDictionary* temp = nil;
    id object;
    
    temp = [leaf objectForKey:@"Parent"];
    
    iter = ((temp == nil)?leaf.parent:leaf);temp = nil;
    
    if(iter == nil)iter = leaf;
    
    BOOL objectIsValid;
    
    while(!(objectIsValid = ((object = [iter objectForKey:nme])!=nil)) && (inheritable == YES))
    {
        object = nil;
        if(!(temp = [iter objectForKey:@"Parent"]))break;
        iter = temp;
    }
    
    if((inheritable == NO && objectIsValid == NO) || object == NULL)return nil;
    return object;
}


-(NSString*)getFormNameFromLeaf:(PDFDictionary*)leaf 
{
    
   
    PDFDictionary* iter = nil;
    PDFDictionary* temp = nil;
    
    temp = [leaf objectForKey:@"Parent"];
    
    iter = ((temp==nil)?leaf.parent:leaf);temp = nil;
    
    if(iter==nil)iter = leaf;
    
    
    NSString* string = nil;
    NSString* ret = @"";
    
    do{
        
        BOOL objectIsValid = [(string = [iter objectForKey:@"T"]) isKindOfClass:[NSString class]];
        
        if(objectIsValid)
        {
            ret = [[NSString stringWithFormat:@"%@.",string] stringByAppendingString:ret];
        }
        
        temp = [iter objectForKey:@"Parent"];
        
        if(temp == nil)break;
        iter = temp;
        
    }while(YES);
    
    if([ret length]>0)ret = [ret substringToIndex:[ret length]-1];
    
    return ret;
}


-(NSMutableDictionary*)getActionsFromLeaf:(PDFDictionary*)leaf
{
    NSMutableDictionary* ret = [NSMutableDictionary dictionary];
    
    PDFDictionary* actionsd = nil;
    
    if((actionsd = [leaf objectForKey:@"A"]) != nil)
    {
        PDFFormAction* act = [[PDFFormAction alloc] initWithActionDictionary:actionsd];
        [ret setObject:act forKey:@"A"];
        act.key = @"A";
        [act release];
    }
    
    PDFDictionary* iter = nil;
    PDFDictionary* temp = nil;
    
    temp = [leaf objectForKey:@"Parent"];
    iter = ((temp==nil)?leaf.parent:leaf);temp = nil;
    
    if(iter==nil)iter = leaf;
    
    PDFDictionary* additionalActions = nil;
    
    BOOL active = ((additionalActions = [iter objectForKey:@"AA"]) != nil);
    
    if(active == NO && iter!= leaf)
    {
        active = ((additionalActions = [leaf objectForKey:@"AA"]) != nil);
    }
    
    if(active)
    {
        NSArray* keys = [NSArray arrayWithObjects:@"E",@"K", nil];
        
        for(NSString* key in keys)
        {
            PDFDictionary* action = nil;
            if((action = [additionalActions objectForKey:key]))
            {
                PDFFormAction* formAction = [[PDFFormAction alloc] initWithActionDictionary:action];
                formAction.key = key;
                [ret setObject:formAction forKey:key];
                [formAction release];
            }
        }
    }
    
    return ret;
    
    
}
-(NSString*)getSetAppearanceStreamFromLeaf:(PDFDictionary*)leaf
{
    PDFDictionary* ap = nil;
    
    if((ap = [leaf objectForKey:@"AP"]))
    {
        PDFDictionary* n = nil;
        if([(n = [ap objectForKey:@"N"]) isKindOfClass:[PDFDictionary class]])
        {
            for(NSString* key in [n allKeys])
            {
                if([key isEqualToString:@"Off"] == NO && [key isEqualToString:@"OFF"] == NO)
                {
                    PDFStream* str = [n objectForKey:key];
                    if([str isKindOfClass:[PDFStream class]])
                    {
                        NSData* dat = str.data;
                        if(str.dataFormat == CGPDFDataFormatRaw)
                        {
                            return [[[NSString alloc] initWithData:dat encoding:NSASCIIStringEncoding] autorelease];
                        }
                    }
                }
            }
        }
    }
    
    return nil;
    
}
-(NSString*)getExportValueFrom:(PDFDictionary*)leaf  
{
    PDFDictionary* ap = nil;
    
    if((ap = [leaf objectForKey:@"AP"]))
    {
        PDFDictionary* n = nil;
        if([(n = [ap objectForKey:@"N"]) isKindOfClass:[PDFDictionary class]])
        {
            for(NSString* key in [n allKeys])
            {
                if([key isEqualToString:@"Off"] == NO && [key isEqualToString:@"OFF"] == NO)return key;
            }
        }
    }
    
    NSString * as = nil;
    
    if((as = [leaf objectForKey:@"AS"]))
    {
        return as;
    }
    
    return nil;
}

@end
