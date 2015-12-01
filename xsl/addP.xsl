<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="tei:seg"/>
    <xsl:output indent="yes"></xsl:output>
    
    <xsl:key name="token-by-id" match="tei:w|tei:pc|tei:seg" use="@xml:id"/>
    <xsl:key name="first-lex-token-by-reference" match="tei:w[@next-by-lex]" use="tokenize(@next-by-lex,' ')"/>
    
    
    <xsl:template match="/">
        <xsl:variable name="ids-added">
            <xsl:if test="$debug = ('yes','addP')">
                <xsl:message>Run "add-ids"</xsl:message>
            </xsl:if>
            <xsl:apply-templates mode="add-ids"/>
        </xsl:variable>
        <xsl:variable name="floats">
            <xsl:if test="$debug = ('yes','addP')">
                <xsl:message>Run "floats"</xsl:message>
            </xsl:if>
            <xsl:sequence select="$ids-added//*[@mode='float']"/>
        </xsl:variable>
        <xsl:variable name="flatten" as="item()*">
            <xsl:if test="$debug = ('yes','addP')">
                <xsl:message>Run "flatten"</xsl:message>
            </xsl:if>
            <xsl:document>
                <xsl:apply-templates select="$ids-added" mode="flatten"/>
                <xsl:apply-templates select="$floats" mode="flattenFloats"/>
            </xsl:document>
        </xsl:variable>
        
        <xsl:variable name="partsTagged" as="document-node()*">
            <xsl:if test="$debug = ('yes','addP')">
                <xsl:message>Run "group"</xsl:message>
            </xsl:if>
            <xsl:document>
                <xsl:apply-templates select="$flatten" mode="group"/>
            </xsl:document>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$useLexicon = 'true' and $lexToks//*">
                
                <xsl:variable name="lexApplied" as="document-node()">
                    <xsl:if test="$debug = ('yes','addP')">
                        <xsl:message>Run "apply-lex"</xsl:message>
                    </xsl:if>
                    <xsl:document>
                        <xsl:apply-templates select="$partsTagged" mode="apply-lex"/>
                    </xsl:document>
                </xsl:variable>
                
                <xsl:variable name="lexPartsAdded" as="document-node()">
                    <xsl:if test="$debug = ('yes','addP')">
                        <xsl:message>Run "add-lex-parts"</xsl:message>
                    </xsl:if>
                    <xsl:document>
                        <xsl:apply-templates select="$lexApplied" mode="add-lex-parts"/>
                    </xsl:document>
                </xsl:variable>
                
                <xsl:if test="$debug = ('yes','addP')">
                    <xsl:message>Run "add-p"</xsl:message>
                </xsl:if>
                <xsl:apply-templates select="$ids-added" mode="addP">
                    <xsl:with-param name="grouped" select="$lexPartsAdded" as="document-node()" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$debug = ('yes','addP')">
                    <xsl:message>Run "add-p"</xsl:message>
                </xsl:if>
                <xsl:apply-templates select="$ids-added" mode="addP">
                    <xsl:with-param name="grouped" select="$partsTagged" as="document-node()" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="sum">
        <xsl:param name="bag" as="item()*"/>
        <xsl:param name="entry" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="string-join($bag,'') = $entry">
                <xsl:sequence select="$bag"/>
            </xsl:when>
            <xsl:when test="contains($entry, string-join($bag,''))">
                <xsl:call-template name="sum">
                    <xsl:with-param name="entry" select="$entry"/>
                    <xsl:with-param name="bag" select="(($bag,$bag[last()]/following-sibling::*[1]))" as="item()*"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[some $x in $lexToks//tei:entry satisfies starts-with($x, .)]" mode="apply-lex">
        <xsl:variable name="w" select="." as="element()"/>
        <xsl:variable name="entry-length" select="string-length($lexToks)" as="xs:integer"/>
        <xsl:variable name="next" select="subsequence(following-sibling::*, 1, $entry-length)" as="item()*"/>
        <xsl:variable name="candidates" select="$lexToks//tei:entry[starts-with(string-join(($w,$next),''),.)]" as="item()*"/>
        <xsl:choose>
            <xsl:when test="$candidates">
                <xsl:variable name="entries" as="element()*">
                    <xsl:for-each select="$candidates">
                        <xsl:variable name="sum" as="item()*">
                            <xsl:call-template name="sum">
                                <xsl:with-param name="entry" select="." as="xs:string"/>
                                <xsl:with-param name="bag" select="$w" as="item()"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="exists($sum)">
                            <xsl:element name="next-by-lex" namespace="">
                                <xsl:attribute name="lex_entry" select="./@xml:id"/>
                                <xsl:attribute name="entry" select="."/>
                                <xsl:value-of select="string-join(subsequence($sum,2)/@xml:id, ' ')"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="$entries">
                        <xsl:copy-of select="$entries[1]/@lex_entry"/>
                        <xsl:attribute name="next-by-lex" select="$entries[1]"/>
                    </xsl:if>
                    <xsl:copy-of select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[@next-by-lex and @lex_entry]" mode="add-lex-parts">
        <xsl:copy>
            <xsl:copy-of select="@* except (@next-by-lex|@lex_entry|@part|@prev|@next)"/>
            <!-- may be part of an split abbreviation -->
            <xsl:attribute name="part" select="if (@part = ('F','M')) then 'M' else 'I'"/>
            <xsl:attribute name="next" select="concat('#',tokenize(@next-by-lex,' ')[1])"/>
            <xsl:if test="@part = ('F','M')">
                <xsl:copy-of select="@prev"/>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[key('first-lex-token-by-reference', @xml:id)]" mode="add-lex-parts" priority="1">
        <xsl:variable name="id" select="@xml:id" as="xs:string"/>
        <xsl:variable name="first-lex-tokens" select="key('first-lex-token-by-reference', $id)" as="item()+"/>
        <xsl:if test="count($first-lex-tokens) gt 1">
            <xsl:message>ID: <xsl:value-of select="$id"/></xsl:message>
            <xsl:message>
                <xsl:copy-of select="$first-lex-tokens"/>
            </xsl:message>
            <xsl:message>=========</xsl:message>
        </xsl:if>
        <xsl:variable name="first-lex-token" select="($first-lex-tokens)[1]" as="item()"/>
        <xsl:variable name="all-lex-tokens" as="text()*">
            <xsl:for-each select="tokenize($first-lex-token/@next-by-lex,' ')">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="pos" select="index-of($all-lex-tokens, $id)" as="xs:integer"/>
        <xsl:variable name="next-id" select="subsequence($all-lex-tokens, $pos+1, 1)"/>
        <xsl:variable name="prev-id" select="if ($pos = 1) then $first-lex-token/@xml:id else subsequence($all-lex-tokens,xs:integer($pos) - 1, 1)"/>
        <xsl:variable name="part" select="if ($pos lt count($all-lex-tokens)) then 'M' else 'F'"/>
        <xsl:copy>
            <xsl:if test="$pos lt count($all-lex-tokens)">
                <xsl:attribute name="next" select="concat('#', $next-id)"/>
            </xsl:if>
            <xsl:attribute name="prev" select="concat('#', $prev-id)"/>
            <xsl:attribute name="part" select="$part"/>
            <xsl:copy-of select="@* except (@prev|@next|@part)|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="node() | @*" mode="apply-lex add-lex-parts">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    <xsl:template match="/" mode="group">
        <xsl:for-each-group select="*" group-adjacent="local-name(.)">
            <xsl:choose>
                <xsl:when test="count(current-group()[self::tei:w]) > 1">
                    <xsl:for-each select="current-group()">
                        <xsl:variable name="part">
                            <xsl:choose>
                                <xsl:when test="position() = 1">I</xsl:when>
                                <xsl:when test=". is current-group()[last()]">F</xsl:when>
                                <xsl:otherwise>M</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="prev" select="preceding-sibling::*[1]/@xml:id"/>
                        <xsl:variable name="next" select="following-sibling::*[1]/@xml:id"/>
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:attribute name="part" select="$part"/>
                            <xsl:if test="position() > 1">
                                <xsl:attribute name="prev">#<xsl:value-of select="$prev"/></xsl:attribute>
                            </xsl:if>
                            <xsl:if test="not(. is current-group()[last()])">
                                <xsl:attribute name="next">#<xsl:value-of select="$next"/></xsl:attribute>
                            </xsl:if>
                            <xsl:copy-of select="node()"/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="current-group()[not(self::tei:break)]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="tei:w|tei:pc|tei:seg[@type='ws']" priority="1" mode="add-ids">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="add-ids">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:w|tei:pc|tei:seg[@type = 'ws']" mode="flatten flattenFloats" priority="1">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="*[not(@mode) or @mode = 'copy']" mode="flatten flattenFloats">
        <break/><xsl:apply-templates mode="#current"/><break/>
    </xsl:template>
    
    <xsl:template match="*[@mode = 'float']" mode="flatten"/>
    
    <xsl:template match="*[@mode = 'ignore']" mode="flatten flattenFloats"/>
    
    <xsl:template match="*[@mode = 'inline']" mode="flatten flattenFloats">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="addP">
        <xsl:choose>
            <xsl:when test="@mode|descendant::tei:w|descendant::tei:pc">
                <xsl:copy>
                    <xsl:apply-templates select="node() | @* except @mode" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:w|tei:pc|tei:seg[@type = 'ws']" mode="addP">
        <xsl:param name="grouped" tunnel="yes" as="document-node()+"/>
        <xsl:variable name="w" select="key('token-by-id', @xml:id, $grouped)"/>
        <xsl:copy>
            <xsl:if test="exists($w)">
                <xsl:copy-of select="$w/@xml:id|$w/@part|$w/@next|$w/@prev"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    <xsl:template name="splitCollapsed">
        <xsl:param name="parts" as="element()*" required="yes"/>
        <xsl:param name="lex-entry" as="xs:string" tunnel="yes" required="yes"/>
        <xsl:param name="results" as="element()*" required="no"/>
        <xsl:choose>
            <xsl:when test="count($parts) = 0">
                <xsl:sequence select="$results"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="splitCollapsed">
                    <xsl:with-param name="parts" select="$parts[position() gt 1]"/>
                    <xsl:with-param name="results" as="item()*">
                        <xsl:variable name="parts1-id" select="($parts[1]/@orig-id,$parts/parent::*/@collapsed-id)[1]"/>
                        <xsl:sequence select="$results"/>
                        <xsl:element name="{name($parts[1])}" namespace="{namespace-uri($parts[1])}">
                            <xsl:attribute name="xml:id" select="$parts1-id"/>
                            <xsl:attribute name="part">
                                <xsl:choose>
                                    <xsl:when test="count($results) = 0 and starts-with($lex-entry,string-join(($results,$parts[1]),''))">I</xsl:when>
                                    <xsl:when test="ends-with($lex-entry,string-join(($results,$parts[1]),''))">F</xsl:when>
                                    <xsl:otherwise>M</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:if test="count($results) > 0">
                                <xsl:attribute name="prev" select="concat('#',$results[last()]/@xml:id)"/>
                            </xsl:if>
                            <xsl:if test="count($parts) > 1">
                                <xsl:attribute name="next" select="concat('#',$parts[2]/@orig-id)"/>
                            </xsl:if>
                            <xsl:copy-of select="$parts[1]/node()"/>
                        </xsl:element>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
</xsl:stylesheet>