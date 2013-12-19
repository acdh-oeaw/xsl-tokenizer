<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    <xsl:output indent="yes" exclude-result-prefixes="#all"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 13, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()"/>

    <xsl:template match="tei:w[@part='I']">
        <xsl:variable name="final" select="(following::tei:w[@part = 'F'])[1]"/>
        <xsl:variable name="middle" select="following::tei:w[@part = 'M'][some $x in following::tei:w[@part='F'] satisfies $x/@xml:id eq $final/@xml:id]"/>
        <xsl:message>*initial*</xsl:message>
        <xsl:message select="."/>
        <xsl:if test="exists($middle)">
            <xsl:message select="'*middle*'"/>
            <xsl:message select="$middle"/>
        </xsl:if>
        <xsl:message select="'*final*'"/>
        <xsl:message select="$final"/>
        <xsl:message>-----------</xsl:message>
        <xsl:copy>
            <xsl:copy-of select="@* except @part"/>
            <xsl:value-of select="concat(.,string-join(($middle,$final),''))"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:w[not(@part)]">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="tei:pc" exclude-result-prefixes="#all">
        <tei:w>
            <xsl:copy-of select="@xml:id"/>
            <xsl:value-of select="."/>
        </tei:w>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:apply-templates select="*"/>
    </xsl:template>

</xsl:stylesheet>
