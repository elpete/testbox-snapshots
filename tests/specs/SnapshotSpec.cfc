component extends="testbox.system.BaseSpec" {

    variables.SNAPSHOT_DIRECTORY = expandPath( "/tests/resources/snapshots" );

    function beforeAll() {
        addMatchers( "root.SnapshotMatchers" );
    }

    function run() {
        describe( "snapshot assertions", function() {
            afterEach( function() {
                if ( directoryExists( SNAPSHOT_DIRECTORY ) ) {
                    directoryDelete( SNAPSHOT_DIRECTORY, true );
                }
                url.updateSnapshots = false;
            } );

            it( "creates a snapshots directory under `tests/resources/snapshots` if it doesn't exist", function() {
                expect( directoryExists( SNAPSHOT_DIRECTORY ) )
                    .toBeFalse( "Snapshot directory should not exist to start the test." );

                url.updateSnapshots = true;
                expect( 1 ).toMatchSnapshot();

                expect( directoryExists( SNAPSHOT_DIRECTORY ) )
                    .toBeTrue( "Snapshot directory should exist now that a snapshot has been created." );
            } );

            it( "warns if a snapshot does not exist", function() {
                expect(function() {
                    expect( 1 ).toMatchSnapshot();
                }).toThrow( regex = "A new snapshot was found\.  Run this test with the \`updateSnapshots\` url flag to create a new snapshot\." );
            } );

            it( "creates any new snapshots when passed with the `updateSnapshots` url flag", function() {
                url.updateSnapshots = true;
                expect( 1 ).toMatchSnapshot();

                expect( fileExists( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__creates_any_new_snapshots_when_passed_with_the_updateSnapshots_url_flag-1.json" ) ).toBeTrue();
            } );

            it( "file names are created with an auto incrementing id", function() {
                url.updateSnapshots = true;
                expect( 1 ).toMatchSnapshot();
                expect( 1 ).toMatchSnapshot();

                expect( fileExists( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__file_names_are_created_with_an_auto_incrementing_id-1.json" ) ).toBeTrue();
                expect( fileExists( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__file_names_are_created_with_an_auto_incrementing_id-2.json" ) ).toBeTrue();
                expect( fileExists( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__file_names_are_created_with_an_auto_incrementing_id-3.json" ) ).toBeFalse();
            } );

            it( "the content of the file is the value of the expectation", function() {
                url.updateSnapshots = true;
                expect( 1 ).toMatchSnapshot();

                expect( fileExists( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__the_content_of_the_file_is_the_value_of_the_expectation-1.json" ) ).toBeTrue();

                var fileContents = fileRead( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__the_content_of_the_file_is_the_value_of_the_expectation-1.json" );

                expect( fileContents ).toBe( 1, "The content of the file should be the value of the expectation" );
            } );

            it( "passes if a snapshot already exists and the file contents are the same", function() {
                url.updateSnapshots = true;
                expect( 1 ).toMatchSnapshot();

                expect( fileExists( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__passes_if_a_snapshot_already_exists_and_the_file_contents_are_the_same-1.json" ) ).toBeTrue();

                url.updateSnapshots = false;
                this.snapshotNumbers[ "__snapshot_assertions__passes_if_a_snapshot_already_exists_and_the_file_contents_are_the_same" ] = 1;

                expect( function() {
                    expect( 1 ).toMatchSnapshot();
                } ).notToThrow();
            } );

            it( "fails if a snapshot already exists and the file contents are different", function() {
                url.updateSnapshots = true;
                expect( 1 ).toMatchSnapshot();

                expect( fileExists( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__fails_if_a_snapshot_already_exists_and_the_file_contents_are_different-1.json" ) ).toBeTrue();

                url.updateSnapshots = false;
                this.snapshotNumbers[ "__snapshot_assertions__fails_if_a_snapshot_already_exists_and_the_file_contents_are_different" ] = 1;

                expect( function() {
                    expect( 2 ).toMatchSnapshot();
                } ).toThrow( regex = "The snapshots didn't match\.  Actual\: \[2\]\. Expected\: \[1\]\. \(Hint\: run with the \`updateSnapshots\` url flag to update this snapshot instead\." );
            } );

            it( "works with json data types as well", function() {
                url.updateSnapshots = true;
                expect( { name = "Wile E. Coyote", address = { street = "123 Elm Street", city = "Acme", state = "CA", zipcode = "90210" } } ).toMatchSnapshot();

                expect( fileExists( SNAPSHOT_DIRECTORY & "/tests_specs_SnapshotSpec__snapshot_assertions__works_with_json_data_types_as_well-1.json" ) ).toBeTrue();

                url.updateSnapshots = false;
                this.snapshotNumbers[ "__snapshot_assertions__works_with_json_data_types_as_well" ] = 1;

                expect( function() {
                    expect( { name = "Wile E. Coyote", address = { street = "123 Elm Street", city = "Acme", state = "CA", zipcode = "90211" } } ).toMatchSnapshot();
                } ).toThrow();
            } );

            it( "works with html formats", function() {
                savecontent variable="local.html" {
                    writeOutput( "
                        <div id=""app"">
                            <h1>Hello, world!</h1>
                        </div>
                    " );
                }

                url.updateSnapshots = true;
                expect( function() {
                    expect( html ).toMatchSnapshot();
                } ).notToThrow();

                savecontent variable="local.whitespaceDifferentHtml" {
                    writeOutput( "
                        <div id=""app"">
                                <h1>Hello, world!</h1>
                           </div>
                    " );
                }

                url.updateSnapshots = false;
                this.snapshotNumbers[ "__snapshot_assertions__works_with_html_formats" ] = 1;

                expect( function() {
                    expect( whitespaceDifferentHtml ).toMatchSnapshot();
                } ).notToThrow();

                url.updateSnapshots = false;
                this.snapshotNumbers[ "__snapshot_assertions__works_with_html_formats" ] = 1;

                savecontent variable="local.newHtml" {
                    writeOutput( "
                        <div id=""app"">
                            <h1>Hello, ColdBox!</h1>
                        </div>
                    " );
                }

                expect( function() {
                    expect( newHtml ).toMatchSnapshot();
                } ).toThrow();
            } );

            it( "doesn't support the `not` functionality of expectations", function() {
                expect( function() {
                    expect( "foo" ).notToMatchSnapshot();
                } ).toThrow( regex = "\`notToMatchSnapshot\` is not supported\." );
            } );
        } );
    }

}