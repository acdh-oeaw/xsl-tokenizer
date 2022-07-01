<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="xtoks:seg xtoks:w xtoks:pc"/>
    <xsl:key name="tag-by-id" match="xtoks:*" use="@xml:id"/>
    <!-- either "xtoks" (output xtoks:w) or "tei" (output tei:w) -->
    <!-- IMPORTANT: if you want to create a text vertical out of this xml vertical, 
        make sure to set $token-namespace to 'xtoks'
        as vert2txt.xsl relies on that.
    -->
    <xsl:param name="token-namespace">tei</xsl:param>
    
    <xsl:template match="/">
        <xsl:variable name="part-i" select="count(//xtoks:*[@part = 'I'])"/>
        <xsl:variable name="part-f" select="count(//xtoks:*[@part = 'F'])"/>
        <xsl:if test="$part-i != $part-f">
            <xsl:message terminate="yes">Unequal number of partial tokens: <xsl:value-of select="$part-i"/> inital, <xsl:value-of select="$part-f"/> final parts</xsl:message>
        </xsl:if>
        <xsl:if test="$debug != 'no'">
            <xsl:message>Debug level: <xsl:value-of select="$debug"/>
            </xsl:message>
        </xsl:if>
        <xsl:variable name="vert">
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
                        <xsl:variable name="tokenStream">
                            <xsl:apply-templates mode="extractTokens"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="every $i in $tokenStream/* satisfies namespace-uri($i) = 'http://acdh.oeaw.ac.at/xtoks'">
                                <ab>
                                    <xsl:sequence select="$tokenStream"/>
                                </ab>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$tokenStream"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </body>
                </text>
            </TEI>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$token-namespace = 'tei'">
                <xsl:apply-templates select="$vert" mode="xtoks2tei"/>
            </xsl:when>
            <xsl:when test="$token-namespace = 'xtoks'">
                <xsl:sequence select="$vert"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">xtoks2vert.xsl: unknown value $token-namespace = '<xsl:value-of select="$token-namespace"/>' Falling back to 'xtoks'.</xsl:message>
                <xsl:sequence select="$vert"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    <xsl:template match="text() | @*" mode="doc-attributes"/>
    <xsl:template match="*" mode="doc-attributes">
        <xsl:apply-templates select="@*|*" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*" mode="extractTokens">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="xtoks:w|xtoks:seg[@type = 'ws']|xtoks:pc" mode="extractTokens">
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
    <xsl:template match="text()[not(parent::xtoks:w) or not(parent::xtoks:seg)]" mode="extractTokens"/>
    
    <xsl:template match="node() | @*" mode="xtoks2tei">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xtoks:seg[@type = 'ws']" mode="xtoks2tei"/>
    <xsl:template match="xtoks:pc" mode="xtoks2tei">
        <xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="xtoks:w" mode="xtoks2tei">
        <xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:if test="exists(following-sibling::*[1][not(self::xtoks:seg[@type='ws'])])">
                <xsl:attribute name="join">right</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>