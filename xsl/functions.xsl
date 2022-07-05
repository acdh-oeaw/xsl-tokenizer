<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei xtoks" version="2.0">
    
    
    <xsl:function name="xtoks:rmnl">
        <xsl:param name="input" as="document-node()"/>
        <xsl:apply-templates select="$input" mode="rmnl"/>
    </xsl:function>
    
    <xsl:template name="xtoks:tokenize">
        <xsl:param name="input" as="document-node()"/>
        <xsl:param name="token-namespace" select="$token-namespace"/>
        <xsl:param name="preserve-ws" select="$preserve-ws"/>
        <xsl:message>xtoks:tokenize</xsl:message>
        <xsl:message select="concat('$token-namespace=',$token-namespace)"/>
        <xsl:message select="concat('$preserve-ws=',$preserve-ws)"/>
        
        <xsl:variable name="nlRmd" select="xtoks:rmnl($input)"/>
        <xsl:variable name="tokenized" as="document-node()">
            <xsl:document>
                <xsl:apply-templates select="$nlRmd" mode="tokenize"/>
            </xsl:document>    
        </xsl:variable>
        
        <xsl:variable name="pAdded" as="document-node()">
            <xsl:document>
                <xsl:apply-templates select="$tokenized" mode="addP"/>
            </xsl:document>    
        </xsl:variable>
        <xsl:variable name="postProcessed" select="xtoks:applyPostProcessingXSLTs($pAdded)"/>
        <xsl:choose>
            <xsl:when test="$token-namespace = 'xtoks' and $preserve-ws = 'true'">
                <xsl:sequence select="$postProcessed"/>
            </xsl:when>
            <xsl:when test="$token-namespace = 'xtoks' and $preserve-ws = 'false'">
                <xsl:apply-templates select="$postProcessed" mode="rmWs"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$postProcessed" mode="xtoks2tei"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    
    <xsl:template name="xtoks:vert-xml">
        <xsl:param name="input" as="document-node()"/>
        <xsl:param name="token-namespace" select="$token-namespace"/>
        <xsl:param name="preserve-ws" select="$preserve-ws"/>
        <xsl:message select="concat('$preserve-ws=',$preserve-ws)"/>
        <xsl:message select="concat('$token-namespace=',$token-namespace)"/>
        <xsl:variable name="toks">
            <xsl:call-template name="xtoks:tokenize">
                <xsl:with-param name="input" select="$input"/>
                <xsl:with-param name="token-namespace">xtoks</xsl:with-param>
                <xsl:with-param name="preserve-ws">true</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
      
        <xsl:variable name="vert">
            <xsl:apply-templates select="$toks" mode="xtoks2vert"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$token-namespace = 'xtoks' and $preserve-ws = 'true'">
                <xsl:sequence select="$vert"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$toks" mode="xtoks2tei"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="xtoks:vert-txt">
        <xsl:param name="input" as="document-node()"/>
        <xsl:variable name="vert-xml">
            <xsl:call-template name="xtoks:vert-xml">
                <xsl:with-param name="input" select="$input"/>
                <xsl:with-param name="token-namespace">xtoks</xsl:with-param>
                <xsl:with-param name="preserve-ws">true</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:apply-templates select="$vert-xml" mode="vert2txt"/>
    </xsl:template>
    
    
</xsl:stylesheet>
