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
    <xsl:param name="namespaced" as="xs:boolean">0</xsl:param>
    
    <xsl:variable name="tokensMerged" as="element(tei:seg)*">
        <xsl:call-template name="mergeTokens">
            <xsl:with-param name="partialTokens" select="//tei:w[@part]"/>
        </xsl:call-template>
    </xsl:variable>
    
    
    <xsl:template match="/*">
        <xsl:result-document href="tokensMerged-debug.xml">
            <debug xmlns:tei="http://www.tei-c.org/ns/1.0">
                <info>
                    <w-tags-total><xsl:value-of select="count($tokensMerged//tei:w)"/></w-tags-total>
                    <initial-w-tags><xsl:value-of select="count($tokensMerged//tei:w[@part='I'])"/></initial-w-tags>
                    <final-tags><xsl:value-of select="count($tokensMerged//tei:w[@part='F'])"/></final-tags>
                    <midde-tags><xsl:value-of select="count($tokensMerged//tei:w[@part='M'])"/></midde-tags>
                </info>
                <xsl:sequence select="$tokensMerged"/>
            </debug>
        </xsl:result-document>
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
        <xsl:variable name="id" select="@xml:id"/>
        <!--<xsl:variable name="initial" select="." as="element(tei:w)"/>
        
        <!-\- TODO this could be optimized with a recursive function and signals -\->
        <!-\-<xsl:variable name="final" select="following::tei:w[@part = 'F'][some $i in preceding::tei:w[@part='I'] satisfies $i/following::tei:w[@part='I'][1]/position() lt $i/following::tei:w[@part='F'][1]/position()]"/>-\->
        <xsl:variable name="finalPosition" select="
            if (not(following::tei:w[@part='I'])) 
            then 1 
            else count(following::tei:w[@part='F'])-count(following::tei:w[@part='I'])+1" as="xs:integer"/>
        <xsl:variable name="final" select="following::tei:w[@part='F'][$finalPosition]"/>
        <xsl:message>$finalPosition <xsl:value-of select="$finalPosition"/></xsl:message>
        
        <!-\-<xsl:variable name="middle" select="
            if ($finalPosition eq 1) 
            then following::tei:w[@part = 'M'][some $x in following::tei:w[@part='F'] satisfies $x/@xml:id = $final/@xml:id]
            else ()" as="element(tei:w)*"/>-\->
        <xsl:variable name="middle" as="element(tei:w)*" select="$final/preceding::tei:w[@part='M'][preceding::tei:w[@part='I'][position() eq $finalPosition] is $initial]"/>
        <xsl:variable name="middle" as="element(tei:w)*">
            <xsl:for-each select="$final/preceding::tei:w[@part='M']">
                <xsl:variable name="initialPosition" select="
                    if(count(preceding::tei:w[@part='I'])=1) 
                    then 1
                    else "></xsl:variable>
            </xsl:for-each>
        </xsl:variable>
        <xsl:message>*initial*</xsl:message>
        <xsl:message select="."/>
        <xsl:if test="exists($middle)">
            <xsl:message select="'*middle*'"/>
            <xsl:message select="string-join($middle,'')"/>
        </xsl:if>
        <xsl:message select="'*final*'"/>
        <xsl:message select="$final"/>
        <xsl:message>-\-\-\-\-\-\-\-\-\-\-</xsl:message>-->
        <xsl:variable name="parts" select="$tokensMerged[tei:w/@xml:id=$id]/tei:w" as="element(tei:w)*"/>
        <xsl:message>*** partial token tei:w @xml:id='<xsl:value-of select="$id"/>' ***</xsl:message>
        <xsl:message select="text()"/>
        <xsl:if test="$parts[@part='M']">
<!--            <xsl:message> * middle *</xsl:message>-->
            <xsl:message select="string-join($parts[@part='M']/text(),'')"/>
        </xsl:if>
        <!--<xsl:message> ** final **</xsl:message>-->
        <xsl:message select="$parts[@part='F']/text()"/>
        <xsl:message/>
        
        <xsl:element name="w" namespace="{if($namespaced) then 'http://www.tei-c.org/ns/1.0' else ''}">
            <xsl:copy-of select="@* except @part"/>
            <!--<xsl:value-of select="concat(.,string-join(($middle,$final),''))"/>-->
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
