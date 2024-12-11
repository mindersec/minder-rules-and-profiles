# Minder Rules and Profiles

A repository containing Minder rules and profiles recommended by your friends at Stacklok

# Rules types

Reference rule types are available in the `rule-types` directory. To take these rule types
into use, you'll need to instantiate them in a Minder instance. For example, to use the
reference rules recommended for GitHub, use the following command:
    
```bash
minder ruletype create -f rule-types/github
```

# Profiles

Reference profiles are available in the `profiles` directory. To take a profile
into use, you'll need to instantiate it in a Minder instance. For example, to use the
reference profile recommended for GitHub, use the following command:

```bash
minder profile create -f profiles/github/profile.yaml
```

# Data Sources

Reference data sources are available in the `data-sources` directory. To take a data source
into use, you'll need to instantiate it in a Minder instance. For example, to instantiate the
reference data source for using OSV as a data source, use the following command:

```bash
minder datasource create -f data-sources osv.yaml
```

