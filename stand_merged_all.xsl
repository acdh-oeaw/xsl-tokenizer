<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">

<!-- ********************************************************* -->
<!-- This stylesheet is used to display the output of comments -->
<!-- ********************************************************* -->
<xsl:output method="html"/>
<xsl:variable name="marginLeft" select="'margin-left:100px;'"/>
<xsl:template match="/">

<html>
<head>
<script language="Javascript1.2">
												var numberOfPs = <xsl:value-of select="count(//p |//lg)"/>;
									
												function doSomething() {
															o = document.getElementById('m1');
															o.style.left = "10px";
															o.style.top = "20px";
												}
												
												function findPosX(obj) {
															var curleft = 0;
															if (obj.offsetParent) {
																		while (obj.offsetParent) {
																					curleft += obj.offsetLeft;
																					obj = obj.offsetParent;
																		}
															}	else if (obj.x) curleft += obj.x;
															return curleft;
												}

												function findPosY(obj) {
															var curtop = 0;
															if (obj.offsetParent) {
																		while (obj.offsetParent) {
																					curtop += obj.offsetTop;
																					obj = obj.offsetParent;
																		}
															} else if (obj.y) curtop += obj.y;
															return curtop;
												}
</script>
									
<script language="Javascript1.2">			
												function handleMarginalium(margID_, objMarg_, objP_) {
															pFontSize = objP_.style.fontSize;
															itop = findPosY(objP_);
															objMarg_.style.top = itop + 'px';
																					
															//Set the font size in all BRs to the appropriate size
															k = 1;
															brObjID = margID_ + '_' + k;
															objBR = document.getElementById(brObjID);	
															while (objBR) {
																		objBR.style.fontSize = pFontSize;
																		k++;
																		brObjID = margID_ + '_' + k;
																		objBR = document.getElementById(brObjID);	
															}
												}
												
												s = '';
												i = 0;
												while (i != numberOfPs) {
															subItem = 97;
															margID = 'm' + i;
															var objMarg = document.getElementById(margID);	
															var objP = document.getElementById('p' + i);
															
															if (objP) {
																		while (objMarg) {
																					handleMarginalium(margID, objMarg, objP);
																					
																					margID = 'm' + i + '_' + String.fromCharCode(subItem);
																					objMarg = document.getElementById(margID);
																					subItem++;
																		}			
																																				
															}
															
															i++;
												}
</script>
</head>

<body>					
<div id="textDiv" style="position:absolute;;padding-top:100px;margin-left:100px;">
<xsl:apply-templates select="//text"/>
</div>

<!--
<img id="imageDiv" style="position:absolute;left:800;top:100px;">
<xsl:attribute name="src">../IMAGES/<xsl:value-of select="//aac_IMAGE"/></xsl:attribute>
</img>
-->
</body>
</html>
</xsl:template>

<xsl:template match="ref"><xsl:apply-templates/></xsl:template>

<xsl:template match="note">
<xsl:choose>
<xsl:when test="@xml:id and child::p">
<xsl:apply-templates/>
</xsl:when>
<xsl:otherwise>
<br/><xsl:apply-templates/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- **************** -->
<!-- titlePage Anfang -->
<!-- **************** -->

<xsl:template match="titlePage">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="titlePart">
<xsl:choose>
<xsl:when test="@type[.='desc']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:when test="@type[.='main']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:when test="@type[.='repeated']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:when test="@type[.='sub']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:when test="@type[.='vol']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:otherwise><p style="font-size:14pt;"><xsl:apply-templates/></p></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="docAuthor">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="docDate">
<span style="font-size:14pt;"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="docEdition">
<span style="font-size:14pt;"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="docImprint">
<p style="font-size:14pt;"><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="pubPlace">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="publisher">
<xsl:apply-templates/>
</xsl:template>

<!-- ************** -->
<!-- titlePage Ende -->
<!-- ************** -->

<xsl:template match="ref">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="note">
<xsl:choose>
<xsl:when test="@xml:id and child::p">
<xsl:apply-templates/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="back">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="body">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="front">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="bibl"><xsl:apply-templates/></xsl:template>

<xsl:template match="byline"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:template>

<xsl:template match="cit"><xsl:apply-templates/></xsl:template>

