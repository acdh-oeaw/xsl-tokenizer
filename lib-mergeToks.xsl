<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 25, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p>merges interrupted tokens like 
                <tei:w part="I">Inter-</tei:w>
                <tei:w part="F">ruption</tei:w>
            but takes also into account special cases where such sequences are nested:
                <tei:w part="I">Inter-</tei:w>
                    <tei:floatingText>
                        <tei:w part="I">Some</tei:w>
                        <tei:w part="F">thing</tei:w>
                    </tei:floatingText>
                <tei:w part="F">ruption</tei:w>
            </xd:p>
        </xd:desc>
    </xd:doc>


    <xsl:template match="tei:w[@part]" mode="groupByInitialPart">
        <xsl:copy-of select="."/>
    </xsl:template>


    <xsl:template name="mergeTokens">
        <xsl:param name="partialTokens" as="element(tei:w)*"/>
        <!-- first we group by @part='I' -->
        <xsl:variable name="groups-initial">
            <xsl:for-each-group select="$partialTokens" group-starting-with=".[@part='I']">
                <group n="{position()}">
                    <xsl:apply-templates select="current-group()" mode="groupByInitialPart"/>
                </group>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="groups-final" as="item()*">
            <xsl:apply-templates select="$groups-initial" mode="groupByFinalPart"/>
        </xsl:variable>
        <xsl:call-template name="merge-segs">
            <xsl:with-param name="segs" select="$groups-final"/>
        </xsl:call-template>
    </xsl:template>
    

    <xsl:template match="group" mode="groupByFinalPart">
            <xsl:for-each-group select="tei:w[@part]" group-ending-with=".[@part='F']">
                    <xsl:choose>
                        <xsl:when test="current-group()/@part='F' and current-group()/@part='I'">
                            <tei:seg><xsl:sequence select="current-group()"/></tei:seg>
                        </xsl:when>
                        <xsl:when test="current-group()/self::tei:w[@part='F']">
                            <tei:seg part="F">
                                <xsl:sequence select="current-group()"/>    
                            </tei:seg>
                        </xsl:when>
                        <xsl:otherwise>
                            <tei:seg part="I">
                                <xsl:sequence select="current-group()"/>    
                            </tei:seg>
                        </xsl:otherwise>
                    </xsl:choose>
            </xsl:for-each-group>
    </xsl:template>
    
    
    <xsl:template name="merge-segs">
        <xsl:param name="segs" as="item()*"/>
        <xsl:choose>
            <xsl:when test="not($segs)"/>
            <xsl:when test="$segs[1]/not(@part)">
                <tei:seg type="token">
                    <xsl:sequence select="$segs[1]/*"/>
                </tei:seg>
                <xsl:call-template name="merge-segs">
                    <xsl:with-param name="segs" select="$segs except $segs[1]"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <tei:seg type="token">
                    <xsl:sequence select="$segs[1]/*"/>
                    <xsl:sequence select="$segs[@part='F'][1]/*"/>
                </tei:seg>
                <xsl:call-template name="merge-segs">
                    <xsl:with-param name="segs" select="$segs except ($segs[1],$segs[@part='F'][1])"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
