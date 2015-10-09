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
    <xsl:key name="collapsed-token-by-id" match="xtoks:token" use="substring-after(@corresp,'#')"/>
    <xsl:key name="lex-entry-by-part" match="tei:seg" use="(tei:w|tei:pc|tei:seg[@type = 'ws'])/normalize-space(.)"></xsl:key>
    
    <xsl:param name="debug" select="false()"/>
    <xsl:param name="debug-out" select="()"/>
    
    <xsl:template match="/">
        <xsl:variable name="ids-added">
            <xsl:apply-templates mode="add-ids"/>
        </xsl:variable>
        <xsl:variable name="floats">
            <xsl:sequence select="$ids-added//*[@mode='float']"/>
        </xsl:variable>
        <xsl:variable name="flatten" as="item()*">
            <xsl:document>
                <xsl:apply-templates select="$ids-added" mode="flatten"/>
                <xsl:apply-templates select="$floats" mode="flattenFloats"/>
            </xsl:document>
        </xsl:variable>
        
        <xsl:variable name="partsTagged" as="document-node()*">
            <xsl:document>
                <xsl:apply-templates select="$flatten" mode="group"/>
            </xsl:document>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$lexToks//*">
                <xsl:variable name="partsCollapsed" as="node()*">
                    <xsl:document>
                        <xsl:apply-templates select="$partsTagged" mode="collapseParts">
                            <xsl:with-param name="partsTagged" tunnel="yes" as="document-node()">
                                <xsl:document>
                                    <xsl:sequence select="$partsTagged[not(self::processing-instruction())]"/>
                                </xsl:document>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:document>
                </xsl:variable>
                
                <xsl:variable name="lexApplied" as="document-node()*">
                    <xsl:document><xsl:apply-templates select="$partsCollapsed" mode="applyLex"/></xsl:document>
                </xsl:variable>
                
                <xsl:variable name="lexAppliedRefsAdded" as="document-node()*">
                    <xsl:document><xsl:apply-templates select="$lexApplied" mode="addRefsToLexApplied"/></xsl:document>
                </xsl:variable>
                
                <xsl:variable name="collapsedExpanded" as="document-node()*">
                    <xsl:document><xsl:apply-templates select="$lexAppliedRefsAdded" mode="expandCollapsed"/></xsl:document>
                </xsl:variable>
                
                <xsl:variable name="nextAdded" as="document-node()*">
                    <xsl:document>
                        <xsl:apply-templates select="$collapsedExpanded" mode="addNext"/>
                    </xsl:document>
                </xsl:variable>
                
                <xsl:apply-templates select="$ids-added" mode="addP">
                    <xsl:with-param name="grouped" select="$nextAdded" as="document-node()" tunnel="yes"/>
                </xsl:apply-templates>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$ids-added" mode="addP">
                    <xsl:with-param name="grouped" select="$partsTagged" as="document-node()" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="applyLex addRefsToLexApplied addNext collapseParts expandCollapsed">
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
        <break/><xsl:apply-templates mode="#current"/>
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
    
    
    
    
    
    
    
    
    
    
    <xsl:template match="tei:*[key('lex-entry-by-part',normalize-space(.),$lexToks)]" mode="applyLex" priority="1">
        <xsl:variable name="token" select="." as="element()"/>
        <xsl:variable name="segCandidates" select="key('lex-entry-by-part',normalize-space(.),$lexToks)" as="node()*"/>
        <xsl:variable name="preceding" select="preceding::*[self::tei:w or self::tei:pc or self::tei:seg[@type = 'ws']][not(ancestor::xtoks:collapsed)]" as="item()*"/>
        <xsl:variable name="following" select="following::*[self::tei:w or self::tei:pc or self::tei:seg[@type = 'ws']][not(ancestor::xtoks:collapsed)]" as="item()*"/>
        <xsl:if test="$debug">
            <xsl:message>===================</xsl:message>
            <xsl:message><xsl:copy-of select="."/></xsl:message>
            <xsl:message>Identified <xsl:value-of select="count($segCandidates)"/> candidates.</xsl:message>
        </xsl:if>
        <xsl:variable name="lex-entries" as="item()*">
            <xsl:for-each select="$segCandidates">
                <!-- number of tokens in the lexicon entry -->
                <xsl:variable name="totalToks" select="count(*)"/>
                <!-- position of the current token in the lexicon-token -->
                <xsl:variable name="pos" select="count(*[. = $token]/preceding-sibling::*)+1" as="xs:integer"/>
                <xsl:variable name="toks-after" select="if ($totalToks = $pos) then 0 else xs:integer($totalToks) - xs:integer($pos)"/>
                <xsl:variable name="toks-before" select="xs:integer($pos) - 1"/>
                <xsl:variable name="next" select="$following[position() le $toks-after]" as="item()*"/>
                <xsl:variable name="prev" select="reverse(reverse($preceding)[position() le $toks-before])" as="item()*"/>
                <xsl:variable name="lex-entry" select="data(.)"/>
                <xsl:variable name="parts-joined" select="string-join(($prev/data(.), $token/data(.), $next/data(.)),'')"/>
                <xsl:if test="$debug">
                    <xsl:message>   candidate "<xsl:value-of select="."/>"</xsl:message>
                    <xsl:message>total toks / before / after : <xsl:value-of select="$totalToks"/> / <xsl:value-of select="$toks-before"/> / <xsl:value-of select="$toks-after"/></xsl:message>
                    <xsl:message>prev / next : <xsl:value-of select="string-join($prev,'')"/> / <xsl:value-of select="string-join($next,'')"/></xsl:message>
                    <xsl:message>$parts-joined: <xsl:value-of select="$parts-joined"/></xsl:message>
                </xsl:if>
                <xsl:if test="$parts-joined = $lex-entry">
                    <entry id="{@xml:id}" xmlns="">
                        <position><xsl:value-of select="$pos"/></position>
                        <toks-before><xsl:value-of select="$toks-before"/></toks-before>
                        <toks-after><xsl:value-of select="$toks-after"/></toks-after>
                    </entry>
                </xsl:if>
            </xsl:for-each>    
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count($lex-entries) > 0">
                <!--                <xsl:message>$lex-entry <xsl:value-of select="$lex-entries[1]/@id"/> "<xsl:value-of select="$lexToks//tei:seg[@xml:id = $lex-entries[1]/@id]"/>"</xsl:message>-->
                <xsl:variable name="toks-after" select="$lex-entries[1]//toks-after" as="xs:integer"/>
                <xsl:variable name="toks-before" select="$lex-entries[1]//toks-before" as="xs:integer"/>
                <xsl:variable name="next" select="$following[position() le $toks-after][1]" as="item()*"/>
                <xsl:variable name="prev" select="reverse(reverse($preceding)[position() le $toks-before])[1]" as="item()*"/>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="toks-after" select="$lex-entries[1]//toks-after"/>
                    <xsl:attribute name="toks-before" select="$lex-entries[1]//toks-before"/>
                    <xsl:attribute name="position" select="$lex-entries[1]//position"/>
                    <xsl:attribute name="lex-entry-id" select="$lex-entries[1]/@id"/>                    
                    <xsl:choose>
                        <xsl:when test="$toks-before = 0 and $toks-after > 0">
                            <xsl:attribute name="part">I</xsl:attribute>
                            <xsl:attribute name="next" select="concat('#',$next/@xml:id)"/>
                        </xsl:when>
                        <xsl:when test="$toks-before > 0 and $toks-after > 0">
                            <xsl:attribute name="part">M</xsl:attribute>
                            <xsl:attribute name="next" select="concat('#',$next/@xml:id)"/>
                            <xsl:attribute name="prev" select="concat('#',$prev/@xml:id)"/>
                        </xsl:when>
                        <xsl:when test="$toks-before > 0 and $toks-after = 0">
                            <xsl:attribute name="part">F</xsl:attribute>
                            <xsl:attribute name="prev" select="concat('#',$prev/@xml:id)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--<xsl:attribute name="part">?</xsl:attribute>-->
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:copy-of select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="tei:*[not(@part)][preceding::*/@toks-after != 0]" mode="addRefsToLexApplied" priority="1">
        <xsl:variable name="this-id" select="xs:string(@xml:id)"/>
        <xsl:variable name="hook" select="preceding::*[@toks-after][1]"/>
        <xsl:variable name="toks-after" as="item()*">
            <list>
                <xsl:copy-of select="($hook/following::tei:w|$hook/following::tei:pc|$hook/following::tei:seg[@type = 'ws'])[position() le xs:integer($hook/@toks-after)]"/>
            </list>
        </xsl:variable>
        <xsl:variable name="in-toks-list" select="$toks-after/*[@xml:id = $this-id]" as="element()*"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="$in-toks-list">
                <xsl:choose>
                    <xsl:when test="$in-toks-list/preceding-sibling::*">
                        <xsl:attribute name="prev" select="concat('#',$in-toks-list/preceding-sibling::*[1]/@xml:id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="prev" select="concat('#',$hook/@xml:id)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$in-toks-list/following-sibling::*">
                    <xsl:attribute name="next" select="concat('#',$in-toks-list/following-sibling::*[1]/@xml:id)"/>
                </xsl:if>
                <xsl:attribute name="part">
                    <xsl:choose>
                        <xsl:when test="$in-toks-list/following-sibling::*"><xsl:text>M</xsl:text><xsl:message><xsl:copy-of select="$in-toks-list/following-sibling::*"/></xsl:message></xsl:when>
                        <xsl:otherwise>F</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:*[@part = 'I']" mode="collapseParts">
        <xsl:param name="partsTagged" as="document-node()" tunnel="yes"/>
        <xtoks:collapsed collapsed-id="{@xml:id}">
            <xsl:copy>
                <xsl:copy-of select="@* except @xml:id"/>
                <xsl:copy-of select="node()"/>
            </xsl:copy>
            <xsl:apply-templates select="key('token-by-id', substring-after(@next,'#'), root($partsTagged))" mode="collapseParts-copy"/>
        </xtoks:collapsed>
        <xsl:copy>
            <xsl:copy-of select="@* except (@part|@next)"/>
            <xsl:value-of select="."/>
            <xsl:apply-templates select="key('token-by-id', substring-after(@next,'#'), root($partsTagged))" mode="collapseParts-doCollapse"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:*[@part = ('M','F')]" mode="collapseParts"/>
    
    
    <xsl:template match="tei:*[@part = ('M','F')]" mode="collapseParts-tag">
        <xsl:param name="partsTagged" as="document-node()" tunnel="yes"/>
        <xtoks:token corresp="#{@xml:id}"><xsl:copy-of select="(@part|@prev|@next)"/></xtoks:token>
        <xsl:if test="@next">
            <xsl:apply-templates select="key('token-by-id', substring-after(@next,'#'), root($partsTagged))" mode="#current"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:*[@part = ('M','F')]" mode="collapseParts-doCollapse">
        <xsl:param name="partsTagged" as="document-node()" tunnel="yes"/>
        <xsl:value-of select="."/>
        <xsl:if test="@next">
            <xsl:apply-templates select="key('token-by-id', substring-after(@next,'#'), root($partsTagged))" mode="#current"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*" mode="collapseParts-copy">
        <xsl:param name="partsTagged" as="document-node()" tunnel="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="orig-id" select="@xml:id"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
        <xsl:if test="@next">
            <xsl:apply-templates select="key('token-by-id', substring-after(@next,'#'), root($partsTagged))" mode="#current"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:*[@xml:id = root()//xtoks:collapsed/@collapsed-id]" mode="expandCollapsed" priority="2">
        <xsl:message>matched</xsl:message>
        <xsl:variable name="this-id" select="@xml:id"/>
        <xsl:variable name="origElts" select="root()//xtoks:collapsed[@collapsed-id = $this-id]/*" as="node()*"/>
        <xsl:variable name="lex-entry-id" select="@lex-entry-id" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="$lex-entry-id">
                <xsl:call-template name="splitCollapsed">
                    <xsl:with-param name="parts" select="$origElts" as="item()*"/>
                    <xsl:with-param name="lex-entry" select="$lexToks//tei:*[@xml:id = $lex-entry-id]" tunnel="yes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$origElts">
                    <xsl:element name="{name(.)}" namespace="{namespace-uri(.)}">
                        <xsl:attribute name="xml:id" select="(@orig-id,parent::xtoks:collapsed/@collapsed-id)[1]"/>
                        <xsl:copy-of select="(@* except @orig-id|node())"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xtoks:collapsed" mode="expandCollapsed" priority="1"/>
    
    <xsl:template name="splitCollapsed">
        <xsl:param name="parts" as="element()*" required="yes"/>
        <xsl:param name="lex-entry" as="xs:string" tunnel="yes" required="yes"/>
        <xsl:param name="results" as="element()*" required="no"/>
        <xsl:message>matched</xsl:message>
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
    
    <xsl:template match="tei:*[substring-after(@prev,'#') = root(.)//xtoks:collapsed/@collapsed-id]/@prev" mode="expandCollapsed" priority="2">
        <xsl:param name="partsTagged" tunnel="yes"/>
        <xsl:message>matched</xsl:message>
        <xsl:variable name="collapsed-id" select="substring-after(.,'#')"/>
        <xsl:variable name="origElts" select="root()//xtoks:collapsed[@collapsed-id = $collapsed-id]/*" as="node()*"/>
        <xsl:variable name="collapsed-elt" select="root()//tei:w[@xml:id = $collapsed-id]" as="item()*"/>
        <xsl:choose>
            <xsl:when test="$collapsed-elt/@lex-entry-id">
                <xsl:variable name="prevExpanded">
                    <xsl:call-template name="splitCollapsed">
                        <xsl:with-param name="parts" select="$origElts" as="item()*"/>
                        <xsl:with-param name="lex-entry" select="$lexToks//tei:*[@xml:id = $collapsed-elt/@lex-entry-id]" tunnel="yes"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="prev" select="concat('#',$prevExpanded//*[@xml:id][last()]/@xml:id)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>