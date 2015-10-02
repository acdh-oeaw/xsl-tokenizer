<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:param name="path-to-lexicon">lexicon.txt</xsl:param>
    
    <xsl:variable name="lexicon" as="xs:string*">
        <xsl:for-each select="tokenize(unparsed-text($path-to-lexicon),'\n')">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="lexiconEscpd" as="xs:string*">
        <xsl:for-each select="$lexicon">
            <xsl:variable name="parts" as="xs:string*">
                <xsl:analyze-string select="." regex="[\.\$\^\[\]\(\)\-\{{\}}\|\*\+\?\\]">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat('\',.)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:value-of select="string-join($parts,'')"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="lexiconEscpdRegex" select="concat('(',string-join($lexiconEscpd,'|'),')')"/>
    
    <xsl:template match="/">
        <xsl:if test="not(unparsed-text-available($path-to-lexicon))">
            <xsl:message>Lexicon not available.</xsl:message>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[some $t in $lexicon satisfies contains(xs:string(.),$t)]">
        <xsl:choose>
            <xsl:when test="*[some $t in $lexicon satisfies contains(.,$t)]">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="this" select="." as="element()"/>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:analyze-string select="." regex="{$lexiconEscpdRegex}">
                        <xsl:matching-substring>
                            <abbr>
                                <xsl:value-of select="."/>
                            </abbr>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>