<xsl:template match="corr">
<xsl:if test="@cert[.='high']"><span style="color:rgb(116,116,116);"><sup><i><xsl:apply-templates/></i></sup></span></xsl:if>
<xsl:if test="@cert[.='low']"><span style="color:rgb(116,116,116);"><sup><i><xsl:apply-templates/></i></sup></span></xsl:if>
</xsl:template>

<xsl:template match="sic"><xsl:apply-templates/></xsl:template>

<xsl:template match="reg"></xsl:template>

<xsl:template match="orig"><xsl:apply-templates/></xsl:template>

<xsl:template match="supplied">&#xA0;</xsl:template>

<xsl:template match="date"><xsl:apply-templates/></xsl:template>

<xsl:template match="div">
<!--
<xsl:if test="@n"><span style="color:rgb(128,128,128);margin-left:270px"><xsl:value-of select="@n"/></span></xsl:if>
-->
<xsl:choose>
<xsl:when test="@type[.='compTitle']">
<span style="font-size:14pt;"><xsl:apply-templates/></span>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="emptyLine">
<xsl:param name="line"/>
<xsl:param name="mid"/>
<xsl:variable name="brID"><xsl:value-of select="$mid"/>_<xsl:value-of select="$line"/></xsl:variable>
<xsl:if test="$line &gt; 0">
<br>
<xsl:attribute name="style">font-family:'Arial Unicode MS';font-size:12pt;</xsl:attribute>
<xsl:attribute name="id"><xsl:value-of select="$brID"/></xsl:attribute>
</br>	
<xsl:call-template name="emptyLine">
<xsl:with-param name="line" select="$line - 1"/>
<xsl:with-param name="mid" select="$mid"/>
</xsl:call-template>
</xsl:if>
</xsl:template>

<xsl:template match="epigraph"><xsl:apply-templates/></xsl:template>

<xsl:template match="figure">
<xsl:choose>
<xsl:when test="child::p">
<br/><table style="border: 3px solid Darkgrey;font-size:10pt;padding:3px 3px 3px 3px;">
<tr><td style="border: 1px solid Darkgrey;"><xsl:apply-templates/></td></tr>
</table><br/>
</xsl:when>
<xsl:when test="child::lg">
<br/><table style="border: 3px solid Darkgrey;font-size:10pt;padding:3px 3px 3px 3px;">
<tr><td style="border: 1px solid Darkgrey;"><xsl:apply-templates/></td></tr>
</table><br/>
</xsl:when>
<xsl:otherwise>
<br/><table style="border: 3px solid Darkgrey;">
<tr><td style="border: 1px solid Darkgrey;width:150px;height:100px;"><xsl:apply-templates/></td></tr>
</table><br/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="foreign"><xsl:apply-templates/></xsl:template>

