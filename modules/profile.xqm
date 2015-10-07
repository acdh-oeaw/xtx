xquery version "3.0";

module namespace profile = "http://acdh.oeaw.ac.at/apps/xtoks/profile";
declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

import module namespace config = "http://acdh.oeaw.ac.at/apps/xtoks/config" at "config.xqm";

declare function profile:home($id as xs:string) {
    let $path := $config:profiles||"/"||$id
    return 
        if (doc-available($path||"/profile.xml"))
        then $path
        else ()
};

declare function profile:create($profile as document-node()) {
    let $id := $profile/profile/@id
    return
        if ($id)
        then (
            xmldb:create-collection($config:profiles, $id), 
            xmldb:store($config:profiles||"/"||$id, "profile.xml", $profile)
        )
        else () 
};

declare function profile:read($id as xs:string) {
    collection($config:profiles)//profile[@id = $id]
};

declare function profile:update($id as xs:string, $data as document-node()) {
    let $profile-home := profile:home($id)
    return xmldb:store($profile-home, "profile.xml", $data)
};

declare function profile:delete($id as xs:string) {
    let $profile-home := profile:home($id)
    return xmldb:remove($profile-home) 
};

declare function profile:prepare($id as xs:string) {
    (:get the profile:)
    let $profile := profile:read($id)
    
    (: since the original "make_xsl.xsl" makes use of xsl:result-document 
       (which does not work in exist-db) we have to make some exist-db-specific 
       adjustments to it :)
    let $make_xsl := if (doc-available($config:make_xsl)) then doc($config:make_xsl) else ()
    let $make_xsl_existdb as document-node() := 
        let $tr := transform:transform($make_xsl, doc($config:prep_make_xsl_existdb), ())
        return 
        if (doc-available($config:xsls||"/make_xsl_existdb.xsl"))
        then doc($config:xsls||"/make_xsl_existdb.xsl")
        else doc(xmldb:store($config:xsls, "make_xsl_existdb.xsl", $tr))
    let $stylesheets := transform:transform($profile, $make_xsl_existdb, ())
    return 
        for $s in $stylesheets
        return xmldb:store(profile:home($id), $s/@xml:id||".xsl", $s)
};