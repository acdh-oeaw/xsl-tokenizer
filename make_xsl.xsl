<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 4, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> aac</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="makeNoNamespaceVersion" as="xs:boolean"
        select="if(exists(root()//param[@key='makeNoNamespaceVersion'])) then xs:boolean(root()//param[@key='makeNoNamespaceVersion']/data(@value)) else true()"/>
    <xsl:param name="pathToTokenizer" as="xs:string"
        select="if(exists(root()//param[@key='pathToTokenizerLib'])) then xs:string(root()//param[@key='pathToTokenizerLib']/data(@value)) else ''"/>
    <xsl:param name="pathToBoundaryLib" as="xs:string"
        select="if(exists(root()//param[@key='pathToBoundaryLib'])) then xs:string(root()//param[@key='pathToBoundaryLib']/data(@value)) else ''"/>
    <xsl:param name="punctCharPattern" as="xs:string"
        select="if(exists(root()//param[@key='punctCharPattern'])) then xs:string(root()//param[@key='punctCharPattern']/data(@value)) else '\p{P}'"/>


    <xsl:template match="/">
        <!-- parameter stylesheet -->
        <xsl:result-document href="parameters.xsl">
            <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
                <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
                <xsl:namespace name="xd">http://www.oxygenxml.com/ns/doc/xsl</xsl:namespace>
                <xsl:attribute name="version">2.0</xsl:attribute>

                <for-each select="//param">
                    <xsl:element name="xsl:param">
                        <xsl:attribute name="name">
                            <xsl:value-of select="@key"/>
                        </xsl:attribute>
                        <xsl:if test="@as">
                            <xsl:attribute name="as">
                                <xsl:value-of select="@as"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="@value"/>
                    </xsl:element>
                </for-each>
            </xsl:element>
        </xsl:result-document>

        <!-- main stylesheet -->
        <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
            <xsl:namespace name="xd">http://www.oxygenxml.com/ns/doc/xsl</xsl:namespace>
            
            <xsl:for-each select="//namespace">
                <namespace name="{@prefix}" select="."/>
            </xsl:for-each>

            <attribute name="version">2.0</attribute>
            <attribute name="exclude-result-prefixes">#all</attribute>
            <text>&#10;&#10;</text>


            <element name="xsl:import">
                <attribute name="href" select="$pathToTokenizer"/>
            </element>
            <element name="xsl:import">
                <attribute name="href" select="$pathToBoundaryLib"/>
            </element>
            <element name="xsl:import">
                <attribute name="href">parameters.xsl</attribute>
            </element>
            <text>&#10;&#10;</text>

            <element name="xsl:output">
                <attribute name="method">xml</attribute>
                <attribute name="indent">no</attribute>
                <attribute name="omit-xml-declaration">yes</attribute>
            </element>
            <text>&#10;&#10;</text>

            <element name="xsl:template">
                <attribute name="match">/</attribute>
                <attribute name="mode">#default</attribute>
                <element name="xsl:variable">
                    <attribute name="name">wTagsAdded</attribute>
                    <element name="xsl:apply-templates">
                        <attribute name="select">.</attribute>
                        <attribute name="mode">makeWTags</attribute>
                    </element>
                </element>
                <comment>
                    <element name="xsl:variable">
                        <attribute name="name">tokenized</attribute>
                        <element name="xsl:apply-templates">
                            <attribute name="select">$wrapped</attribute>
                            <attribute name="mode">tokenize</attribute>
                        </element>
                    </element>
                    <element name="xsl:sequence">
                        <attribute name="select">$tokenized</attribute>
                    </element>
                </comment>
                <element name="xsl:sequence">
                    <attribute name="select">$wTagsAdded</attribute>
                </element>
            </element>

            <text>&#10;&#10;</text>

            <xsl:for-each select="//expression[ancestor::ignore]">
                <!-- template for textvalue resolving -->
                <element name="xsl:template">
                    <attribute name="match" select="."/>
                    <attribute name="mode">textvalue</attribute>
                </element>
                <text>&#10;&#10;</text>


                <!-- templates for tokenization -->
                <element name="xsl:template">
                    <attribute name="match" select="."/>
                    <attribute name="mode">tokenize</attribute>
                    <attribute name="priority">1</attribute>
                    <!--<xsl:if test="ancestor::ignore">-->
                    <!--<element name="xsl:apply-templates"/>-->
                    <!--                    </xsl:if>-->
                    <element name="xsl:copy-of">
                        <attribute name="select">.</attribute>
                    </element>
                </element>
                <text>&#10;&#10;</text>

                <xsl:if test="xs:boolean($makeNoNamespaceVersion)">
                    <!-- template for textvalue resolving -->
                    <element name="xsl:template">
                        <attribute name="match">
                            <xsl:variable name="pattern">
                                <value-of
                                    select="concat('(',string-join(root()//namespace/concat(@prefix,':'),'|'),')')"
                                />
                            </xsl:variable>
                            <xsl:value-of select="replace(.,$pattern,'')"/>
                        </attribute>
                        <attribute name="mode">textvalue</attribute>
                    </element>
                    <text>&#10;&#10;</text>

                    <!-- templates for tokenization -->
                    <element name="xsl:template">
                        <attribute name="match">
                            <xsl:variable name="pattern">
                                <value-of
                                    select="concat('(',string-join(root()//namespace/concat(@prefix,':'),'|'),')')"
                                />
                            </xsl:variable>
                            <xsl:value-of select="replace(.,$pattern,'')"/>
                        </attribute>
                        <attribute name="mode">tokenize</attribute>
                        <attribute name="priority">1</attribute>
                        <element name="xsl:copy-of">
                            <attribute name="select">.</attribute>
                        </element>
                    </element>
                    <text>&#10;&#10;</text>
                </xsl:if>
            </xsl:for-each>


            <!-- mode: wrap -->
            <xsl:for-each select="//expression[ancestor::in-word-tags]">
                <element name="xsl:template">
                    <attribute name="match" select="."/>
                    <attribute name="mode">is-in-word-tag</attribute>
                    <attribute name="as">xs:boolean</attribute>
                    <element name="xsl:sequence">
                            <attribute name="select">true()</attribute>
                    </element>
                </element>
                <text>&#10;&#10;</text>

                <xsl:if test="xs:boolean($makeNoNamespaceVersion)">
                    <element name="xsl:template">
                        <attribute name="match">
                            <xsl:variable name="pattern">
                                <value-of
                                    select="concat('(',string-join(root()//namespace/concat(@prefix,':'),'|'),')')"
                                />
                            </xsl:variable>
                            <xsl:value-of select="replace(.,$pattern,'')"/>
                        </attribute>
                        <attribute name="mode">is-in-word-tag</attribute>
                        <attribute name="as">xs:boolean</attribute>
                        <element name="xsl:sequence">
                            <attribute name="select">true()</attribute>
                        </element>
                    </element>
                    <text>&#10;&#10;</text>

                </xsl:if>
            </xsl:for-each>
        </xsl:element>

    </xsl:template>
</xsl:stylesheet>
