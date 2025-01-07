# Roadmap

## Phase 1, basic core functionality.
### Potentially recruit/find people to include in this phase?

[x] Basic CLI that accepts commands (just print something per command for now) - Needs to support windows (sadly)
[] Each "run" of the CLI can only fire 1 command at a time. So `zigpkg install PACKAGENAME list` wont work, only `zigpkg install PACKAGENAME` and then afterwards `zigpkg list`. This is to simplify the argument parsing and the UX overhead 

[ ] Create a folder to store packages in i.e. ~/.zigpkg/ - this should be initialised only if the folder does not exist already

[ ] Use the [Zon](https://zon.dev/) to create the necessary configs. in ~/.zigpkg/packages.zon as the manifest that has the files. and in the project folder a packages.zon file to use to link packages to the build.zig.zon to make them available in the project. (later step)

[ ] Create functions that are the core for the install and remove commands. `install <url>` should download and install the tarball or git repo (idk what yet). `remove <package>` should remove the package from the filesystem. Both commands need to manipulate the config file.

[ ] Add the `list` command to list the installed packages and their versions.


## Phase 2, 

[ ] Package index - A simple (for now) registry and collection of links for packages, with metadata.

[ ] Add a `search <term>` command to look for a specific package from the registry.

[ ] Dependency intergration - declare potential dependencies in a configuration file in the project. Automatically resolve and install dependencies if needed. (TODO: Check if ths is at all relevant).

[ ] Build system hook - Hook into the zig build system with a command like `link <package>` to generate a zig build file (build.zig.zon) to link and include the package(s) defined in the project packages file.

