<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" 
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:param name="preserve-ws"/>
    <xsl:param name="debug"/>
    
    <xsl:template match="/">
        <xsl:if test="$debug != ''">
            <xsl:message select="concat('$preserve-ws=',$preserve-ws)"/>
        </xsl:if>
        <xsl:if test="not($preserve-ws = ('true','false'))">
            <xsl:message terminate="yes">$preserve-ws must be ('true', 'false'); provided value is "<xsl:value-of select="$preserve-ws"/>"</xsl:message>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy inherit-namespaces="no">
            <xsl:apply-templates select="node() | @*" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@xtoks:*">
        <xsl:attribute name="{if (local-name() = ('id','space','lang','base')) then 'xml:' else ''}{local-name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="xtoks:ws">
        <xsl:choose>
            <xsl:when test="$preserve-ws = 'true'">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xtoks:*">
        <xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="xtoks:w | xtoks:pc">
        <xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:if test="exists(following-sibling::*[1][not(self::xtoks:ws)])">
                <xsl:attribute name="join">right</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>