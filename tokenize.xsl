<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="tokenizer.xsl"/>
	<xsl:import href="wrap.xsl"/>
	<xsl:import href="whitespace.xsl"/>
	<xsl:import href="parameters.xsl"/>

	<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/" mode="#default">
		<xsl:variable name="wTagsAdded">
			<xsl:apply-templates mode="makeWTags" select="."/>
		</xsl:variable>
		<!--<xsl:choose>
         <xsl:when test="$purgeWhitespace">
            <xsl:apply-templates select="$wTagsAdded" mode="purgeWhitespace"/>
         </xsl:when>
         <xsl:when test="$purgeNewlineonlyWhitespaceTags">
            <xsl:apply-templates select="$wTagsAdded" mode="purgeNewlineonlyWhitespaceTags"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$wTagsAdded"/>
         </xsl:otherwise>
      </xsl:choose>-->
		<xsl:sequence select="$wTagsAdded"/>
	</xsl:template>


	<xsl:template match="tei:fw" mode="textvalue"/>

	<xsl:template match="tei:fw" mode="tokenize" priority="1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="fw" mode="textvalue"/>

	<xsl:template match="fw" mode="tokenize" priority="1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="tei:pb" mode="textvalue"/>

	<xsl:template match="tei:pb" mode="tokenize" priority="1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="pb" mode="textvalue"/>

	<xsl:template match="pb" mode="tokenize" priority="1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="tei:seg[@type=('header','footer')]" mode="textvalue"/>

	<xsl:template match="tei:seg[@type=('header','footer')]" mode="tokenize" priority="1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="seg[@type='header' or @type='footer']" mode="textvalue"/>

	<xsl:template match="seg[@type='header' or @type='footer']" mode="tokenize" priority="1">
		<xsl:copy-of select="."/>
	</xsl:template>


	<xsl:template match="node()[ancestor::fw]" mode="textvalue" priority="1"/>


	<xsl:template match="tei:milestone" mode="textvalue"/>

	<xsl:template match="tei:milestone" mode="tokenize" priority="1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="milestone" mode="textvalue"/>

	<xsl:template match="milestone" mode="tokenize" priority="1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template as="xs:boolean" match="tei:lb[@break='no']" mode="is-in-word-tag">
		<xsl:sequence select="true()"/>
	</xsl:template>

	<xsl:template as="xs:boolean" match="lb[@break='no']" mode="is-in-word-tag">
		<xsl:sequence select="true()"/>
	</xsl:template>

	<xsl:template as="xs:boolean" match="tei:seg" mode="is-in-word-tag">
		<xsl:sequence select="true()"/>
	</xsl:template>

	<xsl:template as="xs:boolean" match="seg" mode="is-in-word-tag">
		<xsl:sequence select="true()"/>
	</xsl:template>

</xsl:stylesheet>
