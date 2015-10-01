<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:c="http://www.w3.org/ns/xproc-step" 
    version="1.0" name="xsl_tokenizer">
    
    <!-- input from outside -->
    <p:input port="source"/>
    <p:input port="config"/>
    
    <!-- must be placed before other steps -->
    <p:output port="result" primary="true">
        <p:pipe port="result" step="indent"/>
    </p:output>
    
    <!-- paths -->
    <p:option name="path-to-tokenizer" required="true"/>
    <p:option name="path-to-project-xsl" required="true"/>
    <p:option name="path-to-wtags-output" required="true"/>
    
    
    <!-- stylesheet filenames -->
    <p:option name="tokenizer.config" select="'make_xsl.xsl'"/>
    <p:option name="project.addBlanksBeforeLb" select="'addBlanksBeforeLb.xsl'"/>
    <p:option name="project.rmPrettyPrintNewlines" select="'rmPrettyPrintNewlines.xsl'"/>
    <p:option name="tokenizer.addIds" select="'addIds.xsl'"/>
    <p:option name="tokenizer.indent" select="'indent.xsl'"/>
    <p:option name="tokenizer.extractWTags" select="'extractWTags.xsl'"/>
    
    
    <p:variable name="tokenizer.path" select="replace($path-to-tokenizer,'/$','')"/>
    <p:variable name="project.path" select="replace($path-to-project-xsl,'/$','')"/>
    
    
    <!-- stylesheet loading -->
    <p:load name="load.tokenizer.config">
        <p:with-option name="href" select="concat($tokenizer.path,'/',$tokenizer.config)"/>
    </p:load>
    <p:load name="load.project.addBlanksBeforeLb">
        <p:with-option name="href" select="concat($project.path,'/',$project.addBlanksBeforeLb)"/>
    </p:load>
    <p:load name="load.project.rmPrettyPrintNewlines">
        <p:with-option name="href" select="concat($project.path,'/',$project.rmPrettyPrintNewlines)"/>
    </p:load>
    <p:load name="load.tokenizer.addIds">
        <p:with-option name="href" select="concat($tokenizer.path,'/',$tokenizer.addIds)"/>
    </p:load>
    <p:load name="load.tokenizer.indent">
        <p:with-option name="href" select="concat($tokenizer.path,'/',$tokenizer.indent)"/>
    </p:load>
    <p:load name="load.tokenizer.extractWTags">
        <p:with-option name="href" select="concat($tokenizer.path,'/',$tokenizer.extractWTags)"/>
    </p:load>
    
    <p:xslt name="setup">
        <p:input port="source">
            <p:pipe port="config" step="xsl_tokenizer"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="load.tokenizer.config"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    
    
    
    <p:store name="store.tokenize-xsl">
        <p:with-option name="href" select="concat($project.path,'/tmp/xsl/tokenize.xsl')"/>
        <p:input port="source">
            <p:pipe port="result" step="setup"/>
        </p:input>        
    </p:store>
    
    
    
    <!--<p:xslt name="addBlanksBeforeLb">
        <p:input port="source">
            <p:pipe port="source" step="xsl_tokenizer"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="load.project.addBlanksBeforeLb"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>-->
    
    <p:xslt name="removePrettyPrintNewlines">
        <p:input port="source">
            <p:pipe port="source" step="xsl_tokenizer"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="load.project.rmPrettyPrintNewlines"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="tokenize">
        <p:input port="source">
            <p:pipe port="result" step="removePrettyPrintNewlines"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="setup"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="addIds">
        <p:input port="source">
            <p:pipe port="result" step="tokenize"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="load.tokenizer.addIds"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="indent">
        <p:input port="source">
            <p:pipe port="result" step="addIds"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="load.tokenizer.indent"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="extractWTags">
        <p:input port="source">
            <p:pipe port="result" step="addIds"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="load.tokenizer.extractWTags"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:store name="store.wtags">
        <p:input port="source">
            <p:pipe port="result" step="extractWTags"/>
        </p:input>
        <p:with-option name="href" select="$path-to-wtags-output"/>
    </p:store>
    
</p:declare-step>