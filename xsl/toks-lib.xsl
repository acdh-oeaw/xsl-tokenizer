<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://acdh.oeaw.ac.at/xtoks" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:template match="node()" mode="is-copy-node is-ignore-node is-inline-node is-floating-node">
        <xsl:sequence select="false()"/>
    </xsl:template>
    <xsl:function name="xtoks:is-copy-node" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:apply-templates select="$node" mode="is-copy-node"/>
    </xsl:function>
    <xsl:function name="xtoks:is-ignore-node" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:apply-templates select="$node" mode="is-ignore-node"/>
    </xsl:function><!--    <xsl:template match="*" mode="is-ignore-node" priority="1">
        <xsl:sequence select="true()"/>
    </xsl:template>
    -->
    <xsl:function name="xtoks:is-inline-node" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:apply-templates select="$node" mode="is-inline-node"/>
    </xsl:function>
    <xsl:function name="xtoks:is-floating-node" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:apply-templates select="$node" mode="is-floating-node"/>
    </xsl:function>
    <xsl:template name="tokenize-text">
        <xsl:param name="ws-regex" required="yes"/>
        <xsl:param name="pc-regex" required="yes"/>
        <xsl:param name="preserve-ws" required="no" as="xs:boolean" select="true()"/>
        <xsl:analyze-string select="." regex="{$ws-regex}">
            <xsl:matching-substring>
                <xsl:element name="ws">
                    <xsl:attribute name="xml:space">preserve</xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <!-- ordinals -->
                <xsl:analyze-string select="." regex="[0-9]+\.">
                    <xsl:matching-substring><w><xsl:value-of select="."/></w></xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="." regex="{$pc-regex}">
                            <xsl:matching-substring><pc><xsl:value-of select="."/></pc></xsl:matching-substring>
                            <xsl:non-matching-substring><w><xsl:value-of select="."/></w></xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
</xsl:stylesheet>