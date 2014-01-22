<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs tei" version="2.0"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="no"/>


	<xsl:variable name="abbrList" as="item()*">
		<xsl:choose>
			<xsl:when test="$user-supplied-abbreviation-list">
				<xsl:sequence select="$user-supplied-abbreviation-list//abbr"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:analyze-string
					select="unparsed-text($abbrLexURI)"
					regex="\s*\n">
					<xsl:matching-substring/>
					<xsl:non-matching-substring>
						<abbr>
							<xsl:value-of select="normalize-space(.)"/>
						</abbr>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:key name="abbrList" match="abbr" use="text()"/>

	<xsl:template name="tokenize">
		<xsl:param name="node"/>
		<xsl:param name="purgeWhitespace" as="xs:boolean" select="$purgeWhitespace"/>
		<!--<xsl:copy>-->
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
				<xsl:choose>
					<!-- abbreviations -->
					<xsl:when test="some $x in $abbrList satisfies matches(.,$x) and $useAbbrList">
						<xsl:variable name="token" select="."/>
						<xsl:variable name="abbreviation" select="$abbrList[contains($token,.)]"/>
						<xsl:analyze-string select="." regex="{$abbreviation}">
							<xsl:matching-substring>
								<tei:w><xsl:value-of select="."/></tei:w>
							</xsl:matching-substring>
							<xsl:non-matching-substring>
								<xsl:choose>
									<!-- we have to check if there was a match at all - otherwise we run into an infinite loop --> 
									<xsl:when test=". eq $node">
										<xsl:message>Error: Ther should be an abbreviation in "<xsl:value-of select="$node"/>"</xsl:message>
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
						<!-- dates -->
						<xsl:analyze-string select="."
							regex="([0-9]?[0-9]\.)([01]?[0-9]\.)([0-9]{{2,4}})?">
							<xsl:matching-substring>
								<tei:w>
									<xsl:value-of select="regex-group(1)"/>
								</tei:w>
								<tei:w>
									<xsl:value-of select="regex-group(2)"/>
								</tei:w>
								<xsl:if test="exists(regex-group(3))">
									<tei:w>
										<xsl:value-of select="regex-group(3)"/>
									</tei:w>
								</xsl:if>
							</xsl:matching-substring>
							<xsl:non-matching-substring>
								<!-- tausender trennzeichen -->
								<xsl:analyze-string select="." regex="\d+(\.\d{{3,3}})*">
									<xsl:matching-substring>
										<tei:w>
											<xsl:value-of select="."/>
										</tei:w>
									</xsl:matching-substring>
									<xsl:non-matching-substring>
										<!-- ordinals -->
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
							</xsl:non-matching-substring>
						</xsl:analyze-string>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
		<!--</xsl:copy>-->
	</xsl:template>
</xsl:stylesheet>
