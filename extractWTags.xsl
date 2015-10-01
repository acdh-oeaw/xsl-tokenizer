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
    
    <xsl:include href="lib-mergeToks.xsl"/>
    <!-- put w-elements into TEI-namespace or not ? -->
    <xsl:param name="namespaced" as="xs:boolean">0</xsl:param>
    
    <xsl:param name="revision" select="@revision"/>
    
    <xsl:variable name="tokensMerged" as="element(tei:seg)*">
        <xsl:call-template name="mergeTokens">
            <xsl:with-param name="partialTokens" select="//tei:w[@part]"/>
        </xsl:call-template>
    </xsl:variable>
    
    
    <xsl:template match="/*">
        <xsl:result-document href="wtags-report.xml">
            <debug xmlns:tei="http://www.tei-c.org/ns/1.0" lastrun="{current-dateTime()}">
                <info>
                    <source>
                        <w-tags-total><xsl:value-of select="count(//tei:w)"/></w-tags-total>
                        <initial-w-tags><xsl:value-of select="count(//tei:w[@part='I'])"/></initial-w-tags>
                        <final-tags><xsl:value-of select="count(//tei:w[@part='F'])"/></final-tags>
                        <midde-tags><xsl:value-of select="count(//tei:w[@part='M'])"/></midde-tags>
                    </source>
                    <merged>
                        <w-tags-total><xsl:value-of select="count($tokensMerged//tei:w)"/></w-tags-total>
                        <initial-w-tags><xsl:value-of select="count($tokensMerged//tei:w[@part='I'])"/></initial-w-tags>
                        <final-tags><xsl:value-of select="count($tokensMerged//tei:w[@part='F'])"/></final-tags>
                        <midde-tags><xsl:value-of select="count($tokensMerged//tei:w[@part='M'])"/></midde-tags>
                    </merged>
                </info>
                <report>
                    <watchme>
                        <xsl:for-each select="//tei:w[@part='I' and not(following-sibling::*[1][descendant-or-self::tei:w/@part = ('M','F')])]">
                            <initials>
                                <xsl:sequence select="(.,following-sibling::*[1])"/>
                            </initials>
                        </xsl:for-each>
                    </watchme>
                    <errors>
                        <xsl:sequence select="$tokensMerged/self::tei:seg[not(exists(tei:w[@part='I']) or exists(tei:w[@part='F']))]"/>
                    </errors>
                </report>
                <tokens>
                    <xsl:sequence select="$tokensMerged"/>
                </tokens>
            </debug>
        </xsl:result-document>
        <xsl:choose>
            <xsl:when test="$namespaced">
                <xsl:copy>
                    <xsl:attribute name="last-update" select="current-dateTime()"/>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{local-name(.)}" namespace="">
                    <xsl:attribute name="last-tokenized" select="current-dateTime()"/>
                    <xsl:attribute name="revision" select="$revision"/>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()"/>

    <xsl:template match="tei:w[@part='I']">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="parts" select="$tokensMerged[tei:w/@xml:id=$id]/tei:w" as="element(tei:w)*"/>
        <xsl:element name="w" namespace="{if($namespaced) then 'http://www.tei-c.org/ns/1.0' else ''}">
            <xsl:copy-of select="@* except @part"/>
            <xsl:value-of select="string-join($parts/text(),'')"/>
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
