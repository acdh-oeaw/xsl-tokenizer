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
    <xsl:param name="namespaced" as="xs:boolean">0</xsl:param>
    
    <xsl:template match="/*">
        <xsl:choose>
            <xsl:when test="$namespaced">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{local-name(.)}" namespace="">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
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
        <xsl:element name="w" namespace="{if($namespaced) then 'http://www.tei-c.org/ns/1.0' else ''}">
            <xsl:copy-of select="@* except @part"/>
            <xsl:value-of select="concat(.,string-join(($middle,$final),''))"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:w[not(@part)]">
        <xsl:if test="$namespaced">
            <xsl:copy-of select="."/>
        </xsl:if>
        <xsl:if test="not($namespaced)">
            <xsl:element name="w" namespace="">
                <xsl:if test="*">
                    <xsl:message>ACHTUNG w-tag "<xsl:value-of select="."/>" (ID <xsl:value-of select="@xml:id"/>) hat Kind-Element(e) <xsl:value-of select="string-join(for $x in * return concat('''',local-name($x),''''),', ')"/>.</xsl:message>
                </xsl:if>
                <xsl:copy-of select="@*|text()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:pc" exclude-result-prefixes="#all">
        <xsl:element name="w" namespace="{if ($namespaced) then 'http://www.tei-c.org/ns/1.0' else ''}">
            <xsl:copy-of select="@*|text()|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:apply-templates select="*"/>
    </xsl:template>

</xsl:stylesheet>