<xsl:template match="fw">
<xsl:choose>
<xsl:when test="@place[.='top_right']">
<span style="margin-left:130px;text-align:right"><xsl:apply-templates/></span>
</xsl:when>
<xsl:when test="@place[.='top_left']">
<span style="text-align:left"><xsl:apply-templates/></span>
</xsl:when>
<xsl:when test="@place[.='top_center'] and contains(.,'Vorrede')">
<span style="margin-left:105px"><xsl:apply-templates/></span>
</xsl:when>
<xsl:when test="@place[.='top_center'] and contains(.,'DEDICATIO')">
<span style="margin-left:90px"><xsl:apply-templates/></span>
</xsl:when>
<xsl:when test="@place[.='top_center']">
<span style="margin-left:120px"><xsl:apply-templates/></span>
</xsl:when>
<xsl:when test="@place[.='bot_right']">
<div style="margin-left:250px"><xsl:apply-templates/></div>
</xsl:when>
<xsl:when test="@place[.='bot_left']">
<span style="width:380px;text-align:left"><xsl:apply-templates/></span>
</xsl:when>
<xsl:when test="@place[.='bot_center']">
<span style="position:absolute;margin-left:130px;"><xsl:apply-templates/></span>
</xsl:when>
<xsl:when test="@type[.='catch']">
<span style="margin-left:230px"><xsl:apply-templates/></span>
</xsl:when>
<xsl:when test="@type[.='marginalNote']">
<div>
<xsl:choose>
<xsl:when test="@place[.='right']"><xsl:attribute name="style">position:absolute;left:600px;width:100px;font-family:'Arial Unicode MS';font-size:10pt;</xsl:attribute></xsl:when>
<xsl:otherwise><xsl:attribute name="style">position:absolute;left:20px;font-family:'Arial Unicode MS';font-size:10pt;</xsl:attribute></xsl:otherwise>
</xsl:choose>
<xsl:variable name="mID">m<xsl:value-of select="count(preceding::p) + count(preceding::lg)"/></xsl:variable>
<xsl:choose>
<xsl:when test="@aac_ord">
<xsl:attribute name="id"><xsl:value-of select="$mID"/>_<xsl:value-of select="@aac_ord"/></xsl:attribute>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="id"><xsl:value-of select="$mID"/></xsl:attribute>
</xsl:otherwise>
</xsl:choose>									
<xsl:if test="@aac_line">
<xsl:choose>
<xsl:when test="@aac_ord">
<xsl:call-template name="emptyLine">
<xsl:with-param name="line" select="@aac_line - 1"/>
<xsl:with-param name="mid"><xsl:value-of select="$mID"/>_<xsl:value-of select="@aac_ord"/></xsl:with-param>
</xsl:call-template>															
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="emptyLine">
<xsl:with-param name="line" select="@aac_line - 1"/>
<xsl:with-param name="mid" select="$mID"/>
</xsl:call-template>															
</xsl:otherwise>
</xsl:choose>																					
</xsl:if>									
<xsl:apply-templates/>
</div>
</xsl:when>
</xsl:choose>
</xsl:template>

<xsl:template match="gap"><span style="color:rgb(226,226,226);">...</span></xsl:template>

<xsl:template match="head">
<xsl:choose>
<xsl:when test="@type[.='desc']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:when test="@type[.='imprint']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:when test="@type[.='main']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:when test="@type[.='sub']"><span style="font-size:14pt;"><p><xsl:apply-templates/></p></span></xsl:when>
<xsl:otherwise><p><xsl:apply-templates/></p></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="imprint"><xsl:apply-templates/></xsl:template>

<xsl:template match="l"><xsl:apply-templates/><br/></xsl:template>

<xsl:template match="lb">
<xsl:choose>
<xsl:when test="@break[.='no'] and @type[.='d']"><xsl:apply-templates/>=<br/></xsl:when>
<xsl:when test="@break[.='no'] and not(@type)"><xsl:apply-templates/><br/></xsl:when>
<xsl:when test="@break[.='no'] and @type[.='s']"><xsl:apply-templates/>-<br/></xsl:when>
<xsl:otherwise><xsl:apply-templates/><br/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="lg">
<p>
<xsl:choose>
<xsl:when test="@rend[.='indent']"><xsl:attribute name="style">font-family:'Arial Unicode MS';font-size:12pt;</xsl:attribute>&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;</xsl:when>
<xsl:when test="ancestor::figure"><xsl:attribute name="style">font-family:'Arial Unicode MS';font-size:12pt;</xsl:attribute></xsl:when>
<xsl:otherwise><xsl:attribute name="style">font-family:'Arial Unicode MS';font-size:12pt;</xsl:attribute></xsl:otherwise>
</xsl:choose>
<xsl:apply-templates/>
</p>									
</xsl:template>

<xsl:template match="milestone">
<xsl:choose>
<xsl:when test="@type[.='hr'] and @rend[.='line']"><hr style="margin-left:0px;text-align:left;width:300px;"/></xsl:when>
<xsl:when test="@type[.='hr'] and @rend[.='high']"><table style="border: 3px solid Darkgrey;padding:3px 3px 3px 3px;"><tr><td style="width:284px;height:50px;"><xsl:apply-templates/></td></tr></table><br/></xsl:when>
<xsl:when test="@type[.='hr'] and @rend[.='dotted']">.................................<br/></xsl:when>

