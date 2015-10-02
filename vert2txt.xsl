<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="text" indent="no"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="tei:TEI/tei:text/tei:body"/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:p | tei:head">
        <xsl:value-of select="concat('&lt;',local-name(.),'&gt;&#10;')"/>
        <xsl:apply-templates/>
        <xsl:value-of select="concat('&lt;/',local-name(.),'&gt;&#10;')"/>
    </xsl:template>
    
    <xsl:template match="tei:w|tei:pc">
        <xsl:value-of select="concat(.,'&#10;')"/>
    </xsl:template>
</xsl:stylesheet>