#!/bin/bash

#the default saxon 
s=saxon9he.jar

export tmpDir="tmp_$$"
export pathToLogfile="$tmpDir/log.txt"

methodKeys="'makeXSL', 'get-profile','rmNl', 'tokenize', 'vert-xml' or 'vert-txt'"

usage() {
    echo "xtx.sh - a shell script frontend for xml tokenization"
    echo "====================================================="
    echo "Parameters:"
    echo "  -p / --profile: The name of the tokenization profile. (MANDADORY)"
    echo "  -pv / --paramValue: read profile and return the value of given parameter (implies -m = get-profile)"
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
    echo "  -f / --force: Force rebuilding the wrapper stylesheets"
    echo "This script is merely provided for convenience - other methods of invoking the stylesheets are most probably more efficient."
    echo ""
}


# write to log file 
# $1 = message to be written 
log () {
	echo "$1" >> $pathToLogfile
}

# retrieve parameter value from profile
# $1 = profile name
# $2 = parameter name
profileParamValue() {
	profile $1 | grep "param key=\"$2\"" | grep -oP '(?<=value=").+(?=\")'
}

# return profile definition document by profile name
# $1 = profile name
profile() {
	cat "`profilePath $1`"
}

# return path to profile definition directory by profile name
# $1 = profile name
profileDir() {
	echo "profiles/$1"	
}

# return path to profile definition document by profile name
# $1 = profile name
profilePath() {
	echo "profiles/$1/profile.xml"	
}

# return path to the cached post-tokenization XSLT scripts extracted from tokenization profile
# $1 = profile name
postTokXSLDir() {
	echo "`profileDir $1`/postTokenization"
}

# prepare profile wrapper stylesheets
# $1 = profile name
mkXSL() {
	profileDir=`profileDir $1`
	profilePath=`profilePath $1`
	postTokXSLDir=`postTokXSLDir $1`
	[ -d "$postTokXSLDir" ] && rm -r $postTokXSLDir
	$s -xi -s:"$profilePath" -xsl:xsl/make_xsl.xsl "output-base-path=$profileDir" "postTokXSLDir=$postTokXSLDir" $d
	eval "md5sum `profilePath $1`" > "`profileDir $1`/compiledFrom"
}

# remove new lines 
# $1 = input file
rmNl() {
	$s -s:$1 -xsl:xsl/rmNl.xsl $d
}

# tokenize 
# $1 = input file
# $2 = profile name
# $3 = override tokenNamespace parameter (needed by vert-txt())
# $4 = override preserveWs parameter (needed by vert-txt())
tokenize() {
	profileDir="`profileDir $2`"
	log "starting rmNl"
	eval "rmNl $1" > $tmpDir/rmnl.xml
	log "stopped rmNl"
	xsl="wrapper_toks.xsl"
	log "starting $xsl"
	eval "$s -s:$tmpDir/rmnl.xml -xsl:$profileDir/$xsl $d" > $tmpDir/0_toks.xml
	log "stopped $xsl"
		
	
	xsl="wrapper_addP.xsl"
	eval log "starting $xsl"
	$s -s:"$tmpDir/0_toks.xml" -xsl:"$profileDir/$xsl" -o:"$tmpDir/0_toks_PAdded.xml" $d
	log "stopped $xsl"

	# apply post-tokenization stylesheets	
	postTokXSLDir=`postTokXSLDir $2`
	echo "\$postTokXSLDir=$postTokXSLDir" >> $pathToLogfile
	if [ -e $postTokXSLDir ];
	then 
		noOfPostTokenizationXSLs=`ls $postTokXSLDir/*.xsl | wc -l`
		echo $noOfPostTokenizationXSLs > "$tmpDir/noOfPostTokenizationXSLs.txt"
		for i in `ls $postTokXSLDir/*.xsl`; do
			pos=`basename $i .xsl`
			log "starting $pos"
			[ $pos = "1" ] && input="$tmpDir/0_toks_PAdded.xml" || input="$tmpDir/0_toks_PAdded_$((pos - 1)).xml"
			$s -s:$input -xsl:"$i" $d > "$tmpDir/0_toks_PAdded_$pos.xml"
			log "stopped $xsl"
		done
		pathToPostProcessedTok="$tmpDir/0_toks_PAdded_$noOfPostTokenizationXSLs.xml"
	else 
		pathToPostProcessedTok="$tmpDir/0_toks_PAdded.xml" 

	fi


	# create TEI version if wanted; otherwise just remove whitespace nodes if needed	
	[ -z $3 ] && tokenNamespace=`profileParamValue $2 "token-namespace"` || tokenNamespace=$3
	[ -z $4 ] && preserveWs=`profileParamValue $2 "preserve-ws"` || preserveWs=$4
	if [ $tokenNamespace = 'tei' ];
	then 
		$s -s:$pathToPostProcessedTok -xsl:xsl/xtoks2tei.xsl "preserve-ws=$preserveWs" $d
	else 
		if [ $preserveWs = 'true' ];
		then 
			cat $pathToPostProcessedTok 
		else 
			$s -s:$pathToPostProcessedTok -xsl:xsl/rmWs.xsl "preserve-ws=$preserveWs"
		fi
	fi
}


