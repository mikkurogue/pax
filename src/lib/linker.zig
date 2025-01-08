/// This file is the initial linker, to link packages to a zig project
/// from the cli.
/// aka when the command `zigpkg link <package>` is fired
/// this has the logic to actually link the package to the project,
/// update the build file and build the project to complete the link
/// its not as seamless of an idea that npm has for isntance
/// but it gives the user more control
/// we can automate the zigpkg install command to also automtically link
/// if we are in a zig project directory
const std = @import("std");
