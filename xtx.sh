#!/bin/bash

#the default saxon 
s=saxon9he.jar

methodKeys="'makeXSL', 'get-profile','rmNl', 'tokenize', 'vert-xml' or 'vert-txt'"

usage() {
    echo "xtx.sh - a shell script frontend for xml tokenization"
    echo "====================================================="
    echo "Parameters:"
    echo "  -p / --profile: The name of the tokenization profile. (MANDADORY)"
    echo "  -i / --input: The path to the XML document to be tokenized."
    echo "  -o / --output: The path to the tokenized dokument. If not given, the scripts outputs to the shell."
    echo "  -m / --method: One of $methodKeys (MANDADORY)"
    echo "                 * makeXSL: Re-compile the wrapper stylesheets (done automatically, if the profile definition document has changed)."
    echo "                 * get-profile: Return the XML definition of the tokenizeation profile."
    echo "                 * rmNl: Return the input document with pretty-print newlines stripped"
    echo "                 * tokenize: Return the input document with added tokens."
    echo "                 * vert-xml: Return a vertical of the tokens as an XML tokument."
    echo "                 * vert-txt: Return a vertical of the tokens as a text file."
    echo "  -s/ --saxon: The path to a JAR distribution of the Saxon XSLT Processor. If this is not set, Saxon 9 HE (saxon9he.jar) must be present in your \$PATH for this script to work."
    echo "This script is merely provided for convenience - other methods of invoking the stylesheets are most probably more efficient."
    echo ""
}

# return path to profile definition document by profile name
# $1 = profile name
profile() {
	echo "`profilePath $1`/profile.xml"	
}

# return path to profile definition document by profile name
# $1 = profile name
profilePath() {
	echo "profiles/$1"	
}

# prepare profile wrapper stylesheets
# $1 = profile name
mkXSL() {
	$s -s:"`profile $1`" -xsl:xsl/make_xsl.xsl output-base-path="`profilePath $1`" $d
	eval "md5sum `profile $1`" > "`profilePath $1`/compiledFrom"
}

# remove new lines 
# $1 = input file
rmNl() {
	$s -s:$1 -xsl:xsl/rmNl.xsl $d
}

# tokenize 
# $1 = input file
# $2 = profile name
tokenize() {
	profilePath="`profilePath $2`"
	eval "rmNl $1" > tmp_$$/rmnl.xml
	xsl="wrapper_toks.xsl"
	eval "$s -s:tmp_$$/rmnl.xml -xsl:$profilePath/$xsl $d" > tmp_$$/0_toks.xml
	xsl="wrapper_addP.xsl"
	$s -s:tmp_$$/0_toks.xml -xsl:"$profilePath/$xsl" $d > tmp_$$/0_toks_PAdded.xml
	noOfPostTokenizationXSLs=`ls $profilePath/postTokenization/*.xsl | wc -l`

	for i in `ls $profilePath/postTokenization/*.xsl`; do
		pos=`basename $i .xsl`
		[ $pos = "1" ] && input="tmp_$$/0_toks_PAdded.xml" || input="tmp_$$/0_toks_PAdded_$((pos - 1)).xml"
		$s -s:$input -xsl:"$i" > "tmp_$$/0_toks_PAdded_$pos.xml"
	done
#	cat tmp_$$/0_toks_PAdded.xml
	[ -z $noOfPostTokenizationXSLs ] && cat "tmp_$$/0_toks_PAdded.xml" || cat "tmp_$$/0_toks_PAdded_$noOfPostTokenizationXSLs.xml"
}


# verticalize to XML
# $1 = input file
# $2 = profile name
# $3 = token namespace
vert-xml() {
	eval "tokenize $1 $2" > tmp_$$/1_toks.xml
	xsl="wrapper_xtoks2vert.xsl"
	[ -z $3 ] && tokenNamespace="tei" || tokenNamespace="$3"
	$s -s:tmp_$$/1_toks.xml -xsl:"`profilePath $2`/$xsl" "token-namespace=$tokenNamespace" $d
}

# verticalize to txt
# $1 = input file
# $2 = profile name
vert-txt() {
	# important! must pass 'xtoks' as third argument here 
	# in order to keep the proprietary token namespace expected by vert-txt
	eval "vert-xml $1 $2 xtoks" > tmp_$$/2_vert.xml
	xsl="wrapper_vert2txt.xsl"
	$s -s:tmp_$$/2_vert.xml -xsl:"`profilePath $2`/$xsl" $d
}

# returns if the profile has changed since last wrapper stylesheet compilation
# $1 = profile name
profile-has-changed(){
	if [ -e "`profilePath $profile`/compiledFrom" ]; then
		! md5sum -c "`profilePath $profile`/compiledFrom" --status
	else
		true
	fi
}


# Test if there is any parameter given, otherwise report usage.
if [ $# -eq 0 ] 
then { usage; exit; }
fi

# Parse user-provided arguments  
while [ "$1" != "" ]; do
    case $1 in
        -i | --input )           shift
                                input=$1
                                ;;
	-p | --profile )           shift
                                profile=$1
                                ;;
        -o | --output )         shift
                                output=$1
                                ;;
	-m | --method )         shift
                                method=$1
                                ;;
	-s | --saxon )          shift
                                s=$(cd "$(dirname "$1")"; pwd)/$(basename "$1")
                                ;;
	-d | --debug )          shift
				d="debug=$1"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

#Testing for required parameters
[ -z $profile ] && { echo "ERROR: Missing profile name. Please provide parameter -p or --profile."; exit 1; }
[ -z $method ] && { echo "ERROR: Missing method name. Please provide parameter -m or --method. Must be $methodKeys. "; exit 1; }

[ ! -e "profiles/$profile/profile.xml" ] && { echo "ERROR: Unknown profile named '$profile'. Profile definition file not found at profiles/$profile/profile.xml"; exit 1; }
[ ! -e $s ] && { echo "Saxon not found at $s"; exit 1; }
s="java -jar $s"
case $method in
    get-profile) cat `profile $profile` ;;
    makeXSL) mkXSL $profile ;;
    rmNl|tokenize|vert-xml|vert-txt)
	echo "Using Saxon at $s" 
	[ -z $input ] && { echo "ERROR: Missing parameter for input file. Please provide parameter -i or --input"; exit 1; }
	#Checking existence of input document
	[ ! -e $input ] && { echo "ERROR: Input file $input not found."; exit 1; }
	# Only re-make wrapper Stylesheets if there is no compiledFrom file in the profile directory or if the hash of the profile definition document has changed.
	
	if [ ! -e "`profilePath $profile`/compiledFrom" ] || profile-has-changed $profile ; 
	then 
	    	echo "The profile has changed. Re-compiling the wrapper stylesheets in `profilePath $profile`."
		mkXSL $profile 
	else 
		echo "There are no profile updates. Using the existing wrapper stylesheets in `profilePath $profile`."
	fi
	mkdir tmp_$$
	[ -z $output ] && $method $input $profile || { eval "$method $input $profile" > $output ; } 
	[ -z $d ] && rm -rf "tmp_$$"
      ;;

    *) echo "Invalid method $method. Must be either $methodKeys"; exit 1 ;;
esac



