xquery version "3.0";

import module namespace config = "http://acdh.oeaw.ac.at/apps/xtoks/config" at "modules/config.xqm";

let $target-base-default := "/Users/Daniel/repo"
return 

<response>{
try{
(:    let $source  := request:get-parameter("source", $config:app-root):)
(:    let $target-base := request:get-parameter("target-base",$target-base-default):)
    let $app := file:sync($config:app-root, $target-base-default||"/xToks/src", ())
(:    let $xsl-tokenizer :=  file:sync($source||"/xsl-tokenizer", $target-base||"/xsl-tokenizer", ()):)
    return
        $app
(:        ($xsl-tokenizer,$app):)
    
    
} catch * {
    let $log := util:log("ERROR", ($err:code, $err:description) )
    return <ERROR>{($err:code, $err:description)}</ERROR>
}
}</response>