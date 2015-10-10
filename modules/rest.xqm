xquery version "3.0";


module namespace api = "http://acdh.oeaw.ac.at/apps/xtoks/api";
declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace config = "http://acdh.oeaw.ac.at/apps/xtoks/config" at "config.xqm";
import module namespace tok = "http://acdh.oeaw.ac.at/apps/xtoks/tokenize" at "tok.xqm";
import module namespace profile = "http://acdh.oeaw.ac.at/apps/xtoks/profile" at "profile.xqm";


(: Remove Newlines :)
declare
    %rest:POST("{$data}")
    %rest:path("/xtoks/rmNl")
    %rest:consumes("application/xml")
    %rest:produces("application/xml")
function api:rmNl($data as document-node()) {
    tok:rmNl($data, ())
};





(: Tokenizer Endpoints :)
declare
    %rest:POST("{$data}")
    %rest:path("/xtoks/tokenize/{$profile-id}")
    %rest:query-param("format", "{$format}", "doc")
    %rest:consumes("application/xml")
    %rest:produces("application/xml")
    %output:method("xml")
    %output:encoding("UTF-8")
    %output:indent("yes")
function api:tokenize-xml($data as document-node(), $profile-id as xs:string, $format as xs:string*) {
    tok:tokenize($data, $profile-id, $format[1])
};


declare
    %rest:POST("{$data}")
    %rest:path("/xtoks/tokenize/{$profile-id}")
    %rest:consumes("application/xml")
    %rest:produces("text/plain")
    %output:method("text")
    %output:encoding("UTF-8")
function api:tokenize-txt($data as document-node(), $profile-id as xs:string) {
    tok:tokenize($data, $profile-id, "txt")
};





(: Profile Management :)
declare 
    %rest:GET 
    %rest:path("/xtoks/profile")
    %rest:produces("application/xml")
function api:list-profiles() {
    <profiles>{
        for $p in collection($config:profiles)//profile 
        return <profile id="{$p/@id}"/>
    }</profiles>
};

declare 
    %rest:GET 
    %rest:path("/xtoks/profile/{$profile-id}")
    %rest:produces("application/xml")
function api:read-profile($profile-id as xs:string){
    profile:read($profile-id)
};

declare 
    %rest:POST("{$data}") 
    %rest:path("/xtoks/profile")
    %rest:produces("application/xml")
    %rest:consumes("application/xml")
function api:create-profile($data as document-node()) {
    profile:create($data)
};

declare 
    %rest:PUT("{$data}") 
    %rest:path("/xtoks/profile/{$profile-id}")
    %rest:produces("application/xml")
    %rest:consumes("application/xml")
function api:update-profile($data as document-node(), $profile-id as xs:string) {
    let $update := profile:update($profile-id, $data)
    return profile:read($profile-id)
};

declare 
    %rest:DELETE 
    %rest:path("/xtoks/profile/{$profile-id}")
    %rest:produces("application/xml")
function api:delete-profile($profile-id as xs:string) {
    profile:delete($profile-id)
};