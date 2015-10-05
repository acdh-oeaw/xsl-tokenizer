<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:template match="tei:teiHeader|tei:note[@place = 'below']" mode="is-copy-node">
        <xsl:sequence select="true()"/>
    </xsl:template>
    
    <xsl:template match="tei:fw" mode="is-ignore-node">
        <xsl:sequence select="true()"/>
    </xsl:template>
    
    
    <xsl:template match="tei:hi|tei:lb[@break = 'no']|tei:pb" mode="is-inline-node">
        <xsl:sequence select="true()"/>
    </xsl:template>
    
    
    <xsl:template match="tei:figure" mode="is-floating-node">
        <xsl:sequence select="true()"/>
    </xsl:template>
</xsl:stylesheet>