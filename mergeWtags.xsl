<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 13, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p>merges the attributes added to the bare token-sequence, with the full text
                (toks-ids) based on the token-id</xd:p>
        </xd:desc>
    </xd:doc>


    <xd:doc>
        <xd:desc>
            <xd:p>path to the file containing the w-tags with attributes to be merged</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="enriched-tokens-doc-path" required="yes" as="xs:string"/>
    <xsl:key name="tags" match="//*[local-name(.) eq 'w' or local-name(.) eq 'pc']" use="(@xml:id|@id)"/>

    <xsl:variable name="enriched-tokens-doc" as="item()" select="doc($enriched-tokens-doc-path)"/>
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="not(exists($enriched-tokens-doc))">
                <xsl:message>Document at <xsl:value-of select="$enriched-tokens-doc-path"/> is not available.</xsl:message>
            </xsl:when>
            <xsl:when test="not($enriched-tokens-doc//(tei:w|w))">
                <xsl:message>Document at <xsl:value-of select="$enriched-tokens-doc-path"/> does not contain w-tags.</xsl:message>
            </xsl:when>
            <xsl:when test="count($enriched-tokens-doc//(tei:w|w)) != count((//tei:pc,//tei:w[not(@part) or @part='I'],//w[not(@part) or @part='I']))">
                <xsl:message>Unequal length of files:</xsl:message>
                <xsl:message><xsl:value-of select="count($enriched-tokens-doc//(tei:w|w))"/> w-tags at <xsl:value-of select="$enriched-tokens-doc-path"/></xsl:message>
                <xsl:message><xsl:value-of select="count((//tei:pc,//tei:w[not(@part) or @part='I'],//w[not(@part) or @part='I']))"/> w-tags at input document.</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:w[@part='I' or not(@part)]|tei:pc">
        <xsl:variable name="matching-w" select="key('tags',@xml:id,$enriched-tokens-doc)" as="element()?"/>
        <xsl:if test="empty($matching-w)">
            <xsl:message>Beware: no matching w-tag in vertical for Tag <xsl:value-of select="local-name(.)"/> ("<xsl:value-of select="."/>") with xml:id <xsl:value-of select="@xml:id"/>.</xsl:message>
        </xsl:if>
        <xsl:message select="concat(@xml:id,': ''',.,''' lemma: ',$matching-w/@lemma)"/>
        <xsl:copy>
            <xsl:apply-templates select="$matching-w/@*|@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
