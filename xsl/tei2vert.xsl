<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="tei:seg tei:w tei:pc"/>
    
    <xsl:key name="tag-by-id" match="tei:*" use="@xml:id"/>
    
    <xsl:template match="/">
        <xsl:variable name="part-i" select="count(//tei:*[@part = 'I'])"/>
        <xsl:variable name="part-f" select="count(//tei:*[@part = 'F'])"/>
        <xsl:if test="$part-i != $part-f">
            <xsl:message terminate="yes">Unequal number of partial tokens: <xsl:value-of select="$part-i"/> inital, <xsl:value-of select="$part-f"/> final parts</xsl:message>
        </xsl:if>
        <xsl:if test="$debug != 'no'">
            <xsl:message>Debug level: <xsl:value-of select="$debug"/></xsl:message>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:TEI|*[ancestor-or-self::tei:teiHeader]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <body>
                <ab><xsl:apply-templates select="." mode="extractTokens"/></ab>
            </body>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="extractTokens">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:w|tei:seg[@type = 'ws']|tei:pc" mode="extractTokens">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*[@part = 'I']" mode="extractTokens" priority="1">
        <xsl:variable name="next" select="key('tag-by-id', substring-after(@next, '#'))" as="node()?"/>
        <xsl:if test="$debug = 'no' and not($next)">
            <xsl:message terminate="yes">@next is empty or element not found for element <xsl:copy-of select="."/></xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@* except (@part|@prev|@next)"/>
            <xsl:choose>
                <xsl:when test="$debug = 'tei2vert'">
                    <xsl:sequence select="."/>
                    <xsl:apply-templates select="$next" mode="getTokenCopy"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                    <xsl:apply-templates select="$next" mode="getTokenContent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@part = ('M', 'F')]" mode="extractTokens" priority="2"/>
    
    <xsl:template match="*[@part = 'M']" mode="getTokenContent">
        <xsl:variable name="next" select="key('tag-by-id', substring-after(@next, '#'))" as="node()?"/>
        <xsl:if test="not($next)">
            <xsl:message terminate="yes">@next is empty or not found for element <xsl:copy-of select="."/></xsl:message>
        </xsl:if>
        <xsl:value-of select="."/>
        <xsl:apply-templates select="$next" mode="getTokenContent"/>
    </xsl:template>
    
    <xsl:template match="*[@part = 'M']" mode="getTokenCopy">
        <xsl:variable name="next" select="key('tag-by-id', substring-after(@next, '#'))" as="node()?"/>
        <xsl:sequence select="."/>
        <xsl:apply-templates select="$next" mode="getTokenCopy"/>
    </xsl:template>
    
    <xsl:template match="*[@part = 'F']" mode="getTokenContent">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="*[@part = 'F']" mode="getTokenCopy">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="text()[not(parent::tei:w) or not(parent::tei:seg)]" mode="extractTokens"/>
        
    
    
</xsl:stylesheet>