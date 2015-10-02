<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="user-params.xsl"/>
    <xsl:param name="preserve-ws" select="true()"/>
    <xsl:param name="ws-regex" select="'\s+'"/>
    <xsl:param name="pc-regex" select="'\p{P}+'"/>
    
</xsl:stylesheet>