<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei xtoks" version="2.0">
    <xsl:include href="toks-lib.xsl"/>
    
    <xsl:template match="/" mode="tokenize">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="@* | comment() | processing-instruction()" mode="tokenize">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*" mode="tokenize">
        <xsl:choose>
            <xsl:when test="xtoks:is-copy-node(.)">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="xtoks:is-ignore-node(.)">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="mode">ignore</xsl:attribute>
                    <xsl:copy-of select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="xtoks:is-floating-node(.)">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="mode">float</xsl:attribute>
                    <xsl:apply-templates mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="xtoks:is-inline-node(.)">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="mode">inline</xsl:attribute>
                    <xsl:apply-templates mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()" mode="tokenize">
        <xsl:param name="mode"/>
        <xsl:choose>
            <xsl:when test="$mode = ('ignore','copy')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="tokenize-text">
                    <xsl:with-param name="pc-regex" select="$pc-regex"/>
                    <xsl:with-param name="preserve-ws" select="$preserve-ws"/>
                    <xsl:with-param name="ws-regex" select="$ws-regex"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
</xsl:stylesheet>