<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 12, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="no" omit-xml-declaration="yes"/>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>


    <!--<xsl:template
        match="text()[matches(.,'^&#x000A;.+')][preceding-sibling::*[1]/self::lb[not(@break='no')]]">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>-->

    <xsl:template match="*[following-sibling::node()[1]/matches(.,'^[&#x0A;\n]')]">
        <xsl:choose>
            <xsl:when test="self::lb[not(@break='no')]">
                <xsl:text> </xsl:text>
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="self::seg[@type=('header','footer')]">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="self::seg">
                <xsl:copy-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()[matches(.,'^[&#x0A;\n]')]">
        <xsl:value-of select="replace(.,'^&#x0A;','')"/>
    </xsl:template>
    
</xsl:stylesheet>