<xsl:when test="@type[.='separator'] and @rend[.='asterisk']"><p style="text-align:center">*</p></xsl:when>
<xsl:when test="@type[.='separator'] and @rend[.='asterism']"><p style="text-align:center">*&#xA0;&#xA0;*&#xA0;&#xA0;*</p></xsl:when>
<xsl:when test="@type[.='separator'] and @rend[.='asterismUp']"><p style="text-align:center">*&#xA0;&#xA0;<sup>*</sup>&#xA0;&#xA0;*</p></xsl:when>
<xsl:when test="@type[.='separator'] and @rend[.='asterismDown']"><p style="text-align:center">*&#xA0;&#xA0;<sub>*</sub>&#xA0;&#xA0;*</p></xsl:when>
<xsl:when test="@type[.='separator'] and @rend[.='hr']"><hr style="width:100px;text-align:center"/></xsl:when>
<xsl:when test="@type[.='separator'] and @rend[.='undefined']"><p style="width:285px;text-align:center">&#x232B;&#x2326;</p></xsl:when>

<xsl:when test="@type[.='symbol'] and @rend[.='blEtc']"><i>r</i>c.</xsl:when>

<xsl:when test="@type[.='symbol'] and @rend[.='bracketsMW']"><span style="font-size:18pt;">):(&#xA0;.<sup>.</sup>.</span></xsl:when>
<xsl:when test="@type[.='symbol'] and @rend[.='bracketsTC']"><span style="font-size:18pt;">)(</span></xsl:when>
<xsl:when test="@type[.='symbol'] and @rend[.='bracketsGM']"><span style="font-size:18pt;">)(</span></xsl:when>

<xsl:when test="@type[.='symbol'] and @rend[.='flower']">&#x273E;</xsl:when>
<xsl:when test="@type[.='symbol'] and @rend[.='flowerKAA']">&#x2766; &#x273E; &#x2766;</xsl:when>
<xsl:when test="@type[.='symbol'] and @rend[.='footerDots']"><span style="font-size:18pt;font-weight:bold;">.<sup>.</sup>.</span></xsl:when>

<xsl:when test="@type[.='symbol'] and @rend[.='undefined']"><b>&#x2609;</b></xsl:when>
<xsl:otherwise>
<b>?S?</b>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="name">
<xsl:choose>
<xsl:when test="@type[.='auctor']"><xsl:apply-templates/></xsl:when>
<xsl:when test="@type[.='translator']"><xsl:apply-templates/></xsl:when>
<xsl:when test="@type[.='editor']"><xsl:apply-templates/></xsl:when>
<xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="p">
<p>
<xsl:choose>
<xsl:when test="@rend[.='indent']"><xsl:attribute name="style">font-family:'Arial Unicode MS';font-size:12pt;</xsl:attribute>&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;</xsl:when>
<xsl:when test="ancestor::figure"><xsl:attribute name="style">font-family:'Arial Unicode MS';font-size:12pt;</xsl:attribute></xsl:when>
<xsl:otherwise><xsl:attribute name="style">font-family:'Arial Unicode MS';font-size:12pt;</xsl:attribute></xsl:otherwise>
</xsl:choose>
<xsl:apply-templates/>
</p>
</xsl:template>

<xsl:template match="pb">
<span style="color:rgb(196,196,196);">.....................................</span>
<br/>
<!--
<span style="color:rgb(196,196,196);"><xsl:if test="@n"><xsl:value-of select="@n"/></xsl:if></span>
-->
<br/>
<br/>
</xsl:template>

<xsl:template match="persName"><xsl:apply-templates/></xsl:template>

<xsl:template match="placeName"><xsl:apply-templates/></xsl:template>

<xsl:template match="quote"><xsl:apply-templates/></xsl:template>

<xsl:template match="rs"><xsl:apply-templates/></xsl:template>

<xsl:template match="seg">
<xsl:if test="@rend[.='initialCapital']">
<xsl:choose>
<xsl:when test="*">
<span style="font-size:25px;"><xsl:apply-templates/></span>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="hstr"><xsl:value-of select="."/></xsl:variable>
<xsl:choose>
<xsl:when test="ancestor::p and substring($hstr, 1,1) != '&#x201E;'">
<span style="font-size:20px;"><xsl:value-of select="substring($hstr, 1, 1)"/></span>
<xsl:value-of select="substring($hstr, 2)"/>
</xsl:when>
<xsl:when test="ancestor::lg and substring($hstr, 1,1) != '&#x201E;'">
<span style="font-size:20px;"><xsl:value-of select="substring($hstr, 1, 1)"/></span>
<xsl:value-of select="substring($hstr, 2)"/>
</xsl:when>
<xsl:when test="substring($hstr, 1,1) != '&#x201E;'">
<span style="font-size:25px;"><xsl:value-of select="substring($hstr, 1, 1)"/></span>
<xsl:value-of select="substring($hstr, 2)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="substring($hstr, 1, 1)"/>
<span style="font-size:25px;"><xsl:value-of select="substring($hstr, 2, 1)"/></span>
<xsl:value-of select="substring($hstr, 3)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
<xsl:choose>
<xsl:when test="@rend[.='antiqua'] and ancestor::fw[@type[.='marginalNote']]"><span style="font-family:'Times New Roman';font-size:10pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='antiqua'] and ancestor::fw[@type[.='catch']]"><span style="font-family:'Times New Roman';font-size:13pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='antiqua'] and ancestor::head"><span style="font-family:'Times New Roman';font-size:14pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='antiqua'] and ancestor::byline"><span style="font-family:'Times New Roman';font-size:14pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='antiqua'] and ancestor::docImprint"><span style="font-family:'Times New Roman';font-size:14pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='antiqua'] and ancestor::titlePart"><span style="font-family:'Times New Roman';font-size:14pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='antiqua']"><span style="font-family:'Times New Roman';font-size:13pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='bold']"><b><xsl:apply-templates/></b></xsl:when>
<xsl:when test="@rend[.='gothic']"><span style="font-family:'Arial Unicode MS';font-size:12pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='italicised']"><i><xsl:apply-templates/></i></xsl:when>
<xsl:when test="@rend[.='spaced']"><span style="letter-spacing:0.2em"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='smallCaps']"><span style="font-variant:small-caps;font-size:12pt;"><xsl:apply-templates/></span></xsl:when>
<xsl:when test="@rend[.='sub']"><sub><span style="font-size:smaller;"><xsl:apply-templates/></span></sub></xsl:when>
<xsl:when test="@rend[.='sup']"><sup><span style="font-size:smaller;"><xsl:apply-templates/></span></sup></xsl:when>
<xsl:when test="@rend[.='underlined']"><u><xsl:apply-templates/></u></xsl:when>
<xsl:when test="@type[.='enum']"><xsl:apply-templates/></xsl:when>
<xsl:when test="@type[.='footer']"><xsl:apply-templates/></xsl:when>
<xsl:when test="@type[.='header']">
<xsl:choose>
<xsl:when test="descendant::fw[@place='top_center'] and fw[@place='top_right']">
<xsl:apply-templates/>
</xsl:when>
<xsl:when test="descendant::fw[@place='top_right'][not(@place='top_center')]">
<span style="margin-left:380px;"><xsl:apply-templates/></span>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates/><br/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="@type[.='signature']"><xsl:apply-templates/></xsl:when>
<xsl:when test="@rend[.='gothic']"><span style="font-family:'Arial Unicode MS';font-size:12pt;"><xsl:apply-templates/></span></xsl:when>
</xsl:choose>
</xsl:template>

<xsl:template match="text"><span style="font-family:'Arial Unicode MS'"><xsl:apply-templates/></span></xsl:template>

<xsl:template match="table">
<xsl:choose>
<xsl:when test="ancestor::table">
<table><xsl:apply-templates/></table>
</xsl:when>
<xsl:otherwise>
<table><xsl:apply-templates/></table>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="row"><tr><xsl:apply-templates/></tr></xsl:template>

<xsl:template match="cell">
<td><xsl:attribute name="style">vertical-align:top;</xsl:attribute>
<xsl:if test="@cols">
<xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
</xsl:if>
<xsl:if test="@rows">
<xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute>
</xsl:if>
<xsl:apply-templates/></td>
</xsl:template>

<xsl:template match="aac_PREV"></xsl:template>

<xsl:template match="aac_NEXT"></xsl:template>

<xsl:template match="aac_IMAGE"></xsl:template>

<xsl:template match="aac_PAGE"><span style="font-family:'Arial Unicode MS'"><xsl:apply-templates/></span></xsl:template>

</xsl:stylesheet>
