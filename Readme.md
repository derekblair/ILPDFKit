#ILPDFKit

A simple toolkit for filling out PDF forms in iOS.



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
    [_pdfViewController.document writeToFile:@"new-file-in-app-doc-dir.pdf"];
    
## Features


  For this version, all features are considered experimental. Expanded features and documentation will be released in subsequent versions.
  
  * View and interact with PDF forms (Button, Text, and Choice)
  * Support for JavaScript PDF actions (A, E and K keys)
  * Save form data to the original PDF file (Uncompressed PDF files only)
  * Created XML respresentation of all forms and data for form submission.
  
## Future Features
  * Support for signature forms.
  * Support for SubmitForm, ResetForm and other PDF actions values. 
  * Draw vector drawings on the PDF, optionally saving the changes.


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
