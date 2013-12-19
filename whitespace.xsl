<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 12, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p>whitespace cleanup</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="tei:seg[@type='whitespace']" mode="purgeNewlineonlyWhitespaceTags">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="tei:seg[@type='whitespace']" mode="purgeWhitespace"/>

    <xsl:template match="tei:seg[@type='whitespace'][matches(.,'^\n$')]" mode="purgeWhitespace"
        priority="3">
        <xsl:if test="xs:boolean($purgeNewlineonlyWhitespaceTags) eq false()">
            <xsl:value-of select="."/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="node() | @*" mode="purgeWhitespace purgeNewlineonlyWhitespaceTags">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
