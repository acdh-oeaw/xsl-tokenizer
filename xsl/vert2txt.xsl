<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="text" indent="no"/>
    <xsl:strip-space elements="*"/>
    <xsl:function name="tei:structure">
        <xsl:param name="elt"/>
        <xsl:choose>
            <xsl:when test="$elt/@type">
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="concat($elt/@type, substring(local-name($elt), 1, 1))"/>
                <xsl:for-each select="$elt/@* except $elt/@type">
                    <xsl:value-of select="concat(' ',local-name(.),'=','&#34;',data(.),'&#34;')"/>
                </xsl:for-each>
                <xsl:text xml:space="preserve">&gt;
</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="local-name($elt)"/>
                <xsl:for-each select="$elt/@*">
                    <xsl:value-of select="concat(' ',local-name(.),'=','&#34;',data(.),'&#34;')"/>
                </xsl:for-each>
                <xsl:text xml:space="preserve">&gt;
</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="$elt/*"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="local-name($elt)"/>
        <xsl:text xml:space="preserve">&gt;
</xsl:text>
        <xsl:if test="exists($elt/following-sibling::*) and $elt/following-sibling::*[1]/(self::xtoks:w|self::xtoks:pc)">
            <xsl:text xml:space="preserve">&lt;g/&gt;
</xsl:text>
        </xsl:if>
    </xsl:function>
    <xsl:template match="/">
        <xsl:text>&lt;doc</xsl:text>
        <xsl:for-each select="//tei:body/@*">
            <xsl:value-of select="concat(' ',local-name(.),'=','&#34;',data(.),'&#34;')"/>
        </xsl:for-each>
        <xsl:text xml:space="preserve">&gt;
</xsl:text>
        <xsl:apply-templates select="//tei:body/*"/>
        <xsl:text>&lt;/doc&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="xtoks:ws"/>
    <xsl:template match="*">
        <xsl:sequence select="tei:structure(.)"/>
    </xsl:template>
    <xsl:template match="(xtoks:w|xtoks:pc)[following-sibling::*[1][self::xtoks:ws] or empty(following-sibling::*)]">
        <xsl:call-template name="noske-token"/>
    </xsl:template>
    <xsl:template name="noske-token">
        <xsl:value-of select="concat(string-join((normalize-space(.), @xtoks:id[parent::xtoks:w], @* except (@xtoks:id, @join, @rend)),'&#x9;'),'&#xA;')"/>
    </xsl:template>
    <xsl:template match="xtoks:w|xtoks:pc">        
        <xsl:call-template name="noske-token"/>
        <xsl:text xml:space="preserve">&lt;g/&gt;
</xsl:text>        
    </xsl:template>
    <!-- do not "render" @rend remarks for NoSkE, it is a bad "renderer" any way -->
    <xsl:template match="xtoks:w[@rend]" priority="2">        
        <xsl:call-template name="noske-token"/>
    </xsl:template>
</xsl:stylesheet>