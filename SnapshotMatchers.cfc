component {

    function toMatchSnapshot( expectation, args = {} ) {
        param url.updateSnapshots = false;
        param args.snapshotDirectory = expandPath( "/tests/resources/snapshots" );

        if ( expectation.isNot ) {
            throw( type = "NotSupported", message = "`notToMatchSnapshot` is not supported." );
        }

        var isHTML = function( str ) {
            if ( ! isSimpleValue( str ) ) { return false; }
            return ! arrayIsEmpty( REMatch( "<[^>]+>", str ) );
        };

        // include function locally because closures
        var indentXML = function( xml, indent = "    " ) {
            var lines = "";
            var depth = "";
            var line = "";
            var isCDATAStart = "";
            var isCDATAEnd = "";
            var isEndTag = "";
            var isSelfClose = "";
            xml = trim(REReplace(xml, "(^|>)\s*(<|$)", "\1#chr(10)#\2", "all"));
            lines = listToArray(xml, chr(10));
            depth = 0;
            for ( i=1 ; i<=arrayLen(lines) ; i++ ) {
                line = trim(lines[i]);
                isCDATAStart = left(line, 9) == "<![CDATA[";
                isCDATAEnd = right(line, 3) == "]]>";
                if ( !isCDATAStart && !isCDATAEnd && left(line, 1) == "<" && right(line, 1) == ">" ) {
                    isEndTag = left(line, 2) == "</";
                    isSelfClose = right(line, 2) == "/>" || REFindNoCase("<([a-z0-9_-]*).*</\1>", line);
                    if ( isEndTag ) {
                        //  use max for safety against multi-line open tags 
                        depth = max(0, depth - 1);
                    }
                    lines[i] = repeatString(indent, depth) & line;
                    if ( !isEndTag && !isSelfClose ) {
                        depth = depth + 1;
                    }
                } else if ( isCDATAStart ) {
                    /* 
              we don't indent CDATA ends, because that would change the
              content of the CDATA, which isn't desirable
              */
                    lines[i] = repeatString(indent, depth) & line;
                }
            }
            return arrayToList(lines, chr(10));
        };

        // cache the spec since we use it over and over
        var thisSpec = expectation.getSpec();

        // create the snapshot directory provided if it doesn't exist
        if ( ! directoryExists( args.snapshotDirectory ) ) {
            directoryCreate( args.snapshotDirectory );
        }

        // keep track of all snapshot numbers by suite name
        if ( ! structKeyExists( thisSpec, "snapshotNumbers" ) ) {
            thisSpec.snapshotNumbers = {};
        }

        // create a file system safe file name
        var specFilename = getMetadata( thisSpec ).fullname;
        specFilename = replace( specFilename, "/", "__", "ALL" );
        specFilename = replace( specFilename, " ", "_", "ALL" );
        specFilename = replace( specFilename, ".", "_", "ALL" );
        specFilename = replace( specFilename, "`", "", "ALL" );

        var suiteName = thisSpec.$currentExecutingSpec;
        suiteName = replace( suiteName, "/", "__", "ALL" );
        suiteName = replace( suiteName, " ", "_", "ALL" );
        suiteName = replace( suiteName, ".", "_", "ALL" );
        suiteName = replace( suiteName, "`", "", "ALL" );

        // make sure we have an entry for this suite name
        if ( ! structKeyExists( thisSpec.snapshotNumbers, suiteName ) ) {
            thisSpec.snapshotNumbers[ suiteName ] = 1;
        }

        var snapshotFilename = "#specFilename##suiteName#-#thisSpec.snapshotNumbers[ suiteName ]#";
        var snapshotPath = "#args.snapshotDirectory#/#snapshotFilename#";

        // increment the snapshot number in case there are more snapshots in this suite
        thisSpec.snapshotNumbers[ suiteName ]++;

        if ( url.updateSnapshots ) {
            // xml includes html (which is our main use case)
            if ( isHTML( expectation.actual ) ) {
                fileWrite( snapshotPath & ".xml", indentXML( expectation.actual ) );
                thisSpec.debug( "Snapshot updated: [#snapshotFilename#.xml]" );
            }
            else {
                fileWrite( snapshotPath & ".json", serializeJSON( expectation.actual ) );
                thisSpec.debug( "Snapshot updated: [#snapshotFilename#.json]" );
            }
            return true;
        }

        if ( ! fileExists( snapshotPath & ".xml" ) && ! fileExists( snapshotPath & ".json" ) ) {
            expectation.message = "A new snapshot was found.  Run this test with the `updateSnapshots` url flag to create a new snapshot.";
            return false;
        }

        var contents = "";
        try {
            contents = fileRead( snapshotPath & ".xml" );
        }
        catch ( any e ) {
            contents = fileRead( snapshotPath & ".json" );
        }
        
        if ( isHTML( contents ) ) {
            if ( indentXML( expectation.actual ) == contents ) {
                return true;
            }

            try {
                var differ = createObject( "java", "difflib.DiffUtils" );
                var patch = differ.diff( contents.listToArray( "\n" ), indentXML( expectation.actual ).listToArray( "\n" ) );
                var changes = [];
                for ( var delta in patch.getDeltas() ) {
                    arrayAppend( changes, delta.toString() );
                }

                expectation.message = "The snapshots didn't match.  #changes.toList( " -- " )# (Hint: run with the `updateSnapshots` url flag to update this snapshot instead.";
            }
            catch ( any e ) {
                expectation.message = "The snapshots didn't match.  Actual: [#indentXML( expectation.actual )#]. Expected: [#contents#]. (Hint: run with the `updateSnapshots` url flag to update this snapshot instead.";
            }

            return false;
        }
        else {
            if ( serializeJSON( expectation.actual ) == contents ) {
                return true;
            }

            try {
                var differ = createObject( "java", "difflib.DiffUtils" );
                var patch = differ.diff( contents.listToArray( "\n" ), serializeJSON( expectation.actual ).listToArray( "\n" ) );
                var changes = [];
                for ( var delta in patch.getDeltas() ) {
                    arrayAppend( changes, delta.toString() );
                }

                expectation.message = "The snapshots didn't match.  #changes.toList( " -- " )# (Hint: run with the `updateSnapshots` url flag to update this snapshot instead.";
            }
            catch ( any e ) {
                expectation.message = "The snapshots didn't match.  Actual: [#serializeJSON( expectation.actual )#]. Expected: [#contents#]. (Hint: run with the `updateSnapshots` url flag to update this snapshot instead.";
            }

            return false;
        }
    }

}