<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="xtoks:seg xtoks:w xtoks:pc xtoks:ws"/>
    <xsl:key name="tag-by-id" match="xtoks:*" use="@xml:id"/>
    
    <xsl:template match="/" mode="xtoks2vert">
        <xsl:if test="$debug !=''">
            <xsl:message select="'xtoks2vert.xsl'"/>
        </xsl:if>    
        <xsl:variable name="part-i" select="count(//xtoks:*[@part = 'I'])"/>
        <xsl:variable name="part-f" select="count(//xtoks:*[@part = 'F'])"/>
        <xsl:if test="$part-i != $part-f">
            <xsl:message terminate="yes">Unequal number of partial tokens: <xsl:value-of select="$part-i"/> inital, <xsl:value-of select="$part-f"/> final parts</xsl:message>
        </xsl:if>
        <xsl:if test="$debug != 'no'">
            <xsl:message>Debug level: <xsl:value-of select="$debug"/>
            </xsl:message>
        </xsl:if>
        
        <TEI>
            <xsl:choose>
                <xsl:when test="exists(tei:TEI/tei:teiHeader)">
                    <xsl:sequence select="tei:TEI/tei:teiHeader"/>
                </xsl:when>
                <xsl:otherwise>
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>Automatically generated vertical</title>
                            </titleStmt>
                            <publicationStmt>
                                <p>Intermediate working data.</p>
                            </publicationStmt>
                            <sourceDesc>
                                <p>Born digital.</p>
                            </sourceDesc>
                        </fileDesc>
                    </teiHeader>
                </xsl:otherwise>
            </xsl:choose>
            <text>
                <body>
                    <xsl:apply-templates mode="doc-attributes"/>
                    <xsl:apply-templates mode="extractTokens"/>
                </body>
            </text>
        </TEI>        
    </xsl:template>
    <xsl:template match="text() | @*" mode="doc-attributes"/>
    <xsl:template match="*" mode="doc-attributes">
        <xsl:apply-templates select="@*|*" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*" mode="extractTokens">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="xtoks:w|xtoks:ws|xtoks:pc" mode="extractTokens">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="*[@part = 'I']" mode="extractTokens" priority="1">
        <xsl:variable name="next" select="key('tag-by-id', substring-after(@next, '#'))" as="node()?"/>
        <xsl:if test="$debug = 'no' and not($next)">
            <xsl:message terminate="yes">@next is empty or element not found for element <xsl:copy-of select="."/>
            </xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@* except (@part|@prev|@next)"/>
            <xsl:choose>
                <xsl:when test="$debug = 'xtoks2vert'">
                    <xsl:sequence select="."/>
                    <xsl:apply-templates select="$next" mode="getTokenCopy"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                    <xsl:apply-templates select="$next" mode="getTokenContent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*[@part = ('M', 'F')]" mode="extractTokens" priority="2"/>
    <xsl:template match="*[@part = 'M']" mode="getTokenContent">
        <xsl:variable name="next" select="key('tag-by-id', substring-after(@next, '#'))" as="node()?"/>
        <xsl:if test="not($next)">
            <xsl:message terminate="yes">@next is empty or not found for element <xsl:copy-of select="."/>
            </xsl:message>
        </xsl:if>
        <xsl:value-of select="."/>
        <xsl:apply-templates select="$next" mode="getTokenContent"/>
    </xsl:template>
    <xsl:template match="*[@part = 'M']" mode="getTokenCopy">
        <xsl:variable name="next" select="key('tag-by-id', substring-after(@next, '#'))" as="node()?"/>
        <xsl:sequence select="."/>
        <xsl:apply-templates select="$next" mode="getTokenCopy"/>
    </xsl:template>
    <xsl:template match="*[@part = 'F']" mode="getTokenContent">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="*[@part = 'F']" mode="getTokenCopy">
        <xsl:sequence select="."/>
    </xsl:template>
    <xsl:template match="text()[not(parent::xtoks:w) or not(parent::xtoks:ws)]" mode="extractTokens"/>
    
 
    
</xsl:stylesheet>
