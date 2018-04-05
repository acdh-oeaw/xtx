# xtx - An XML tokenizer

This is a simple exist-db application providing RESTful endpoints for tokenizing XML documents. It is a simple wrapper for the transformations at <https://github.com/acdh-oeaw/xsl-tokenizer>.

## Building

calling `ant` inside of the cloned root directory builds a `xar` package which can be deployed into exist-db via the package manager. After installation you find a description of the endpoints at http://localhost:8080/exist/apps/xtx/index.html.
