xquery version "3.0";

module namespace tok = "http://acdh.oeaw.ac.at/apps/xtx/tokenize";
import module namespace config = "http://acdh.oeaw.ac.at/apps/xtx/config" at "config.xqm";
import module namespace profile = "http://acdh.oeaw.ac.at/apps/xtx/profile" at "profile.xqm";

declare function tok:rmNl ($doc as document-node(), $profile-id as xs:string?) as document-node() {
    let $path-to-xsl := $config:tokenizer-home||"/xsl/rmNl.xsl",
        $xsl := doc($path-to-xsl)
    return document { transform:transform($doc, $xsl, ()) }
};

declare function tok:toks($doc as document-node(), $profile-id as xs:string) as item() {
    let $profile := profile:home($profile-id),
        $path-to-wrapper := $profile||"/wrapper_toks.xsl",
        $prepare-wrapper := if (doc-available($path-to-wrapper)) then () else profile:prepare($profile-id),
        $xsl := doc($path-to-wrapper)
    return
        if ($xsl)
        then document { transform:transform($doc, $xsl, ()) }
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
        then document { transform:transform($doc, $xsl, ()) }
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


declare function tok:tokenize($doc as document-node(), $profile-id as xs:string, $format as xs:string) as item()* {
    let $nlRmd := tok:rmNl($doc, $profile-id),
        $toks := tok:toks($nlRmd, $profile-id),
        $pAdded := tok:addP($toks, $profile-id)
    return 
        switch($format)
            case "vert" return tok:tei2vert($pAdded, $profile-id)
            case "txt" return 
                let $vert := tok:tei2vert($pAdded, $profile-id)
                return tok:vert2txt($vert, $profile-id)
            case "doc" return $pAdded
            default return $pAdded
};
