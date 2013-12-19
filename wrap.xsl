<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:icltt="http://www.oeaw.ac.at/icltt" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 5, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p>Library for detecting word/token boundaries.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="no"/>
	
	<xsl:function name="icltt:splits-token">
		<xsl:param name="node" as="node()?"/>
		<xsl:choose>
			<xsl:when test="$node instance of processing-instruction()">
				<xsl:sequence select="false()"/>
			</xsl:when>
			<xsl:when test="$node instance of attribute()">
				<xsl:sequence select="false()"/>
			</xsl:when>
			<xsl:when test="icltt:is-in-word-tag($node)">
				<xsl:sequence select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

    <xsl:function name="icltt:textvalue">
        <xsl:param name="node" as="node()?"/>
        <xsl:variable name="val" as="item()*">
            <xsl:apply-templates select="$node" mode="textvalue"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-join($val,'')!=''">
                <xsl:value-of select="$val"/>
            </xsl:when>
            <xsl:when test="not(empty($val)) and $node/self::* and icltt:is-in-word-tag($node)">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <!--<xsl:when test="$node/self::* and icltt:is-in-word-tag($node)">
                <xsl:sequence select="true()"/>
            </xsl:when>-->
        </xsl:choose>
    </xsl:function>

    <xsl:template match="*" mode="is-in-word-tag" as="xs:boolean">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <xsl:function name="icltt:is-in-word-tag" as="xs:boolean">
        <xsl:param name="tag" as="element()"/>
        <xsl:apply-templates select="$tag" mode="is-in-word-tag"/>
    </xsl:function>

    <xsl:function name="icltt:starts-token" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:sequence select="icltt:starts-token($node,false())"/>
    </xsl:function>

    <xsl:function name="icltt:starts-token" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="isLookAhead" as="xs:boolean"/>
        <xsl:variable name="preceding"
            select="$node/preceding-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)][1]"/>
        <xsl:variable name="prev"
            select="$node/parent::*/preceding-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)][1]"/>
        <xsl:choose>
            <!-- node = text() -->
            <xsl:when test="$node instance of text()">
                <xsl:variable name="toks" as="item()*">
                    <xsl:call-template name="tokenize">
                        <xsl:with-param name="node" select="$node"/>
                        <xsl:with-param name="purgeWhitespace" select="false()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when
                        test="$toks[1]/self::tei:seg[@type='whitespace'] or $toks[1]/self::tei:pc">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$isLookAhead">
                                <xsl:sequence select="false()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="exists($preceding)">
                                        <xsl:sequence select="icltt:ends-token($preceding, true())"
                                        />
                                    </xsl:when>
                                    <!--<xsl:when test="exists($prev)">
                                        <xsl:sequence select="icltt:ends-token($prev, true())"/>
                                    </xsl:when>-->
                                    <xsl:otherwise>
                                        <xsl:sequence select="icltt:starts-token($node/parent::*)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- node = element() -->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="icltt:is-in-word-tag($node)">
                        <xsl:sequence select="false()"/>
                    </xsl:when>
                    <xsl:when test="not($prev)">
                        <xsl:choose>
                            <xsl:when test="icltt:is-in-word-tag($node)">
                                <xsl:sequence select="false()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="true()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="icltt:ends-token($prev)">
                                <xsl:sequence select="true()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="icltt:is-in-word-tag($node)">
                                        <xsl:sequence select="false()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="true()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="icltt:ends-token" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:sequence select="icltt:ends-token($node,false())"/>
    </xsl:function>

    <xsl:function name="icltt:ends-token" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="isLookBehind" as="xs:boolean"/>
        <xsl:variable name="following"
            select="$node/following-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)][1]"/>
        <xsl:variable name="next"
            select="$node/parent::*/following-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)][1]"/>
        <xsl:choose>
            <!-- node = text() -->
            <xsl:when test="$node instance of text()">
                <xsl:variable name="toks" as="item()*">
                    <xsl:call-template name="tokenize">
                        <xsl:with-param name="node" select="$node"/>
                        <xsl:with-param name="purgeWhitespace" select="false()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when
                        test="$toks[last()]/self::tei:seg[@type='whitespace'] or $toks[last()]/self::tei:pc">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$isLookBehind">
                                <xsl:sequence select="false()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="exists($following)">
                                        <xsl:sequence select="icltt:starts-token($following,true())"
                                        />
                                    </xsl:when>
                                    <xsl:when test="exists($next)">
                                        <xsl:sequence select="icltt:starts-token($next,true())"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="icltt:ends-token($node/parent::*)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- node = element() -->
            <xsl:otherwise>
                <xsl:variable name="next"
                    select="$node/parent::*/following-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)][1]"
                    as="item()?"/>
                <xsl:choose>
                    <xsl:when test="$isLookBehind">
                        <xsl:choose>
                            <xsl:when test="icltt:is-in-word-tag($node)">
                                <xsl:sequence select="false()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="true()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="not($next)">
                        <xsl:choose>
                            <xsl:when test="icltt:is-in-word-tag($node)">
                                <xsl:sequence select="false()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="true()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="icltt:ends-token($next)">
                                <xsl:sequence select="true()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="icltt:is-in-word-tag($node)">
                                        <xsl:sequence select="false()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="true()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--<xsl:function name="icltt:ends-token" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            <!-\- node = text() -\->
            <xsl:when test="$node instance of text()">
                <xsl:variable name="toks" as="item()*">
                    <xsl:call-template name="tokenize">
                        <xsl:with-param name="node" select="$node"/>
                        <xsl:with-param name="purgeWhitespace" select="false()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when
                        test="$toks[last()]/self::tei:seg[@type='whitespace'] or $toks[last()]/self::tei:pc">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="false()"/>
                        <!-\-<xsl:sequence select="icltt:ends-token($node/parent::*)"/>-\->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-\- node = element() -\->
            <xsl:otherwise>
                <xsl:variable name="next"
                    select="$node/parent::*/following-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)][1]"
                    as="item()?"/>
                <xsl:choose>
                    <xsl:when test="not($next)">
                        <xsl:choose>
                            <xsl:when test="icltt:is-in-word-tag($node)">
                                <xsl:sequence select="false()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="true()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="icltt:starts-token($next)">
                                <xsl:sequence select="true()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="icltt:is-in-word-tag($node)">
                                        <xsl:sequence select="false()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="true()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>-->

    <xsl:function name="icltt:is-token" as="xs:boolean">
        <xsl:param name="tag" as="element()"/>
        <xsl:sequence select="icltt:starts-token($tag) and icltt:ends-token($tag)"/>
    </xsl:function>

    <xsl:template match="node() | @*" mode="makeWTags">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="makeWTags"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:w" mode="makeWTags">
        <xsl:param name="part" as="xs:string?"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="$part!=''">
                <xsl:attribute name="part" select="$part"/>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>



    <xsl:template match="/*" priority="4" mode="makeWTags">
        <xsl:copy>
            <xsl:namespace name="tei">http://www.tei-c.org/ns/1.0</xsl:namespace>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text()[matches(.,'^\s+$')]" mode="makeWTags">
        <tei:seg type="whitespace">
            <xsl:value-of select="."/>
        </tei:seg>
    </xsl:template>

    <!-- text node that contains whitespace -->
	<xsl:template match="text()[not(matches(.,'^\s+$'))]" mode="makeWTags" priority="1">
        <xsl:choose>
            <xsl:when test="some $x in ancestor::* satisfies not(icltt:textvalue($x))">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="toks" as="item()*">
                    <xsl:call-template name="tokenize">
                        <xsl:with-param name="node" select="."/>
                        <xsl:with-param name="purgeWhitespace" select="false()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="preceding"
                	select="if (exists(preceding-sibling::node()[icltt:textvalue(.)])) then preceding-sibling::node()[icltt:textvalue(.)][1] else ancestor::node()[icltt:textvalue(.)][exists(preceding-sibling::node()[icltt:textvalue(.)])][1]/preceding-sibling::node()[icltt:textvalue(.)][1]"/>
                
                <xsl:variable name="following"
                	select="if (exists(following-sibling::node()[icltt:textvalue(.)])) then preceding-sibling::node()[icltt:textvalue(.)][1] else ancestor::node()[icltt:textvalue(.)][exists(following-sibling::node()[icltt:textvalue(.)])][1]/following-sibling::node()[icltt:textvalue(.)][1]"/>

                <!-- TOKEN BEFORE FIRST BLANK-->
                <xsl:choose>
                    <xsl:when test="icltt:starts-token(.) and icltt:ends-token(.)">
                        <xsl:copy-of select="if (count($toks) eq 1) then $toks else $toks except $toks[last()]"/>
                    </xsl:when>
                    <!-- text node does not start with whitespace or pc 
                 ->  may be part of a partially marked up token. 
            -->
                    <xsl:otherwise>
                        <xsl:choose>
                        	<xsl:when test="$toks[1]/self::tei:seg[@type='whitespace']">
                        		<xsl:copy-of select="$toks except $toks[last()]"/>
                        	</xsl:when>
                        	<xsl:when test="count($toks) eq 1">
                        		<xsl:choose>
                        			<xsl:when test="icltt:starts-token(.) and not(icltt:ends-token(.))">
                        				<tei:w part="I">
                        					<xsl:value-of select="$toks[1]"/>
                        				</tei:w>
                        			</xsl:when>
                        			<xsl:when test="icltt:ends-token(.) and not(icltt:starts-token(.))">
                        				<tei:w part="F">
                        					<xsl:value-of select="$toks[1]"/>
                        				</tei:w>
                        			</xsl:when>
                        			<xsl:otherwise>
                        				<tei:w>
                        					<xsl:value-of select="$toks[1]"/>
                        				</tei:w>
                        			</xsl:otherwise>
                        		</xsl:choose>
                        	</xsl:when>
                            <xsl:when test="exists($preceding)">
                                <xsl:choose>
                                    <xsl:when test="icltt:ends-token($preceding, true())">
                                        <tei:w>
                                            <xsl:value-of select="$toks[1]"/>
                                        </tei:w>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="$preceding instance of text()">
                                                <!-- <xsl:choose>
                                                  <xsl:when test="exists($toks[3])">-->
                                                <tei:w part="F">
                                                  <xsl:value-of select="$toks[1]"/>
                                                </tei:w>
                                                <!--</xsl:when>
                                                  <xsl:otherwise>
                                                    <tei:w>
                                                        <xsl:value-of select="$toks[1]"/>
                                                    </tei:w>
                                                  </xsl:otherwise>
                                                </xsl:choose>-->
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!--<xsl:choose>
                                                  <xsl:when test="exists($toks[3])">-->
                                                <tei:w part="F">
                                                  <xsl:value-of select="$toks[1]"/>
                                                </tei:w>
                                                <!--</xsl:when>
                                                  <xsl:otherwise>
                                                  <tei:w>
                                                  <xsl:value-of select="$toks[1]"/>
                                                  </tei:w>
                                                  </xsl:otherwise>
                                                </xsl:choose>-->
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:sequence
                                            select="$toks[position() gt 1] except $toks[last()]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <!-- <xsl:otherwise>
                                <xsl:choose>
                                     preceding tag is defined as in-word-tag, 
                                so this text() might be the continuation of the preceding token 
                                    <xsl:when test="exists($prev) and icltt:ends-token($prev)">
                                        <xsl:copy-of select="$toks except $toks[last()]"/>
                                    </xsl:when>
                                    <xsl:when
                                        test="$prev instance of element() and icltt:is-in-word-tag($prev)">
                                        <xsl:choose>
                                            <xsl:when test="icltt:starts-token($prev)">
                                                <xsl:copy-of select="$toks[1]"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <tei:w>
                                                  <xsl:choose>
                                                  <xsl:when test="icltt:ends-token(.)">
                                                  <xsl:attribute name="part">F</xsl:attribute>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:attribute name="part">M</xsl:attribute>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  <xsl:value-of select="$toks[1]"/>
                                                </tei:w>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="$toks except $toks[last()]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                    </xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>

            	<xsl:if test="count($toks) gt 1">
            		<xsl:choose>
            			<xsl:when test="icltt:ends-token(.)">
            				<xsl:sequence select="$toks[last()]"/>
            			</xsl:when>
            			<!-- text node does not end a token  
                 ->  may be part of a partially marked up token. 
            -->
            			<xsl:otherwise>
            				<xsl:choose>
            					<!-- parent is defined as in-word-tag, 
                         so this text() is the continuation of the 
                         preceding token  -->
            					<xsl:when test="icltt:is-in-word-tag(parent::*)">
            						<xsl:choose>
            							<xsl:when test="icltt:starts-token(parent::*)">
            								<xsl:copy-of select="$toks[last()]"/>
            							</xsl:when>
            							<xsl:otherwise>
            								<xsl:choose>
            									<xsl:when
            										test="parent::*/following-sibling::node()[1] instance of element()">
            										<xsl:element
            											name="{name(parent::*/following-sibling::node()[1])}"
            											namespace="{namespace-uri(parent::*/following-sibling::node()[1])}">
            											<xsl:copy-of
            												select="parent::*/following-sibling::node()[1]/@*"/>
            											<xsl:attribute name="isCopy">true</xsl:attribute>
            											<xsl:copy-of select="$toks[last()]/node()"/>
            										</xsl:element>
            									</xsl:when>
            									<xsl:otherwise>
            										<tei:w part="I">
            											<xsl:copy-of select="$toks[last()]/node()"/>
            										</tei:w>
            									</xsl:otherwise>
            								</xsl:choose>
            							</xsl:otherwise>
            						</xsl:choose>
            					</xsl:when>
            					<xsl:otherwise>
            						<tei:w part="I">
            							<xsl:copy-of select="$toks[last()]/node()"/>
            						</tei:w>
            					</xsl:otherwise>
            				</xsl:choose>
            			</xsl:otherwise>
            		</xsl:choose>
            	</xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- text node without whitespace: either a token or part of a token  -->
    <xsl:template match="text()[not(matches(.,'\s'))]" mode="ignore">
        <xsl:choose>
            <xsl:when test="some $x in ancestor::* satisfies not(icltt:textvalue($x))">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="preceding"
                    select="preceding-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)][1]"/>
                <xsl:variable name="following"
                    select="following-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)][1]"/>
                <xsl:choose>
                    <!--<xsl:when test="icltt:starts-token(.) and icltt:ends-token(.)">
                        <tei:w>
                            <xsl:value-of select="."/>
                        </tei:w>
                    </xsl:when>-->
                    <xsl:when test="exists($preceding)">
                        <xsl:choose>
                            <xsl:when test="icltt:ends-token($preceding,true())">
                                <tei:w>
                                    <xsl:value-of select="."/>
                                </tei:w>
                            </xsl:when>
                            <xsl:otherwise>
                                <tei:w part="F">
                                    <xsl:value-of select="."/>
                                </tei:w>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="exists($following)">
                        <xsl:choose>
                            <xsl:when test="icltt:starts-token($following,true())">
                                <tei:w>
                                    <xsl:value-of select="."/>
                                </tei:w>
                            </xsl:when>
                            <xsl:otherwise>
                                <tei:w part="I">
                                    <xsl:value-of select="."/>
                                </tei:w>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="some $x in ancestor::node() satisfies icltt:starts-token($x) and not(exists($x/preceding-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)]))">
                                <xsl:variable name="startTag"
                                    select="ancestor::node()[icltt:starts-token(.)][1]" as="item()"/>
                                <xsl:choose>
                                    <xsl:when
                                        test="some $x in ancestor-or-self::node() satisfies icltt:starts-token($x) and not(exists($x/following-sibling::node()[icltt:textvalue(.) or icltt:splits-token(.)]))">
                                    <!--<xsl:when test="icltt:ends-token(.)">-->
                                        <tei:w>
                                            <xsl:value-of select="."/>
                                        </tei:w>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <tei:w part="I">
                                            <xsl:value-of select="."/>
                                        </tei:w>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="icltt:starts-token(parent::*)">
                                <tei:w part="I">
                                    <xsl:value-of select="."/>
                                </tei:w>
                            </xsl:when>
                            <xsl:when test="icltt:ends-token(parent::*)">
                                <tei:w part="F">
                                    <xsl:value-of select="."/>
                                </tei:w>
                            </xsl:when>
                            <xsl:otherwise>
                                <tei:w part="M">
                                    <xsl:value-of select="."/>
                                </tei:w>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>

                    <!-- <xsl:otherwise>
                        <xsl:variable name="prev"
                            select="parent::*/preceding-sibling::node()[icltt:textvalue(.)][1]"/>
                        <xsl:choose>
                            <xsl:when test="exists($prev) and icltt:ends-token($prev)">
                                <xsl:choose>
                                    <xsl:when test="icltt:ends-token(.)">
                                        <tei:w part="F">
                                            <xsl:value-of select="."/>
                                        </tei:w>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <tei:w part="I">
                                            <xsl:value-of select="."/>
                                        </tei:w>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="icltt:ends-token(.)">
                                        <tei:w part="F">
                                            <xsl:value-of select="."/>
                                        </tei:w>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <tei:w part="M">
                                            <xsl:value-of select="."/>
                                        </tei:w>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
               -->
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" priority="1" mode="makeWTags">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
