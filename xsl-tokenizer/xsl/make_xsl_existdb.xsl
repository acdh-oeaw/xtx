<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtoks="http://acdh.oeaw.ac.at/xtoks" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Dec 4, 2013</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> Daniel Schopper</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="toks-lib.xsl"/>
    <xsl:param name="makeNoNamespaceVersion" as="xs:boolean" select="if(exists(root()//param[@key='makeNoNamespaceVersion'])) then xs:boolean(root()//param[@key='makeNoNamespaceVersion']/data(@value)) else true()"/>
    <xsl:param name="pathToTokenizerLib" as="xs:string" select="if(exists(root()//param[@key='pathToTokenizerLib'])) then xs:string(root()//param[@key='pathToTokenizerLib']/data(@value)) else '../../xsl/toks.xsl'"/>
    <xsl:param name="pathToVertXSL" as="xs:string" select="if(exists(root()//param[@key='pathToVertXSL'])) then xs:string(root()//param[@key='pathToVertXSL']/data(@value)) else '../../xsl/tei2vert.xsl'"/>
    <xsl:param name="pathToVertTxtXSL" as="xs:string" select="if(exists(root()//param[@key='pathToVertTxtXSL'])) then xs:string(root()//param[@key='pathToVertTxtXSL']/data(@value)) else '../../xsl/vert2txt.xsl'"/>
    <xsl:param name="punctCharPattern" as="xs:string" select="if(exists(root()//param[@key='pc-regex'])) then xs:string(root()//param[@key='pc-regex']/data(@value)) else '\p{P}+'"/>
    <xsl:param name="ws-regex" as="xs:string" select="if(exists(root()//param[@key='ws-regex'])) then xs:string(root()//param[@key='ws-regex']/data(@value)) else '\s+'"/>
    <xsl:param name="preserve-ws" as="xs:boolean" select="if(exists(root()//param[@key='preserve-ws'])) then xs:boolean(root()//param[@key='preserve-ws']/data(@value)) else true()"/>
    <xsl:param name="pathToPLib" as="xs:string" select="if(exists(root()//param[@key='pathToPLib'])) then xs:string(root()//param[@key='pathToPLib']/data(@value)) else '../../xsl/addP.xsl'"/>
    <xsl:function name="xtoks:expand-path">
        <xsl:param name="path" as="xs:string?"/>
        <xsl:if test="$path != ''">
            <xsl:analyze-string select="$path" regex="\$\{{(profile-home|xsl-home)\}}">
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
        </xsl:if>
    </xsl:function>
    <xsl:variable name="profile-name" as="xs:string" select="/profile/@id"/>
    <xsl:template match="/"><!-- parameter stylesheet -->
        
            <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:attribute name="xml:id">params</xsl:attribute>
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
                        <value-of select="xtoks:expand-path(@value)"/>
                    </xsl:element>
                </for-each>
                <variable name="lexicon" select="//param[@key = 'lexicon']"/>
                <xsl:element name="xsl:param">
                    <xsl:attribute name="name">lexToks</xsl:attribute>
                    <xsl:element name="lexicon" namespace="">
                        <xsl:for-each select="tokenize($lexicon,'\n+')">
                            <xsl:sort select="string-length(.)" order="descending"/>
                            <entry xmlns="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:id" select="concat('entry_',position())"/>
                                <xsl:for-each select="normalize-space(.)">
                                    <xsl:call-template name="tokenize-text">
                                        <xsl:with-param name="pc-regex" select="$punctCharPattern"/>
                                        <xsl:with-param name="ws-regex" select="$ws-regex"/>
                                        <xsl:with-param name="preserve-ws" select="$preserve-ws"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </entry>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
                <xsl:for-each select="//expression[parent::ignore][text()]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:attribute name="mode">is-ignore-node</xsl:attribute>
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select">true()</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
                <xsl:for-each select="//expression[parent::in-word-tags][text()]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:attribute name="mode">is-inline-node</xsl:attribute>
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select">true()</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
                <xsl:for-each select="//expression[parent::floating-blocks][text()]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:attribute name="mode">is-floating-node</xsl:attribute>
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select">true()</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
                <xsl:for-each select="//expression[parent::copy][text()]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:attribute name="mode">is-copy-node</xsl:attribute>
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select">true()</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        
        <xsl:if test="exists(//postProcessing[xsl:stylesheet])">
            
                <xsl:copy-of select="//postProcessing/xsl:stylesheet"/>
            
        </xsl:if><!-- tokenizer wrapper -->
        
            <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:attribute name="xml:id">wrapper_toks</xsl:attribute>
                <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
                <xsl:namespace name="xd">http://www.oxygenxml.com/ns/doc/xsl</xsl:namespace>
                <xsl:for-each select="//namespace">
                    <xsl:namespace name="{@prefix}" select="."/>
                </xsl:for-each>
                <xsl:attribute name="version">2.0</xsl:attribute>
                <xsl:attribute name="exclude-result-prefixes">#all</xsl:attribute>
                <xsl:text xml:space="preserve">

