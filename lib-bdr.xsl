<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:icltt="http://www.oeaw.ac.at/icltt" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Dec 5, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> aac</xd:p>
			<xd:p>Library for detecting word/token boundaries. Markup is generally taken to be
				'inline' markup which possibly , i.e. only presence / absence of whitespace and
				puctuation is taken into account. </xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:output indent="no" method="xml"/>
	
	
	<xsl:function name="icltt:splits-token">
		<xsl:param as="node()?" name="node"/>
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

	<xsl:function name="icltt:preceding">
		<xsl:param as="node()?" name="node"/>
		<xsl:variable name="siblings" select="$node/preceding-sibling::node()[icltt:textvalue(.)]"/>
		<xsl:choose> 
			<xsl:when test="exists($siblings)">
				<xsl:sequence select="$siblings[last()]"/>
			</xsl:when>
			<xsl:when test="some $x in $floatingblocks//node() satisfies $x is $node">
				<xsl:variable name="floatingblock" select="$floatingblocks[some $n in descendant::node() satisfies $n is $node]"/>
				<xsl:variable name="prec" select="$node/ancestor::node()[some $x in ancestor::* satisfies $x is $floatingblock][icltt:textvalue(.)][exists(preceding-sibling::node()[icltt:textvalue(.)])][1]/preceding-sibling::node()[icltt:textvalue(.)][1]"/>
				<xsl:sequence select="$prec"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence
					select="$node/ancestor::node()[icltt:textvalue(.)][exists(preceding-sibling::node()[icltt:textvalue(.)])][1]/preceding-sibling::node()[icltt:textvalue(.)][1]"
				/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="icltt:following">
		<xsl:param as="node()?" name="node"/>
		<xsl:variable name="siblings" select="$node/following-sibling::node()[icltt:textvalue(.)]"/>
		<xsl:choose>
			<xsl:when test="exists($siblings)">
				<xsl:sequence select="$siblings[1]"/>
			</xsl:when>
			<xsl:when test="some $x in $floatingblocks//node() satisfies $x is $node">
				<xsl:variable name="floatingblock" select="$floatingblocks[some $n in descendant::node() satisfies $n is $node]"/>
				<xsl:sequence select="$node/ancestor::node()[some $x in ancestor::* satisfies $x is $floatingblock][icltt:textvalue(.)][exists(following-sibling::node()[icltt:textvalue(.)])][1]/following-sibling::node()[icltt:textvalue(.)][1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence
					select="$node/ancestor::node()[icltt:textvalue(.)][exists(following-sibling::node()[icltt:textvalue(.)])][1]/following-sibling::node()[icltt:textvalue(.)][1]"
				/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="icltt:textvalue">
		<xsl:param as="node()?" name="node"/>
		<xsl:variable as="item()*" name="val">
			<xsl:apply-templates mode="textvalue" select="$node"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="replace(string-join($val,''),'\n','')!=''">
				<xsl:value-of select="$val"/>
			</xsl:when>
			<!--<xsl:when test="not(empty($val/replace(.,'\n',''))) and $node/self::* and icltt:is-in-word-tag($node)">
				<xsl:sequence select="true()"/>
			</xsl:when>-->
			<!--<xsl:when test="$node/self::* and icltt:is-in-word-tag($node)">
                <xsl:sequence select="true()"/>
            </xsl:when>-->
		</xsl:choose>
	</xsl:function>

	<xsl:template as="xs:boolean" match="*" mode="is-in-word-tag">
		<xsl:sequence select="false()"/>
	</xsl:template>

	<xsl:function as="xs:boolean" name="icltt:is-in-word-tag">
		<xsl:param as="element()" name="tag"/>
		<xsl:apply-templates mode="is-in-word-tag" select="$tag"/>
	</xsl:function>
	
	<xsl:template as="xs:boolean" match="*" mode="is-floating-block">
		<xsl:sequence select="false()"/>
	</xsl:template>
	
	<xsl:function as="xs:boolean" name="icltt:is-floating-block">
		<xsl:param as="element()" name="tag"/>
		<xsl:apply-templates mode="is-floating-block" select="$tag"/>
	</xsl:function>
	
	<xsl:template as="xs:boolean" match="*" mode="is-ignored">
		<xsl:sequence select="false()"/>
	</xsl:template>
	
	<xsl:function as="xs:boolean" name="icltt:is-ignored">
		<xsl:param as="element()" name="tag"/>
		<xsl:apply-templates mode="is-ignored" select="$tag"/>
	</xsl:function>

	<xsl:function as="xs:boolean" name="icltt:starts-token">
		<xsl:param as="node()" name="node"/>
		<xsl:sequence select="icltt:starts-token($node,false())"/>
	</xsl:function>

	<xsl:function as="xs:boolean" name="icltt:starts-token">
		<xsl:param as="node()" name="node"/>
		<xsl:param as="xs:boolean" name="isLookAhead"/>
		<xsl:variable name="preceding" select="icltt:preceding($node)"/>
		<xsl:variable as="item()*" name="toks">
			<xsl:call-template name="tokenize">
				<xsl:with-param name="node" select="$node"/>
				<xsl:with-param name="purgeWhitespace" select="false()"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<!-- node = text() -->
			<xsl:when test="$node instance of text()">
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
										<xsl:sequence select="icltt:ends-token($preceding, true())"/>
									</xsl:when>
									<!--<xsl:when test="exists($node/parent::*)">
										<xsl:sequence select="icltt:starts-token($node/parent::*)"/>
									</xsl:when>-->
									<xsl:otherwise>
										<xsl:sequence select="true()"/>
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
						<xsl:choose>
							<xsl:when test="$toks[1]/self::tei:seg[@type='whitespace'] or $toks[1]/self::tei:pc">
								<xsl:sequence select="true()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="false()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="not($preceding)">
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
							<xsl:when test="icltt:ends-token($preceding,true())">
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

	<xsl:function as="xs:boolean" name="icltt:ends-token">
		<xsl:param as="node()" name="node"/>
		<xsl:sequence select="icltt:ends-token($node,false())"/>
	</xsl:function>

	<xsl:function as="xs:boolean" name="icltt:ends-token">
		<xsl:param as="node()" name="node"/>
		<xsl:param as="xs:boolean" name="isLookBehind"/>
		<xsl:variable name="following" select="icltt:following($node)"/>
		<xsl:variable as="item()*" name="toks">
			<xsl:call-template name="tokenize">
				<xsl:with-param name="node" select="$node"/>
				<xsl:with-param name="purgeWhitespace" select="false()"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<!-- node = text() -->
			<xsl:when test="$node instance of text()">
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
							<xsl:when test="exists($following)">
								<xsl:sequence select="icltt:starts-token($following,true())"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="true()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- node = element() -->
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$isLookBehind">
						<xsl:choose>
							<xsl:when test="$toks[last()]/self::*[self::tei:seg[@type='whitespace'] or self::tei:pc]">
								<xsl:sequence select="true()"/>
							</xsl:when>
							<xsl:when test="icltt:is-in-word-tag($node)">
								<xsl:sequence select="false()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="true()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="not($following)">
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
							<xsl:when test="icltt:ends-token($following)">
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


	<xsl:function as="xs:boolean" name="icltt:is-token">
		<xsl:param as="element()" name="tag"/>
		<xsl:sequence select="icltt:starts-token($tag) and icltt:ends-token($tag)"/>
	</xsl:function>

	<xsl:template match="node() | @*" mode="makeWTags">
		<xsl:copy>
			<xsl:apply-templates mode="makeWTags" select="node() | @*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tei:w" mode="makeWTags">
		<xsl:param as="xs:string?" name="part"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="$part!=''">
				<xsl:attribute name="part" select="$part"/>
			</xsl:if>
			<xsl:copy-of select="node()"/>
		</xsl:copy>
	</xsl:template>



	<xsl:template match="/*" mode="makeWTags" priority="4">
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

	<xsl:template match="text()[not(matches(.,'^\s+$'))]" mode="makeWTags" priority="1">
		<xsl:param name="in-floating-block" tunnel="yes"/>
		<xsl:param name="is-ignored" tunnel="yes"/>
		<xsl:choose>
			<!--<xsl:when test="some $x in ancestor::* satisfies icltt:is-ignored($x)">
				<xsl:copy-of select="."/>
			</xsl:when>-->
			<xsl:when test="$is-ignored">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable as="item()*" name="toks">
					<xsl:call-template name="tokenize">
						<xsl:with-param name="node" select="."/>
						<xsl:with-param name="purgeWhitespace" select="false()"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="preceding" select="icltt:preceding(.)"/>

				<xsl:variable name="following" select="icltt:following(.)"/>
				<!-- TOKEN BEFORE FIRST BLANK-->
				<xsl:choose>
					<xsl:when test="icltt:starts-token(.) and icltt:ends-token(.)">
						<xsl:copy-of
							select="if (count($toks) eq 1) then $toks else $toks except $toks[last()]"
						/>
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
									<xsl:when
										test="icltt:starts-token(.) and not(icltt:ends-token(.))">
										<tei:w>
											<xsl:if test="not(exists($following)) and icltt:is-in-word-tag(parent::*) or exists($following)">
												<xsl:attribute name="part">I</xsl:attribute>
											</xsl:if>
											<xsl:value-of select="$toks[1]"/>
										</tei:w>
									</xsl:when>
									<xsl:when
										test="icltt:ends-token(.) and not(icltt:starts-token(.))">
										<tei:w part="F">
											<xsl:value-of select="$toks[1]"/>
										</tei:w>
									</xsl:when>
									<xsl:when
										test="not(icltt:ends-token(.)) and not(icltt:starts-token(.))">
										<tei:w part="M">
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
										<xsl:sequence select="$toks except $toks[last()]"/>

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
												<xsl:element name="{name($toks[1])}">
													<xsl:if test="$toks[1] instance of element(tei:w)">
														<xsl:attribute name="part">F</xsl:attribute>
													</xsl:if>
												<xsl:value-of select="$toks[1]"/>
												</xsl:element>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:sequence
											select="$toks[position() gt 1] except $toks[last()]"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="not(icltt:starts-token(.))">
										<xsl:element name="{name($toks[1])}">
											<xsl:if test="$toks[1] instance of element(tei:w)">
												<xsl:attribute name="part">F</xsl:attribute>
											</xsl:if>
											<xsl:value-of select="$toks[1]"/>
										</xsl:element>
										<xsl:copy-of
											select="$toks[position() gt 1] except $toks[last()]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="$toks except $toks[last()]"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:if test="count($toks) gt 1">
					<xsl:choose>
						<xsl:when test="icltt:ends-token(.)">
							<xsl:sequence select="$toks[last()]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<!-- parent is defined as in-word-tag, 
                         so this text() is the continuation of the 
                         preceding token  -->
								<xsl:when test="icltt:is-in-word-tag(parent::*)">
									<xsl:choose>
										<xsl:when test="icltt:starts-token(parent::*)">
											<xsl:choose>
												<xsl:when test="icltt:starts-token($following,true())">
													<xsl:copy-of select="$toks[last()]"/>
												</xsl:when>
												<xsl:otherwise>
													<tei:w part="I">
														<xsl:copy-of select="$toks[last()]/node()"/>
													</tei:w>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="icltt:following(.) instance of element()">
													<xsl:choose>
														<xsl:when test="icltt:starts-token(.) and icltt:ends-token(.)">
															<tei:w>
																<xsl:copy-of select="$toks[last()]/node()"/>
															</tei:w>
														</xsl:when>
														<xsl:when test="icltt:starts-token(.) and not(icltt:ends-token(.))">
															<tei:w part="I">
																<xsl:copy-of select="$toks[last()]/node()"/>
															</tei:w>
														</xsl:when>
														<xsl:when test="not(icltt:starts-token(.)) and icltt:ends-token(.)">
															<tei:w part="F">
																<xsl:copy-of select="$toks[last()]/node()"/>
															</tei:w>
														</xsl:when>
														<xsl:otherwise>
															<tei:w part="M">
																<xsl:copy-of select="$toks[last()]/node()"/>
															</tei:w>
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

	<xsl:template match="*" mode="makeWTags" priority="1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="#current"/>
		</xsl:copy>
	</xsl:template>


</xsl:stylesheet>
