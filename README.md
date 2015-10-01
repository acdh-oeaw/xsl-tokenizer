#README
#Daniel Schopper, last update 2/11/2015 11:50:25 AM 

This is a set of XSLT-Stylesheets to tokenize marked-up text and create a list of tei:w and tei:pc-Elements[1] from it.

## Usage

### Overview
The Usage of this Stylesheets consists of the following steps:

1. Preparation of the source document (stripping of pretty-print whitespace)
2. Configuration and generation of a wrapper stylesheet
3. transformation of the prepared source with this wrapper Stylesheet
4. adding XML-ids to the tokenized parts (addIds.xsl)
5. extracting a list of w-tags (extractWTags.xsl)
6) optionally, after some processing (like adding attributes on the w-tags), 
the added information can be merged back to the full document (result of step 4) (mergeWtags.xsl)


### Preparation of the Source
The XML source is expected to consist only of meaningful whitespace in order to work correctly. The Stylesheet 'rmPrettyPrintNewlines.xsl' does normalization on a TEI text, where each <lb/> is followed by a newline (and some other cases). Adjust accordingly to your input document.

### Configuration of the Tokenizer
Tokenization of XML structures involves knowledge about the semantics of the markup. For example each project has to decide which tags do not imply a token boundary. To do so we have to provide a configuration file which provides information about:

1. parameters for the tokenization process
2. the namespace(s) and prefixes of the markup
3. a set of XPath expressions to select elements that are *not* to be tokenized (for example <tei:fw> tags which are not part of the running text) - these are to be placed inside the <ignore>-element in the parameter file.
4. a set of XPath expressions to identify tags that do not imply word/token boundaries - these are to be placed inside the <in-word-tags>-element in the parameter file.

Please see "sample-config.xml" for such a parameter file. 

Processing this parameter file with 'make_xsl.xsl' produces two files: one file "parameter.xsl", which contains the parameters for the tokenization process, and . Use this file to process your prepared source document.

### Output
Tokens are tagged with the tei:w-Tag, the strucure and namespace of the source document is not altered. Tokens which are disrupted by markup carry a "part"-attribute, indicating whether this is the inital (part="I"), middle (part="M") or final (part="F") part of the token.  Such partial tokens will be glued together in one single tei:w-Tag when creating the list of w:tags with the stylesheet "extractWTags.xsl".

### XProc Pipeline
There is a simple XProc piple (xsl_tokenizer.xproc) included that glues together the various steps in one single transformation. It requires some parameters to be set, namely the path to the project-specific stylesheets and their file names. Note that this as been only tested on Calabash.



[1] http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-w.html