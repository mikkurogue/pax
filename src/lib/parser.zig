//! This is the parser file for the .zon extension files.
//! We need to still figure out how we can read the file(s)
//! even if they are not in the project directory.
//!
//! This is because using json is fine, but parsing json into
//! the zon format for a struct seems to be a pain in the ass.
//! If we can import the file, as it is "comptime known"
//! meaning we can also extract the properties from it.

const std = @import("std");
