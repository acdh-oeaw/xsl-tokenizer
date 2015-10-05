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
        <xsl:copy>
            <xsl:copy-of select="@* except (@part|@prev|@next)"/>
            <xsl:value-of select="."/>
            <xsl:apply-templates select="root()//*[@xml:id = substring-after(current()/@next, '#')]" mode="getTokenContent"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@part = ('M', 'F')]" mode="extractTokens" priority="2"/>
    
    <xsl:template match="*[@part = ('M', 'F')]" mode="getTokenContent">
        <xsl:value-of select="."/>
        <xsl:apply-templates select="//*[@xml:id = substring-after(current()/@next, '#')]" mode="getTokenContent"/>
    </xsl:template>
    
    <xsl:template match="text()[not(parent::tei:w) or not(parent::tei:seg)]" mode="extractTokens"/>
        
    
    
</xsl:stylesheet>