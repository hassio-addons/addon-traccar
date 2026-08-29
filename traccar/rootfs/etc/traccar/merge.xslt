<?xml version='1.0' encoding='UTF-8'?>

<!--
    App managed merge of the Traccar configuration.

    Traccar dropped the "config.default" parameter in 6.2, so the app
    defaults and the user configuration have to be combined into a single
    runtime file. That is done here, at the XML level, on purpose. Reading
    the values into the shell and writing them back escapes them a second
    time, which turns the "&" in, for example, a JDBC connection URL into a
    literal "&amp;" and makes Traccar refuse to start.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"
        doctype-system="http://java.sun.com/dtd/properties.dtd" />

    <!-- The user configuration to merge on top of the app defaults -->
    <xsl:param name="user" />

    <!-- "config.default" is left over from older versions of this app -->
    <xsl:variable name="overrides"
        select="document($user)/properties/entry[@key != 'config.default']" />

    <xsl:template match="/properties">
        <properties>
            <xsl:copy-of select="entry[not(@key = $overrides/@key)]" />
            <xsl:copy-of select="$overrides" />
        </properties>
    </xsl:template>

</xsl:stylesheet>
