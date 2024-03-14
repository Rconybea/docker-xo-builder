1. `nix build` fails with unexpected error:

```
       (stack trace truncated; use '--show-trace' to show the full trace)

       error: getting status of '/nix/store/986qfi9xign2cgcw4rklarfmwh9f4k90-source/pkgs': No such file or directory
```

This will happen after introducing new file `./pkgs/foo.nix`,  if it hasn't been committed to git,  so that it has a hash.

