<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 22, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p>Remove any namespace...</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output exclude-result-prefixes="#all" method="xml" media-type="text/xml" indent="no" omit-xml-declaration="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[namespace-uri(.) != '']">
        <xsl:element name="{local-name(.)}" namespace="">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>


</xsl:stylesheet>
