#xtx HOWTO 

For an overview of the functionality, esp. of the profile definition document, see README.md.

This has been tested with Saxon HE 9.8.0.11 (Saxon9he.jar) on Ubuntu 14.04.2 LTS using GNU bash, version 4.3.11(1)-release (x86_64-pc-linux-gnu).


 
##Running the Stylesheets separately


###Step 1

Create a working directory and copy the test file into it.

`mkdir documents; mkdir documents/test`

`cp test/test.xml documents/test/` 

###Step 2

Create the wrapper stylesheets, in this example the "default" profile.

`saxon9he.jar profiles/default/profile.xml xsl/make_xsl.xsl`

  
###Step 3

Remove new lines and store to intermediate document:

`saxon9he.jar documents/test/test.xml xsl/rmNl.xsl -o:documents/test/test_01_nlRmd.xml`

###Step 4

Tokenize: 

`saxon9he.jar documents/test/test_01_nlRmd.xml profiles/default/wrapper_toks.xsl -o:documents/test/test_02_toks.xml`

This creates an intermediate file with some additional meta-information on the tokens.

###Step 5

Add Part-Attributes and explicit token links:

`saxon9he.jar documents/test/test_02_toks.xml profiles/default/wrapper_addP.xsl -o:documents/test/test_tokenized.xml`

This step returns you input document with added tokens. Depending on your needs, you can further process this document: 

###Step 6

NLP applications like taggers mostly operate on so called verticals, i.e. rather flat token sequences in plain text, which can contain only select structure elements. To get there, we first create a vertical in XML, merging any partial tokens into single `<w>`-elements: 

`saxon9he.jar documents/test/test_tokenized.xml profiles/default/wrapper_tei2vert.xsl -o:documents/test/test_vert.xml`

###Step 7

Based on Step 6, we then create a vertical in text format:  

`saxon9he.jar documents/test/test_tokenized.xml profiles/default/wrapper_tei2vert.xsl -o:documents/test/test_vert.xml`


#Using the Shell script

There is a quickly-hacked shell script named `xtx.sh` which provides some shortcuts to the above-mentioned procedure.
   

	>.\xtx.sh
	
    xtx.sh - a shell script frontend for xml tokenization
	=====================================================
	Parameters:
	  -p / --profile: The name of the tokenization profile. (MANDADORY)
	  -i / --input: The path to the XML document to be tokenized.
	  -o / --output: The path to the tokenized dokument. If not given, the scripts outputs to the shell.
	  -f / --format: One of 'makeXSL', 'get-profile','rmNl', 'tokenize', 'vert-xml' or 'vert-txt' (MANDADORY)
	                 * makeXSL: Re-compile the wrapper stylesheets (done automatically, if the profile definition document has changed).
	                 * get-profile: Return the XML definition of the tokenizeation profile.
	                 * rmNl: Return the input document with pretty-print newlines stripped
	                 * tokenize: Return the input document with added tokens.
	                 * vert-xml: Return a vertical of the tokens as an XML tokument.
	                 * vert-txt: Return a vertical of the tokens as a text file.
	  -s/ --saxon: The path to a JAR distribution of the Saxon XSLT Processor. If this is not set, Saxon 9 HE (saxon9he.jar) must be present in your $PATH for this script to work.

##Example:

`>./xtx.sh -m tokenize -p default -i test/test.xml -o test/test_tokenized.xml --saxon ../saxon/saxon9he.jar`

This means that you:

* want to tokenize the test document `test/test.xml`
* using the `default` profile
* your Saxon JAR is located in `../saxon`
* and you want to output the result to `test/test_tokenized.xml`.


