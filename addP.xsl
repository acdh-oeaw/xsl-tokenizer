<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output indent="yes"></xsl:output>
    
    <xsl:key name="w-by-id" match="tei:w" use="@xml:id"/>
    
    
    <xsl:include href="classify.xsl"/>
    
    <!-- convert dictionary to a sequence of tei:seg elements -->
    <xsl:param name="path-to-lexicon">lexicon.txt</xsl:param>
    
    <xsl:variable name="lexicon" as="xs:string*">
        <xsl:for-each select="tokenize(unparsed-text($path-to-lexicon),'\n')">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="lexToks" as="element(tei:seg)*">
        <xsl:for-each select="$lexicon">
            <seg xml:id="entry_{position()}" xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:call-template name="tokenize-text"/>
            </seg>
        </xsl:for-each>
    </xsl:variable>
    
    
    
    <xsl:template match="node() | @*" mode="add-ids rmIgnores correctInlines add-parts rmInlines rmModeAttrs applyLex">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[xtoks:is-inline-node(.)]" mode="lookaround">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:function name="xtoks:breaks">
        <xsl:param name="node" as="node()?"/>
        <xsl:sequence select="$node/descendant-or-self::tei:seg[@type = 'ws'] or $node/descendant-or-self::tei:pc or not($node/@mode = ('inline','ignore'))"/>
    </xsl:function>
    
    <xsl:template match="/">
        <xsl:comment><xsl:value-of select="current-dateTime()"/></xsl:comment>
        <xsl:variable name="ids-added" as="node()*">
            <xsl:apply-templates mode="add-ids"/>
        </xsl:variable>
        <xsl:variable name="ignoresRmd" as="node()*">
            <xsl:apply-templates mode="rmIgnores" select="$ids-added"/>
        </xsl:variable>
        <xsl:variable name="inlinesRmd" as="node()*">
            <xsl:apply-templates select="$ignoresRmd" mode="rmInlines"/>
        </xsl:variable>
        <xsl:variable name="partsTagged" as="node()*">
            <xsl:apply-templates select="$inlinesRmd" mode="tag-parts"/>
        </xsl:variable>
        
        <xsl:variable name="lexApplied" as="node()*">
            <xsl:apply-templates select="$partsTagged" mode="applyLex"/>
        </xsl:variable>
        
        <xsl:variable name="pAttrsAdded" as="node()*">
            <xsl:apply-templates select="$ids-added" mode="add-parts">
                <xsl:with-param name="pAttrsAdded" tunnel="yes" as="document-node()">
                    <xsl:document>
                        <xsl:sequence select="$lexApplied[not(self::processing-instruction())]"/>
                    </xsl:document>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:variable>
        
        <xsl:apply-templates select="$pAttrsAdded" mode="rmModeAttrs"/>
    </xsl:template>
    
    <xsl:template match="*" mode="add-ids" priority="1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="self::tei:seg[@type = 'ws']|self::tei:w|self::tei:pc">
                <xsl:attribute name="xml:id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@mode = ('ignore','float')]" mode="rmIgnores" priority="1"/>
    
    <xsl:template match="*[@mode = 'inline']/@mode" mode="correctInlines">
        <xsl:if test="not(xtoks:breaks(parent::*))">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[@mode = 'inline']" mode="rmInlines">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    
    
    <xsl:template match="node() | @*" mode="tag-parts">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:w" mode="tag-parts" priority="1">
        <xsl:variable name="part" as="xs:string?">
            <xsl:choose>
                <xsl:when test="preceding-sibling::*[1]/self::tei:w and following-sibling::*[1]/self::tei:w">M</xsl:when>
                <xsl:when test="not(preceding-sibling::*[1]/self::tei:w) and following-sibling::*[1]/self::tei:w">I</xsl:when>
                <xsl:when test="preceding-sibling::*[1]/self::tei:w and not(following-sibling::*[1]/self::tei:w)">F</xsl:when>
                <!--<xsl:when test="not(preceding-sibling::*[1]/self::tei:w and following-sibling::*[1]/self::tei:w)">NO</xsl:when>-->
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="$part != ''">
                <xsl:attribute name="part" select="$part"/>
                <xsl:if test="$part = 'I'">
                    <xsl:attribute name="next" select="concat('#',following-sibling::tei:w[1]/@xml:id)"/>
                </xsl:if>
                <xsl:if test="$part = 'M'">
                    <xsl:attribute name="prev" select="concat('#',preceding-sibling::tei:w[1]/@xml:id)"/>
                    <xsl:attribute name="next" select="concat('#',following-sibling::tei:w[1]/@xml:id)"/>
                </xsl:if>
                <xsl:if test="$part = 'F'">
                    <xsl:attribute name="prev" select="concat('#',preceding-sibling::tei:w[1]/@xml:id)"/>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:w[. = $lexToks//tei:w]" mode="applyLex" priority="1">
        <xsl:variable name="this" select="." as="node()"/>
        <xsl:variable name="segCandidats" select="$lexToks//tei:w[. = $this]/ancestor::tei:seg" as="element(tei:seg)*"/>
        <xsl:variable name="seg" as="node()*">
            <xsl:for-each select="$segCandidats">
                <!-- number of tokens in the lexicon entry -->
                <xsl:variable name="totalToks" select="count(*)"/>
                <!-- position of the current token in the lexicon-token -->
                <xsl:variable name="pos" select="*[. = $this]/position()" as="xs:integer"/>
                <entry id="{@xml:id}">
                    <toks-before><xsl:value-of select="if ($pos &lt;= 0) then 0 else xs:integer($pos) - 1"/></toks-before>
                    <toks-after><xsl:value-of select="xs:integer($totalToks)-(xs:integer($pos) + 1)"/></toks-after>
                </entry>
            </xsl:for-each>    
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="toks-after" select="$seg//toks-after"/>
            <xsl:attribute name="toks-before" select="$seg//toks-before"/>
            <xsl:if test="count($seg) >= 1">
                <xsl:variable name="toks-after" select="$seg//toks-after" as="xs:integer"/>
                <xsl:variable name="toks-before" select="$seg//toks-before" as="xs:integer"/>
                
                <xsl:choose>
                    <xsl:when test="$toks-before = 0 and $toks-after > 0">
                        <xsl:attribute name="part">I</xsl:attribute>
                        <xsl:attribute name="next" select="subsequence(($this/following::tei:w|$this/following::tei:pc|$this/following::tei:seg[@type = 'ws']),0,$toks-after)/@xml:id"/>
                    </xsl:when>
                    <xsl:when test="$toks-before > 0 and $toks-after > 0">
                        <xsl:attribute name="part">M</xsl:attribute>
                        <xsl:attribute name="next" select="subsequence(($this/following::tei:w|$this/following::tei:pc|$this/following::tei:seg[@type = 'ws']),0,$toks-after)/@xml:id"/>
                        <xsl:attribute name="prev" select="subsequence(($this/preceding::tei:w|$this/preceding::tei:pc|$this/preceding::tei:seg[@type = 'ws']),0,$toks-after)/@xml:id"/>
                    </xsl:when>
                    <xsl:when test="$toks-before > 0 and $toks-after = 0">
                        <xsl:attribute name="part">F</xsl:attribute>
                        <xsl:attribute name="prev" select="subsequence(($this/preceding::tei:w|$this/preceding::tei:pc|$this/preceding::tei:seg[@type = 'ws']),0,$toks-after)/@xml:id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="part">?</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
        
    
    
    <xsl:template match="tei:w" mode="add-parts" priority="1">
        <xsl:param name="pAttrsAdded" tunnel="yes" as="document-node()"/>
        <xsl:variable name="w-by-id" select="key('w-by-id', @xml:id, $pAttrsAdded)"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="$w-by-id/@part != ''">
                <xsl:copy-of select="$w-by-id/(@part|@next|@prev|@toks-after|@toks-before)"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@mode" mode="rmModeAttrs"/>
        
    
    
</xsl:stylesheet>