</xsl:text>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href">params.xsl</xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href" select="$pathToTokenizerLib"/>
                </xsl:element>
                <xsl:if test="exists(//postProcessing[xsl:stylesheet])">
                    <xsl:element name="xsl:include">
                        <xsl:attribute name="href">postTokenization.xsl</xsl:attribute>
                    </xsl:element>
                </xsl:if>
                <xsl:text xml:space="preserve">

</xsl:text>
            </xsl:element>
        <!-- tokenizer wrapper -->
        
            <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:attribute name="xml:id">wrapper_addP</xsl:attribute>
                <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
                <xsl:namespace name="xd">http://www.oxygenxml.com/ns/doc/xsl</xsl:namespace>
                <xsl:for-each select="//namespace">
                    <xsl:namespace name="{@prefix}" select="."/>
                </xsl:for-each>
                <xsl:for-each select="//namespace">
                    <xsl:namespace name="{@prefix}" select="."/>
                </xsl:for-each>
                <xsl:attribute name="version">2.0</xsl:attribute>
                <xsl:attribute name="exclude-result-prefixes">#all</xsl:attribute>
                <xsl:text xml:space="preserve">

</xsl:text>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href">params.xsl</xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href" select="$pathToPLib"/>
                </xsl:element>
                <xsl:if test="exists(//postProcessing[xsl:stylesheet])">
                    <xsl:element name="xsl:include">
                        <xsl:attribute name="href">postTokenization.xsl</xsl:attribute>
                    </xsl:element>
                </xsl:if>
                <xsl:text xml:space="preserve">

</xsl:text>
            </xsl:element>
        
        
            <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:attribute name="xml:id">wrapper_tei2vert</xsl:attribute>
                <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
                <xsl:namespace name="xd">http://www.oxygenxml.com/ns/doc/xsl</xsl:namespace>
                <xsl:for-each select="//namespace">
                    <xsl:namespace name="{@prefix}" select="."/>
                </xsl:for-each>
                <xsl:attribute name="version">2.0</xsl:attribute>
                <xsl:attribute name="exclude-result-prefixes">#all</xsl:attribute>
                <xsl:text xml:space="preserve">

</xsl:text>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href">params.xsl</xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href" select="$pathToVertXSL"/>
                </xsl:element>
                <xsl:text xml:space="preserve">

</xsl:text>
                <xsl:for-each select="//expression[parent::structure][text()]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:attribute name="mode">extractTokens</xsl:attribute>
                        <xsl:element name="xsl:copy">
                            <xsl:element name="xsl:apply-templates">
                                <xsl:attribute name="mode">#current</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        
        
            <xsl:element name="xsl:stylesheet" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:attribute name="xml:id">wrapper_vert2txt</xsl:attribute>
                <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
                <xsl:namespace name="xd">http://www.oxygenxml.com/ns/doc/xsl</xsl:namespace>
                <xsl:namespace name="xtoks">http://acdh.oeaw.ac.at/xtoks</xsl:namespace>
                <xsl:for-each select="//namespace">
                    <xsl:namespace name="{@prefix}" select="."/>
                </xsl:for-each>
                <xsl:attribute name="version">2.0</xsl:attribute>
                <xsl:attribute name="exclude-result-prefixes">#all</xsl:attribute>
                <xsl:element name="xsl:output">
                    <xsl:attribute name="method">text</xsl:attribute>
                </xsl:element>
                <xsl:text xml:space="preserve">

</xsl:text>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href">params.xsl</xsl:attribute>
                </xsl:element>
                <xsl:element name="xsl:include">
                    <xsl:attribute name="href" select="$pathToVertTxtXSL"/>
                </xsl:element>
                <xsl:text xml:space="preserve">

</xsl:text>
                <xsl:for-each select="//expression[parent::structure][text()]">
                    <xsl:element name="xsl:template">
                        <xsl:attribute name="match" select="."/>
                        <xsl:element name="xsl:sequence">
                            <xsl:attribute name="select">xtoks:structure(.)</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        
    </xsl:template>
</xsl:stylesheet>