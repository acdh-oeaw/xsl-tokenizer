<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei xtoks"
    xmlns="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <xsl:include href="classify.xsl"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@* | comment() | processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>


    <!--<xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>-->
    <xsl:template match="*">
        <xsl:choose>
            <xsl:when test="xtoks:is-copy-node(.)">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="xtoks:is-ignore-node(.)">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="mode">ignore</xsl:attribute>
                    <!--<xsl:apply-templates/>-->
                    <xsl:copy-of select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="xtoks:is-floating-node(.)">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="mode">float</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="xtoks:is-inline-node(.)">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="mode">inline</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:param name="mode"/>
        <xsl:choose>
            <xsl:when test="$mode = ('ignore','copy')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="tokenize-text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
