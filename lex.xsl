<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" exclude-result-prefixes="#all" version="2.0">

    <xsl:param name="path-to-lexicon">lexicon.txt</xsl:param>
    
    <xsl:variable name="lexicon" as="xs:string*">
        <xsl:for-each select="tokenize(unparsed-text($path-to-lexicon),'\n')">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="lexToks" as="element(tei:seg)*">
        <xsl:for-each select="$lexicon">
            <tei:seg xml:id="entry_{position()}">
                <xsl:call-template name="tokenize-text"/>
            </tei:seg>
        </xsl:for-each>
    </xsl:variable>
    
    
    
</xsl:stylesheet>