# verticalize to XML
# $1 = input file
# $2 = profile name
# $3 = override tokenNamespace parameter (needed by vert-txt())
# $4 = override preserveWs parameter (needed by vert-txt())
vert-xml() {
	eval "tokenize $1 $2 xtoks" > $tmpDir/1_toks.xml
	xsl="wrapper_xtoks2vert.xsl"
	$s -s:$tmpDir/1_toks.xml -xsl:"`profileDir $2`/$xsl" -o:"$tmpDir/2_vert.xml" $d 

	# create TEI version if wanted, otherwise just remove whitespace nodes
	[ -z $3 ] && tokenNamespace=`profileParamValue $2 "token-namespace"` || tokenNamespace=$3
	[ -z $3 ] && preserveWs=`profileParamValue $2 "preserve-ws"` || preserveWs=$4
	if [ $tokenNamespace = 'tei' ];
	then
		# whitespace is handled by xtoks2tei.xsl
		$s -s:$tmpDir/2_vert.xml -xsl:xsl/xtoks2tei.xsl "preserve-ws=$preserveWs" $d
	else
		# when outputting tokens in xtoks namespace, we need to remove whitespace separately 
		if [ $preserveWs = 'true' ];
		then 
			cat $tmpDir/2_vert.xml
		else 
			$s -s:$pathToPostProcessedTok -xsl:xsl/rmWs.xsl "preserve-ws=$preserveWs"
		fi
	fi
}

# verticalize to txt
# $1 = input file
# $2 = profile name
vert-txt() {
	eval "vert-xml $1 $2 xtoks true" > $tmpDir/2_vert.xml
	xsl="wrapper_vert2txt.xsl"
	$s -s:$tmpDir/2_vert.xml -xsl:"`profileDir $2`/$xsl" $d
}

# returns if the profile has changed since last wrapper stylesheet compilation
# $1 = profile name
profile-has-changed(){
	if [ -e "`profileDir $profile`/compiledFrom" ]; then
		! md5sum -c "`profileDir $profile`/compiledFrom" --status
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
	-p | --profile )        shift
                                profile=$1
                                ;;
	-pv | --paramValue )    shift
                                paramValue=$1
                                ;;
	-f | --force ) 		shift
				forceRebuild="true"
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
    get-profile) [ -z $paramValue ] && `profile $profile` || profileParamValue $profile $paramValue ;;
    makeXSL) mkXSL $profile ;;
    rmNl|tokenize|vert-xml|vert-txt)
	echo "Using Saxon at $s" 
	[ -z $input ] && { echo "ERROR: Missing parameter for input file. Please provide parameter -i or --input"; exit 1; }
	#Checking existence of input document
	[ ! -e $input ] && { echo "ERROR: Input file $input not found."; exit 1; }
	# Only re-make wrapper Stylesheets if there is no compiledFrom file in the profile directory or if the hash of the profile definition document has changed.	
	if [ ! -e "`profileDir $profile`/compiledFrom" ] || profile-has-changed $profile ; 
	then 
	    	echo "The profile has changed. Re-compiling the wrapper stylesheets in `profileDir $profile`."
		mkXSL $profile 
	else 
		if [[ "$forceRebuild" = "true" ]];
		then
			echo "-f / --force flag is set: forcing stylesheet build"
			mkXSL $profile
		else
			echo "There are no profile updates. Using the existing wrapper stylesheets in `profileDir $profile`."
		fi
	fi
	mkdir $tmpDir
	echo "made $tmpDir"
	
	[ -z $output ] && $method $input $profile || { eval "$method $input $profile" > $output ; } 
	[ -z $d ] && rm -rf "$tmpDir"
      ;;

    *) echo "Invalid method $method. Must be either $methodKeys"; exit 1 ;;
esac



