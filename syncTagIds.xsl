<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 7, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p>Replaces the xml:ids of the source document by those in another list of
                corresponding w-tags (matched on position() + text()).</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="path-to-doc-with-new-ids" as="xs:string" required="yes"/>
    <xsl:variable name="new-ids" as="item()" select="doc($path-to-doc-with-new-ids)"/>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/TEI|/tei:TEI">
        <xsl:choose>
            <xsl:when test="not(exists($new-ids/*))">
                <xsl:message>Document at <xsl:value-of select="$path-to-doc-with-new-ids"/> empty or not available.</xsl:message>
            </xsl:when>
            <xsl:when test="count(($new-ids//tei:w,$new-ids//w)) != count((//tei:w,//w))">
                <xsl:message>Unequal length of files:</xsl:message>
                <xsl:message><xsl:value-of select="count(($new-ids//tei:w,$new-ids//w))"/> w-tags at <xsl:value-of select="$path-to-doc-with-new-ids"/></xsl:message>
                <xsl:message><xsl:value-of select="count((//tei:pc,//tei:w,//w))"/> w-tags at input document.</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="tei:w|w">
                        <xsl:variable name="position" as="xs:integer">
                            <xsl:number/>
                        </xsl:variable>
                        <xsl:variable name="newID" select="($new-ids/TEI/w[position() eq $position]/@xml:id|$new-ids/tei:TEI/tei:w[position() eq $position]/@xml:id)[1]"/>
                        <xsl:choose>
                            <xsl:when test="not(exists($newID))">
                                <xsl:message>No w-tag found in <xsl:value-of select="$path-to-doc-with-new-ids"/> at position <xsl:value-of select="$position"/>.</xsl:message> 
                            </xsl:when>
                            <xsl:when test="text() eq $newID/parent::*/text()">
                                <xsl:copy>
                                    <xsl:copy-of select="$newID"/>
                                    <xsl:copy-of select="@* except @xml:id"/>
                                    <xsl:value-of select="."/>
                                </xsl:copy>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>ERROR: Vertical lists are not corresponding: </xsl:message>
                                <xsl:message>tag at position <xsl:value-of select="$position"/> ("<xsl:value-of select="text()"/>") does not match with tag at the same position ("<xsl:value-of select="$newID/parent::*/text()"/>")</xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
       </xsl:template>


</xsl:stylesheet>
