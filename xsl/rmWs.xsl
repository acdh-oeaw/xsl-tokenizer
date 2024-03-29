<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" 
    xmlns="http://acdh.oeaw.ac.at/xtoks"
    exclude-result-prefixes="#all"
    version="2.0">
    
    
    <!-- 
        This stylesheet is used to remove any whitespace from a tokenized document or vertical output with token-namespace='toks'.
        For the output of the tei-version, the whitespace handling is implemented in xtoks2tei.xsl. 
    -->
    <xsl:template match="/" mode="rmWs">
        <xsl:if test="$debug != ''">
            <xsl:message>rmWs.xsl</xsl:message>
        </xsl:if>
        <xsl:apply-templates mode="rmWs"/>
    </xsl:template>
    <xsl:template match="node() | @*" mode="rmWs">
        <xsl:copy inherit-namespaces="no">
            <xsl:apply-templates select="node() | @*"  mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xtoks:ws" mode="rmWs"/>
    <xsl:template match="xtoks:w | xtoks:pc" mode="rmWs">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
        <xsl:if test="exists(following-sibling::*[1][not(self::xtoks:ws)])">
            <g/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>