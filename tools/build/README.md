# Build Tools

## build.bat

Builds deployment-ready configuration files.

Usage:

```
    build <output_location> <substitution_list>
```

where:

* `output_location` is the location where the configuration files should be placed.
* `substitution_list` is the path to the placeholder substitution file.

## build4dev.bat

Generates configuration files into a development copy of the GateKeeper source tree

Usage:

```
    build4dev <output_location> <substitution_list> [--deploy-only]
```

where:

* `output_location` is the base directory where the configuration files should be placed.
                      (e.g. The base of the GateKeeper source tree.)
* `substitution_list` is the path to the placeholder substitution file.

* --deploy-only (optional) - if specified, only the files which are included in
                              a deployment are generated.
