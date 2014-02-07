<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd" version="2.0">
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

    <xsl:template match="/TEI">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="w">
                <xsl:variable name="position" as="xs:integer">
                    <xsl:number/>
                </xsl:variable>
                <xsl:variable name="newID" select="$new-ids/TEI/w[position() eq $position]/@xml:id"/>
                <xsl:choose>
                    <xsl:when test="text() eq $newID/parent::w/text()">
                        <xsl:copy>
                            <xsl:copy-of select="$newID"/>
                            <xsl:copy-of select="@* except @xml:id"/>
                            <xsl:value-of select="."/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>ERROR: Vertical lists are not corresponding: </xsl:message>
                        <xsl:message>tag at position <xsl:value-of select="$position"/> ("<xsl:value-of select="text()"/>") does not match with tag at the same position ("<xsl:value-of select="$newID/parent::w/text()"/>")</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
       </xsl:template>


</xsl:stylesheet>
