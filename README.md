# TestBox Snapshots

## Use snapshot testing to easily prevent regressions in TestBox

Snapshot testing was recently popularized by Facebook's [Jest testing framework for Javascript](https://facebook.github.io/jest/).  The idea is that rather than test a specific return value, we test against a regression in a return value.

### Adding the Matcher

To add the matcher, pass in the path to the `SnapshotMatchers.cfc` file in your `beforeAll` method:

```cfc
component extends="" {
    
    function beforeAll() {
        addMatchers( "testbox-snapshots.SnapshotMatchers" );
    }

}
```

### Matching Snapshots

Any value can be used with the new matcher `toMatchSnapshot()`:

```cfc
function run() {
    describe( "my spec", function() {
        it( "matches a snapshot", function() {
            expect( {
                name = "Eric",
                job = "Web Developer"
            } ).toMatchSnapshot();
        } );
    } );
}
```

It is automatically converted behind the scenes to either XML or JSON.  The XML format intelligently ignores whitespace making it perfect for HTML snapshots.

Snapshots are stored by a combination of file name, suite name, and spec name.  If any of those change, the snapshot will need to be updated.

Multiple snapshots can be stored in a single spec.  In this case, the order of the snapshots matters and is used to distinguish the snapshots.

Please note, there is no `notToMatchSnapshot` matcher.

### Updating Snapshots

To create an inital snapshot or to update a snapshot, the url flag `updateSnapshots` must be passed.

> **Take care! Snapshots will be updated for all ran tests with this url flag.  Make sure you are only running the tests you want to update before adding the flag.**

Any tests that update a snapshot will pass that matcher.

### Diffing

If you would like a more targeted diff output, add the following line to your `tests/Application.cfc`:

```cfc
this.javaSettings = { loadPaths = [ "testbox-snapshots/lib" ], reloadOnChange = false };
```

This adds a Java library that will provide a more targeted diff than otherwise is possible.  If this line is not included, the package will fall back to showing the entire contents.