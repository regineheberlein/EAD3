<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" queryBinding="xslt2">
    <ns uri="http://www.loc.gov/mads/rdf/v1#" prefix="madsrdf"/>
    <ns uri="http://ead3.archivists.org/schema/" prefix="ead"/>

    <!-- $language-code-lookups: array of urls of target codelist documents -->
    <xsl:variable name="language-code-lookups" as="element()*">
        <file key="iso639-1">http://id.loc.gov/vocabulary/iso639-1.rdf</file>
        <file key="iso639-2">http://id.loc.gov/vocabulary/iso639-2.rdf</file>
    </xsl:variable>

    <!-- $doc is root of instance being tested -->
    <!--<let name="doc" value="/"/>-->
    
    <!-- active-language-code-key:
    get the value of the first conventiondeclaration/abbr whose content matches
    a @key in $language-code-lookups, with a fallback value of iso639-2 if 
    no language code is declared in a conventiondeclaration/abbr in the EAD3 document
    -->
    
    <let name="active-language-code-key" value="(/ead:ead/ead:control/ead:conventiondeclaration/ead:abbr[.=$language-code-lookups/@key],'iso639-2')[1]"/>
    
    <!--$language-code-lookup:
     select <file> element from $language-code-lookups
     whose @key value matches the EAD3 document's first <conventiondeclaration> child 
     <abbr> element that declares the language codelist with any of the
     values of $language-code-lookups' @key attribute, with a fall-back of 'iso639-2'-->

    <let name="language-code-lookup"
        value="document($language-code-lookups[@key = $active-language-code-key])//madsrdf:code/normalize-space(.)"/>

    <pattern id="codes">
        <!-- context is any element with either a @langcode or @lang -->
        <rule context="*[exists(@langcode | @lang)]">
            <let name="code" value="@lang | @langcode"/>
            <!-- for every @lang or @langcode attribute test that it is equal to a value in the language code list -->
            <assert
                test="every $l in (@lang | @langcode) satisfies normalize-space($l) = $language-code-lookup"
                > The <name/> element's lang or langcode attribute should contain a value from the <value-of select="$active-language-code-key"/> codelist. </assert>
        </rule>

        <let name="countrycodes"
            value="document('http://www.iso.org/iso/home/standards/country_codes/country_names_and_code_elements_xml')"/>
        <rule context="@countrycode">
            <let name="code" value="normalize-space(.)"/>
            <assert test="$countrycodes//ISO_3166-1_Alpha-2_Code_element/normalize-space(.) = $code"
                > The <name/> attribute should contain a code from the ISO 3166-1 codelist.
            </assert>
        </rule>

        <let name="scriptcodes"
            value="document('http://anonscm.debian.org/gitweb/?p=iso-codes/iso-codes.git;a=blob_plain;f=iso_15924/iso_15924.xml;hb=HEAD')"/>
        <rule context="@scriptcode | @script">
            <let name="code" value="normalize-space(.)"/>
            <assert test="$scriptcodes//iso_15924_entry/@alpha_4_code = $code "> The <name/>
                attribute should contain a code from the iso_15924 codelist. </assert>
        </rule>
    </pattern>

    <pattern id="co-occurrence-constraints">
        <rule context="*[@level = 'otherlevel']">
            <assert test="normalize-space(@otherlevel)"> If the value of a <emph>level</emph>
                attribute is "otherlevel', then the <emph>otherlevel</emph> attribute must be used.
            </assert>
        </rule>
    </pattern>
</schema>