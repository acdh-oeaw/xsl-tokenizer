%README for xsl-tokenizer
%Daniel Schopper
%2014/01/22

This is a set of XSLT-Stylesheets to tokenize marked-up text and create a list of tei:w-tags[1] from it.

# Usage

## Overview
The Usage of this Stylesheets consists of the following steps:

1) Preparation of the source document (stripping of pretty-print whitespace)
2) Configuration and generation of a wrapper stylesheet
3) transformation of the prepared source with this wrapper Stylesheet
4) adding XML-ids to the tokenized parts (addIds.xsl)
5) extracting a list of w-tags (extractWTags.xsl)

## Preparation of the Source
The XML source is expected to consist only of meaningful whitespace in order to work correctly. The Stylesheet 'rmPrettyPrintNewlines.xsl' does normalization on a TEI text, where each <lb/> is followed by a newline (and some other cases). Adjust accordingly to your input document.

## Configuration of the Tokenizer
Tokenization of XML structures involves knowledge about the semantics of the markup. For example each project has to decide which tags do not imply a token boundary. To do so we have to provide a configuration file which provides information about:

(1) parameters for the tokenization prozess
(2) the namespace(s) and prefixes of the markup
(3) a set of XPath expressions to select elements that are *not* to be tokenized (for example <tei:fw> tags which are not part of the running text) - these are to be placed inside the <ignore>-element in the parameter file.
(4) a set of XPath expressions to identify tags that do not imply word/token boundaries - these are to be placed inside the <in-word-tags>-element in the parameter file.

Please see "sample-config.xml" for such a parameter file. 

Processing this parameter file with 'make_xsl.xsl' produces two files: one file "parameter.xsl", which contains the parameters for the tokenization process, and a wrapper-stylesheet, say "tokenize.xsl", which imports the necessary xsl-libraries and overrides it according to the decisions made in (3) and (4). Use this file to process your prepared source document.

## Output
Tokens are tagged with the tei:w-Tag, the strucure and namespace of the source document is not altered. Tokens which are disrupted by markup carry a "part"-attribute, indicating whether this is the inital (part="I"), middle (part="M") or final (part="F") part of the token.  Such partial tokens will be glued together in one single tei:w-Tag when creating the list of w:tags with the stylesheet "extractWTags.xsl".



[1] http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-w.html