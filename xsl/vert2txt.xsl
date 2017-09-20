<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="text" indent="no"/>
    <xsl:strip-space elements="*"/>
    <xsl:function name="xtoks:structure">
        <xsl:param name="elt"/>
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="local-name($elt)"/>
        <xsl:for-each select="$elt/@*">
            <xsl:value-of select="concat(' ',local-name(.),'=','&quot;',data(.),'&quot;')"/>
        </xsl:for-each>
        <xsl:text>&gt;&#10;</xsl:text>
        <xsl:apply-templates select="$elt/*"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="local-name($elt)"/>
        <xsl:text>&gt;&#10;</xsl:text>
    </xsl:function>
    <xsl:template match="/">
        <xsl:text>&lt;doc&gt;&#10;</xsl:text>
        <xsl:apply-templates select="tei:TEI/tei:text/tei:body"/>
        <xsl:text>&lt;/doc&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="tei:seg[@type = 'ws']"/>
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:w|tei:pc">
        <xsl:value-of select="concat(normalize-space(.),'&#9;',@xml:id,'&#xA;')"/>
    </xsl:template>
</xsl:stylesheet>