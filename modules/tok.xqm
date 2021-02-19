xquery version "3.0";

module namespace tok = "http://acdh.oeaw.ac.at/apps/xtx/tokenize";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";
import module namespace config = "http://acdh.oeaw.ac.at/apps/xtx/config" at "config.xqm";
import module namespace profile = "http://acdh.oeaw.ac.at/apps/xtx/profile" at "profile.xqm";
import module namespace console = "http://exist-db.org/xquery/console";

declare function tok:rmNl ($doc as document-node(), $profile-id as xs:string?) as document-node() {
    let $path-to-xsl := $config:tokenizer-home||"/xsl/rmNl.xsl",
        $xsl := doc($path-to-xsl)
    return 
        try  { 
                document { transform:transform($doc, $xsl, ()) }
            } catch * {
                console:log( $err:code||" "||$err:description||" "||$err:value)
            }
};

declare function tok:toks($doc as document-node(), $profile-id as xs:string) as item() {
    let $profile := profile:home($profile-id),
        $path-to-wrapper := $profile||"/wrapper_toks.xsl",
        $prepare-wrapper := if (doc-available($path-to-wrapper)) then () else profile:prepare($profile-id),
        $xsl := doc($path-to-wrapper)
    return
        if ($xsl)
        then 
            try  { 
                document { transform:transform($doc, $xsl, ()) }
            } catch * {
                console:log( $err:code||" "||$err:description||" "||$err:value)
            }
        else ()
};

declare function tok:addP($doc as document-node(), $profile-id as xs:string) as item() {
    let $profile := profile:home($profile-id),
        $path-to-wrapper := $profile||"/wrapper_addP.xsl",
        $xsl := if (doc-available($path-to-wrapper)) then doc($path-to-wrapper) else fn:error(QName("http://acdh.oeaw.ac.at/apps/xtx/tokenize", "MISSING_WRAPPER_XSL"), "wrapper_addP.xsl missing for profile '"||$profile-id||"'")
    return document { transform:transform($doc, $xsl, ()) } 
};

declare function tok:tei2vert($doc as document-node(), $profile-id as xs:string) as item() {
    let $profile := profile:home($profile-id),
        $path-to-wrapper := $profile||"/wrapper_tei2vert.xsl",
        $xsl := if (doc-available($path-to-wrapper)) then doc($path-to-wrapper) else ()
    return
        if ($xsl)
        then 
            try  { 
                document { transform:transform($doc, $xsl, ()) }
            } catch * {
                console:log( $err:code||" "||$err:description||" "||$err:value)
            }
        else ()
};
  
declare function tok:vert2txt($doc as document-node(), $profile-id as xs:string) as item() {
    let $profile := profile:home($profile-id),
        $path-to-wrapper := $profile||"/wrapper_vert2txt.xsl",
        $xsl := if (doc-available($path-to-wrapper)) then doc($path-to-wrapper) else ()
    return
        if ($xsl)
        then document { transform:transform($doc, $xsl, ()) }
        else ()
};

declare function tok:postprocess($pAdded as document-node(), $profile-id as xs:string){
    let $profile := profile:read($profile-id),
        $postprocess-xsl := $profile//postProcessing/xsl:stylesheet
    return 
        if (exists($postprocess-xsl)) 
        then transform:transform($pAdded, $postprocess-xsl, ())
        else $pAdded
};


declare function tok:tokenize($doc as document-node(), $profile-id as xs:string, $format as xs:string) as item()* {
    let $nlRmd := tok:rmNl($doc, $profile-id),
        $toks := tok:toks($nlRmd, $profile-id),
        $pAdded := tok:addP($toks, $profile-id),
        $postProcessed := tok:postprocess($pAdded, $profile-id)
    return 
        switch($format)
            case "vert" return tok:tei2vert($postProcessed, $profile-id)
            case "txt" return 
                let $vert := tok:tei2vert($postProcessed, $profile-id)
                return tok:vert2txt($vert, $profile-id)
            case "doc" return $postProcessed
            default return $postProcessed
};
