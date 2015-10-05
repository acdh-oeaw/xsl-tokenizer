<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 4, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Daniel Schopper</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="makeNoNamespaceVersion" as="xs:boolean" select="if(exists(root()//param[@key='makeNoNamespaceVersion'])) then xs:boolean(root()//param[@key='makeNoNamespaceVersion']/data(@value)) else true()"/>
    <xsl:param name="pathToTokenizer" as="xs:string" select="if(exists(root()//param[@key='pathToTokenizerLib'])) then xs:string(root()//param[@key='pathToTokenizerLib']/data(@value)) else '../../xsl/toks.xsl'"/>
    <xsl:param name="punctCharPattern" as="xs:string" select="if(exists(root()//param[@key='pc-regex'])) then xs:string(root()//param[@key='pc-regex']/data(@value)) else '\p{P}+'"/>
    <xsl:param name="pathToPLib" as="xs:string" select="if(exists(root()//param[@key='pathToPLib'])) then xs:string(root()//param[@key='pathToPLib']/data(@value)) else '../../xsl/addP.xsl'"/>
    
    <xsl:variable name="profile-name" as="xs:string" select="/profile/@id"/>

    <xsl:template match="/">
        <!-- parameter stylesheet -->
        <xsl:result-document href="../{$profile-name}/params.xsl">
            <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
                <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
                <xsl:namespace name="xd">http://www.oxygenxml.com/ns/doc/xsl</xsl:namespace>
                <xsl:attribute name="version">2.0</xsl:attribute>
                <xsl:for-each select="//namespace">
                    <namespace name="{@prefix}" select="."/>
                </xsl:for-each>
                
                <for-each select="//param">
                    <xsl:element name="xsl:param">
                        <xsl:attribute name="name">
                            <xsl:value-of select="@key"/>
                        </xsl:attribute>
                        <if test="@as">
                            <xsl:attribute name="as">
                                <xsl:value-of select="@as"/>
                            </xsl:attribute>
                        </if>
                        <xsl:analyze-string select="@value" regex="\$\{{(profile-home|xsl-home)\}}">
                            <xsl:matching-substring>
                                <xsl:choose>
                                    <xsl:when test="regex-group(1) = 'profile-home'">
                                        <xsl:value-of select="concat('../profiles/',$profile-name)"/>
                                    </xsl:when>
                                    <xsl:when test="regex-group(1) = 'xsl-home'">
                                        <xsl:value-of select="concat('../xsl/',$profile-name)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:element>
                </for-each>
                
                <for-each select="//expression[parent::ignore]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:attribute name="mode">is-ignore-node</xsl:attribute>
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select">true()</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </for-each>
                
                <for-each select="//expression[parent::in-word-tags]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:attribute name="mode">is-inline-node</xsl:attribute>
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select">true()</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </for-each>
                
                <for-each select="//expression[parent::floating-blocks]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:attribute name="mode">is-floating-node</xsl:attribute>
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select">true()</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </for-each>
                
            </xsl:element>
        </xsl:result-document>
        
        <xsl:if test="exists(//postProcessing[xsl:stylesheet])">
            <xsl:result-document href="postTokenization.xsl">
                <xsl:copy-of select="//postProcessing/xsl:stylesheet"/>
            </xsl:result-document>
        </xsl:if>

        <!-- tokenizer wrapper -->
        <xsl:result-document href="../{$profile-name}/wrapper_toks.xsl">
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
                    <attribute name="href">params.xsl</attribute>
                </element>
                <xsl:if test="exists(//postProcessing[xsl:stylesheet])">
                    <element name="xsl:import">
                        <attribute name="href">postTokenization.xsl</attribute>
                    </element>    
                </xsl:if>
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
                    <element name="xsl:next-match"/>
                    <!--<element name="xsl:variable">
                        <attribute name="name"></attribute>
                        <element name="xsl:apply-templates">
                            <attribute name="select">.</attribute>
                            <attribute name="mode">makeWTags</attribute>
                        </element>
                    </element>
                    <xsl:choose>
                        <xsl:when test="exists(//postProcessing)">
                            <element name="xsl:apply-templates">
                                <attribute name="select">$wTagsAdded</attribute>
                                <attribute name="mode">postProcess</attribute>
                            </element>
                        </xsl:when>
                        <xsl:otherwise>
                            <element name="xsl:sequence">
                                <attribute name="select">$wTagsAdded</attribute>
                            </element>
                        </xsl:otherwise>
                    </xsl:choose>-->
                </element>
    
                <text>&#10;&#10;</text>
            </xsl:element>
        </xsl:result-document>
        
        
        <!-- tokenizer wrapper -->
        <xsl:result-document href="../{$profile-name}/wrapper_addP.xsl">
            <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
                <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
                <xsl:namespace name="xd">http://www.oxygenxml.com/ns/doc/xsl</xsl:namespace>
                <xsl:for-each select="//namespace">
                    <namespace name="{@prefix}" select="."/>
                </xsl:for-each>
                
                <xsl:for-each select="//namespace">
                    <namespace name="{@prefix}" select="."/>
                </xsl:for-each>
                
                <attribute name="version">2.0</attribute>
                <attribute name="exclude-result-prefixes">#all</attribute>
                <text>&#10;&#10;</text>
                
                
                <element name="xsl:import">
                    <attribute name="href" select="$pathToPLib"/>
                </element>
                <element name="xsl:import">
                    <attribute name="href">params.xsl</attribute>
                </element>
                <xsl:if test="exists(//postProcessing[xsl:stylesheet])">
                    <element name="xsl:import">
                        <attribute name="href">postTokenization.xsl</attribute>
                    </element>    
                </xsl:if>
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
                    <element name="xsl:next-match"/>
                </element>
                
                <text>&#10;&#10;</text>
            </xsl:element>
        </xsl:result-document>            
    </xsl:template>
</xsl:stylesheet>
