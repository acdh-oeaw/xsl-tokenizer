<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs tei xtoks" version="2.0"
	xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="no"/>

	<xsl:function name="xtoks:escape-for-regex">
	<xsl:param name="string" as="xs:string"/>
		<xsl:analyze-string select="$string" regex="([\-\.\[\]\(\)\}}\{{\^\$\\\*\?\+])">
		<xsl:matching-substring>
			<xsl:value-of select="concat('\',.)"/>
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:value-of select="."/>
		</xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:function>

	<xsl:variable name="abbrList" as="document-node()?">
		<xsl:document>
			<abbrs>
				<xsl:choose>
					<xsl:when test="exists($user-supplied-abbreviation-list//abbr)">
						<xsl:message>Using user-supplied abbreviation list</xsl:message>
						<xsl:sequence select="$user-supplied-abbreviation-list//abbr"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:analyze-string
							select="unparsed-text($abbrLexURI)"
							regex="\s*\n">
							<xsl:matching-substring/>
							<xsl:non-matching-substring>
								<abbr>
									<xsl:choose>
										<xsl:when test="contains(.,'&#x9;')">
											<!-- we assume the word form on the first position  -->
											<xsl:value-of select="normalize-space(substring-before(.,'&#x9;'))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(.)"/>
										</xsl:otherwise>
									</xsl:choose>
								</abbr>
							</xsl:non-matching-substring>
						</xsl:analyze-string>
					</xsl:otherwise>
				</xsl:choose>
			</abbrs>
		</xsl:document>
	</xsl:variable>
	
	<xsl:variable name="lexiconList" as="item()*">
		<xsl:analyze-string
					select="unparsed-text($lexiconURI)"
					regex="\s*\n">
					<xsl:matching-substring/>
					<xsl:non-matching-substring>
						<w>
							<xsl:choose>
								<xsl:when test="contains(.,'&#x9;')">
									<xsl:value-of select="normalize-space(substring-before(.,'&#x9;'))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(.)"/>
								</xsl:otherwise>
							</xsl:choose>
						</w>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
	</xsl:variable>

	<xsl:key name="abbrList" match="//tei:abbr" use="text()"/>

	<xsl:template name="tokenize">
		<xsl:param name="node"/>
		<xsl:param name="purgeWhitespace" as="xs:boolean" select="$purgeWhitespace"/>
		<xsl:param name="skipLexEntries" as="xs:boolean" select="false()"/>
<!--		<xsl:message select="string-join($node,'')"/>-->
		<xsl:variable name="lexEntries" select="$lexiconList[contains($node,.)]" as="item()*"/>
		<xsl:variable name="lexEntry" select="$lexEntries[string-length(.) = max($lexEntries/string-length(.))][1]"/>
		<xsl:choose>
			<xsl:when test="not($skipLexEntries) and exists($lexEntry)">
				<xsl:variable name="newNodes" as="item()*">
					<xsl:analyze-string select="$node" regex="{xtoks:escape-for-regex($lexEntry)}">
						<xsl:matching-substring>
							<tei:w><xsl:value-of select="."/></tei:w>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				<xsl:for-each select="$newNodes">
					<xsl:choose>
						<xsl:when test="self::tei:w">
							<xsl:copy-of select="."/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="tokenize">
								<xsl:with-param name="node" select="."/>
								<!-- prevent infinite loop -->
								<xsl:with-param name="skipLexEntries" as="xs:boolean" select="true()"/>
								<xsl:with-param name="purgeWhitespace" select="$purgeWhitespace"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:analyze-string regex="[\s+]" select="$node">
					<xsl:matching-substring>
						<xsl:choose>
							<xsl:when test="matches(.,'^\n$')"/>
							<xsl:when test="$purgeWhitespace"/>
							<xsl:otherwise>
								<tei:seg type="whitespace">
									<xsl:value-of select="."/>
								</tei:seg>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:variable name="token" select="."/>
						<xsl:variable name="abbreviations" select="key('abbrList',$token,$abbrList)" as="item()*"/>
						<xsl:variable name="abbrEntry" select="$abbreviations[string-length(.) = max($abbreviations/string-length(.))][1]"/>
						<xsl:choose>
							<!-- abbreviations -->
							<xsl:when test="count($abbrEntry)>=1 and $useAbbrList">		
								<xsl:variable name="abbreviation" select="xtoks:escape-for-regex($abbrEntry[1])"/>
								
								
							<!--<xsl:when test="exists($abbrList[matches($token,concat('^',.,'$'))]) and $useAbbrList">		
								<xsl:variable name="abbreviation" select="$abbrList[matches($token,concat('^',.,'$'))]"/>-->
								<xsl:analyze-string select="." regex="{$abbreviation}">
									<xsl:matching-substring>
										<tei:w><xsl:value-of select="."/></tei:w>
									</xsl:matching-substring>
									<xsl:non-matching-substring>
										<xsl:choose>
											<!-- we have to check if there was a match at all - otherwise we run into an infinite loop --> 
											<xsl:when test=". eq $node">
												<xsl:message>Error: There should be an abbreviation in "<xsl:value-of select="$node"/>"</xsl:message>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="tokenize">
													<xsl:with-param name="node">
														<xsl:value-of select="."/>
													</xsl:with-param>
													<xsl:with-param name="purgeWhitespace" select="$purgeWhitespace"/>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:non-matching-substring>
								</xsl:analyze-string>
							</xsl:when>
							<xsl:otherwise>
								<!--customized token-regexes-->
								<xsl:analyze-string select="." regex="{$token-regex}">
									<xsl:matching-substring>
										<tei:w>
											<xsl:value-of select="."/>
										</tei:w>
									</xsl:matching-substring>
									<xsl:non-matching-substring>
										<xsl:analyze-string select="." regex="\d+\.">
											<xsl:matching-substring>
												<tei:w>
													<xsl:value-of select="."/>
												</tei:w>
											</xsl:matching-substring>
											<xsl:non-matching-substring>
												<!-- everything else -->
												<xsl:analyze-string select="." regex="{$punctCharPattern}">
													<xsl:matching-substring>
														<tei:pc>
															<xsl:value-of select="."/>
														</tei:pc>
													</xsl:matching-substring>
													<xsl:non-matching-substring>
														<tei:w>
															<xsl:value-of select="."/>
														</tei:w>
													</xsl:non-matching-substring>
												</xsl:analyze-string>
											</xsl:non-matching-substring>
										</xsl:analyze-string>
									</xsl:non-matching-substring>
								</xsl:analyze-string>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
