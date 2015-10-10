xquery version "3.0";

module namespace tok = "http://acdh.oeaw.ac.at/apps/xtoks/tokenize";
import module namespace config = "http://acdh.oeaw.ac.at/apps/xtoks/config" at "config.xqm";
import module namespace profile = "http://acdh.oeaw.ac.at/apps/xtoks/profile" at "profile.xqm";

declare function tok:rmNl ($doc as document-node(), $profile-id as xs:string?) as document-node() {
    let $path-to-xsl := $config:tokenizer-home||"/xsl/rmNl.xsl",
        $xsl := doc($path-to-xsl)
    return document { transform:transform($doc, $xsl, ()) }
};

declare function tok:toks($doc as document-node(), $profile-id as xs:string) as item() {
    let $profile := profile:home($profile-id),
        $path-to-wrapper := $profile||"/wrapper_toks.xsl",
        $xsl := if (doc-available($path-to-wrapper)) then doc($path-to-wrapper) else ()
    return
        if ($xsl)
        then document { transform:transform($doc, $xsl, ()) }
        else ()
};

declare function tok:addP($doc as document-node(), $profile-id as xs:string) as item() {
    let $profile := profile:home($profile-id),
        $path-to-wrapper := $profile||"/wrapper_addP.xsl",
        $xsl := if (doc-available($path-to-wrapper)) then doc($path-to-wrapper) else ()
    return
        if ($xsl)
        then document { transform:transform($doc, $xsl, ()) }
        else ()
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
            default return $pAdded
};
