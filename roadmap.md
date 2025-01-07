# Roadmap

Phase 1, basic core functionality.

### Initial tool
[ ] Basic CLI that accepts commands (just print something per command for now)

[ ] Create a folder to store packages in i.e. ~/.zigpkg/ - this should be initialised only if the folder does not exist already

[ ] Create some configuration structure to track installed packages

[ ] Create functions that are the core for the install and remove commands. `install <url>` should download and install the tarball or git repo (idk what yet). `remove <package>` should remove the package from the filesystem. Both commands need to manipulate the config file.

[ ] Add the `list` command to list the installed packages and their versions.


Phase 2, go open source and try to create the ecosystem

[ ] Package index - A simple (for now) registry and collection of links for packages, with metadata.

[ ] Add a `search <term>` command to look for a specific package from the registry.

[ ] Dependency intergration - declare potential dependencies in a configuration file in the project. Automatically resolve and install dependencies if needed. (TODO: Check if ths is at all relevant).

[ ] Build system hook - Hook into the zig build system with a command like `link <package>` to generate a zig build file (build.zig.zon) to link and include the package(s) defined in the project packages file.

