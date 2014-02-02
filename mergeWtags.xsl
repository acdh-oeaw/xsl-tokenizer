<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 13, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p>merges the attributes added to the bare token-sequence, with the full text (toks-ids)
            based on the token-id</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>path to the file containing the w-tags with attributes to be merged</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="enriched-tokens-doc-path"></xsl:param>
    
    <xsl:variable name="enriched-tokens-doc" select="doc(resolve-uri($enriched-tokens-doc-path,base-uri()))" />
      
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:w">
        
        <xsl:variable name="wid" select="@xml:id" />
        <xsl:variable name="matching-w" select="$enriched-tokens-doc/id($wid)" >
            <!--<xsl:for-each select="$enriched-tokens-doc">
                <xsl:copy-of select="(key('namex', ($curr-lemma, $curr-lemma-normalized, $curr-lemma-normalized2, $curr-lemma-normalized3)))[1]" />
            </xsl:for-each>-->
        </xsl:variable>
        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="$matching-w/@*[not(name()='xml:id')]"/>            
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>