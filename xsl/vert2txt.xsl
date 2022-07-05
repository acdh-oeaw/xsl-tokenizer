<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
<xsl:strip-space elements="*"/>
    <xsl:function name="xtoks:structure">
        <xsl:param name="elt"/>
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="local-name($elt)"/>
        <xsl:for-each select="$elt/@*">
            <xsl:value-of select="concat(' ',local-name(.),'=','&#34;',data(.),'&#34;')"/>
        </xsl:for-each>
        <xsl:text>&gt;
</xsl:text>
        <xsl:apply-templates select="$elt/*" mode="vert2txt"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="local-name($elt)"/>
        <xsl:text>&gt;
</xsl:text>
    </xsl:function>
    <xsl:template match="/" mode="vert2txt">
        <xsl:text>&lt;doc</xsl:text>
        <xsl:for-each select="//tei:body/@*">
            <xsl:value-of select="concat(' ',local-name(.),'=','&#34;',data(.),'&#34;')"/>
        </xsl:for-each>
        <xsl:text>&gt;
</xsl:text>
        <xsl:apply-templates select="//tei:body/*" mode="vert2txt"/>
        <xsl:text>&lt;/doc&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="xtoks:ws" mode="vert2txt"/>
    <xsl:template match="*" mode="vert2txt">
        <xsl:sequence select="xtoks:structure(.)"/>
    </xsl:template>
    <xsl:template match="xtoks:w|xtoks:pc" mode="vert2txt">
        <xsl:value-of select="concat(normalize-space(.),'&#x9;',@xtoks:id,'&#xA;')"/>
        <xsl:if test="exists(following-sibling::*) and not(following-sibling::*[1]/self::xtoks:ws)">
            <xsl:text>&lt;g/&gt;
</xsl:text>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>