<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsl:result-document">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="xsl:element[@name = 'xsl:stylesheet'][parent::xsl:result-document]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="xsl:attribute">
                <xsl:attribute name="name">xml:id</xsl:attribute>
                <xsl:value-of select="substring-before(tokenize(parent::*/@href,'/')[last()],'.xsl')"/>
            </xsl:element>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>