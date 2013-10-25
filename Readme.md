#ILPDFKit

A simple toolkit for filling out PDF forms, and extracting PDF data in iOS.


![screenshot](http://i.imgur.com/lwuG0aC.png "Screenshot")

## Installation

   Add the source files located in the 'ILPDFKit' folder to your project.

## Quick Start

 The quickest way to get started with ILPDFKit is to take a look at the included sample app. For example, to view a PDF form resource named 'test.pdf' you can do the following:

    _pdfViewController = [[PDFViewController alloc] initWithResource:@"test"];
    
    
    // Manually set a form value
    
    [_pdfViewController.document.forms setValue:@"Derek" ForFormWithName:@"FullName"];
    
    // Save a form updated manually or via the user to disk
    
    [_pdfViewController.document saveFormsToDocumentData]
    [_pdfViewController.document writeToFile:somePath];
    
## Features


  For this version, all features are considered experimental. Expanded features and documentation will be released in subsequent versions.
  
  * View and interact with PDF forms (Button, Text, and Choice)
  * Extract and modify AcroForm values.
  * Support for JavaScript PDF actions (A, E and K keys)
  * Save form data to the original PDF file (Uncompressed PDF files only)
  * Created XML respresentation of all forms and data for form submission.
  * Print filled out forms to a printer or flat PDF.
  * Easy introspection using PDFDocument, PDFPage, PDFDictionary and PDFArray.
  * Rapidly, parse, extract and analyze PDF document structure, data and properties.
  
  
## Usage


### Filling out Forms

	_pdfViewController = [[PDFViewController alloc] initWithResource:@"test"];
	[self.window setRootViewController:_pdfViewController];
	// Have fun filling out the form.


### Getting/Setting Form Values Explicity

	for(PDFForm* form in _pdfViewController.document.forms)
	{
		// Get
		NSString* formValue = form.value;
		NSString* formName = form.name;
		
		// Set
		form.value = @"hahahaha";
		// If the form is visible on screen it will updated automatically.
	}


### Saving Forms

	[_pdfViewController.document saveFormsToDocumentData];
	/* At this point, _pdfViewController.documentData represents the updated PDF.
	   You can do as you wish with it. Upload, save to disk etc.
	*/ 
	
### Sending Form XML Data 

	NSString* documentFormsXML = [_pdfViewController.document formsXML];
	// Push to webservice
	


## Documentation

[CocoaDocs](http://cocoadocs.org/docsets/ILPDFKit)


## License

(The MIT License)

Copyright (c) 2013 Derek Blair &lt;derekjblair@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
