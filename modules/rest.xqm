xquery version "3.0";


module namespace api = "http://acdh.oeaw.ac.at/apps/xtx/api";
declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace config = "http://acdh.oeaw.ac.at/apps/xtx/config" at "config.xqm";
import module namespace tok = "http://acdh.oeaw.ac.at/apps/xtx/tokenize" at "tok.xqm";
import module namespace profile = "http://acdh.oeaw.ac.at/apps/xtx/profile" at "profile.xqm";


(: Remove Newlines :)
declare
    %rest:POST("{$data}")
    %rest:path("/xtx/rmNl")
    %rest:consumes("application/xml")
    %rest:produces("application/xml")
    %tok:desc("Preparatory Step: Removes all insignificant newlines from the input document")
function api:rmNl($data as document-node()) {
    tok:rmNl($data, ())
};




(: either return the tokenized document (format = doc) or a xml vertical (format = vert):)
declare
    %rest:POST("{$data}")
    %rest:path("/xtx/tokenize/{$profile-id}")
    %rest:query-param("format", "{$format}", "doc")
    %rest:consumes("application/xml")
    %rest:produces("application/xml")
    %output:method("xml")
    %output:indent("yes")
    %tok:desc("Tokenize the document according to the selected profile and return either the original file with inlined tokens (?format=doc, default) or a vertical TEI/XML document with a flat token sequence (?format=vert). ")
function api:tokenize-xml($data as document-node(), $profile-id as xs:string, $format as xs:string*) {
    if (profile:home($profile-id) != "")
    then tok:tokenize($data, $profile-id, $format[.!=''][1])
    else <error>unknown profile {$profile-id}</error>
};

(: make a plain text vertical of document :)
declare
    %rest:POST("{$data}")
    %rest:path("/xtx/tokenize/{$profile-id}")
    %rest:consumes("application/xml")
    %rest:produces("text/plain")
    %output:method("text")
    %tok:desc("Tokenize the document according to the selected profile and return a verticalized plain text file. ")
function api:tokenize-txt($data as document-node(), $profile-id as xs:string) {
    if (profile:home($profile-id) != "")
    then tok:tokenize($data, $profile-id, "txt")
    else <error>unknown profile {$profile-id}</error>
};
 

(: Make vertical of document with tokens :)
declare
    %rest:POST("{$data}")
    %rest:path("/xtx/verticalize/{$profile-id}")
    %rest:consumes("application/xml")
    %rest:produces("text/plain")
    %output:method("text")
    %tok:desc("Create a plain text vertical out of an XML document with inlined tokens.")
function api:verticalize($data as document-node(), $profile-id as xs:string) {
    if (profile:home($profile-id) != "")
    then 
        let $vert := tok:tei2vert($data, $profile-id)
        return tok:vert2txt($vert, $profile-id)
    else <error>unknown profile {$profile-id}</error> 
};


(: Profile Management :)
declare 
    %rest:GET 
    %rest:path("/xtx/profile")
    %rest:produces("application/xml")
    %output:method("xml")
    %output:indent("yes")
    %tok:desc("List available tokenization profiles.")
function api:list-profiles() {
    <profiles>{
            for $p in collection($config:profiles)//profile 
            return <profile id="{$p/@id}" created="{$p/@created}" last-updated="{$p/@last-updated}">{$p/about}</profile>
    }</profiles>
};

declare 
    %rest:GET 
    %rest:path("/xtx/profile/{$profile-id}")
    %rest:produces("application/xml")
    %tok:desc("Get tokenization profile with ID {$profile-id}.")
function api:read-profile($profile-id as xs:string){
    profile:read($profile-id)
};

declare 
    %rest:POST("{$data}") 
    %rest:path("/xtx/profile")
    %rest:produces("application/xml")
    %rest:consumes("application/xml")
    %tok:desc("Create a new tokenization profile.")
function api:create-profile($data as document-node()) {
    let $log := config:log(("Creating new profile: ", $data))
    let $id := profile:create($data)
    return profile:read($id)
};

declare 
    %rest:PUT("{$data}") 
    %rest:path("/xtx/profile/{$profile-id}")
    %rest:produces("application/xml")
    %rest:consumes("application/xml")
    %tok:desc("Update tokenization profile with ID {$profile-id}.")
function api:update-profile($data as document-node(), $profile-id as xs:string) {
    if (profile:home($profile-id) != "")
    then 
        let $update := profile:update($profile-id, $data)
        return profile:read($profile-id)
    else <error>unknown profile {$profile-id}</error> 
};

declare 
    %rest:DELETE 
    %rest:path("/xtx/profile/{$profile-id}")
    %rest:produces("application/xml")
    %tok:desc("Delete tokenization profile with ID {$profile-id}.")
function api:delete-profile($profile-id as xs:string) {
    if (profile:home($profile-id) != "")
    then 
        profile:delete($profile-id)
    else <error>unknown profile {$profile-id}</error>
};