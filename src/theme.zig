const std = @import("std");
const log = @import("log.zig");
const fsutil = @import("fsutil.zig");

pub const Theme = struct {
    accent: []const u8,
    accent_strong: []const u8,
    dim: []const u8,
    ghost: []const u8,
    highlight: []const u8,
    title_bg: []const u8 = "",
    reset: []const u8 = "\x1b[0m",
    bold: []const u8 = "\x1b[1m",
};

pub const Named = struct { name: []const u8, theme: Theme };

pub const red: Theme = .{
    .accent = "\x1b[38;5;196m",
    .accent_strong = "\x1b[1;38;5;196m",
    .dim = "\x1b[38;5;243m",
    .ghost = "\x1b[38;5;238m",
    .highlight = "\x1b[48;5;196m\x1b[38;5;231m",
};

pub const cyan: Theme = .{
    .accent = "\x1b[36m",
    .accent_strong = "\x1b[1;36m",
    .dim = "\x1b[2m",
    .ghost = "\x1b[38;5;240m",
    .highlight = "\x1b[7m",
};

pub const mono: Theme = .{
    .accent = "\x1b[37m",
    .accent_strong = "\x1b[1;37m",
    .dim = "\x1b[2m",
    .ghost = "\x1b[38;5;240m",
    .highlight = "\x1b[7m",
};

pub const dracula: Theme = .{
    .accent = "\x1b[38;5;141m",
    .accent_strong = "\x1b[1;38;5;141m",
    .dim = "\x1b[2m",
    .ghost = "\x1b[38;5;240m",
    .highlight = "\x1b[48;5;141m\x1b[38;5;232m",
};

pub const nord: Theme = .{
    .accent = "\x1b[38;5;110m",
    .accent_strong = "\x1b[1;38;5;110m",
    .dim = "\x1b[2m",
    .ghost = "\x1b[38;5;240m",
    .highlight = "\x1b[48;5;110m\x1b[38;5;232m",
};

pub const gruvbox: Theme = .{
    .accent = "\x1b[38;5;214m",
    .accent_strong = "\x1b[1;38;5;214m",
    .dim = "\x1b[38;5;243m",
    .ghost = "\x1b[38;5;240m",
    .highlight = "\x1b[48;5;214m\x1b[38;5;232m",
};

pub const tokyonight: Theme = .{
    .accent = "\x1b[38;5;111m",
    .accent_strong = "\x1b[1;38;5;111m",
    .dim = "\x1b[38;5;60m",
    .ghost = "\x1b[38;5;238m",
    .highlight = "\x1b[48;5;111m\x1b[38;5;235m",
};

pub const catppuccin: Theme = .{
    .accent = "\x1b[38;5;183m",
    .accent_strong = "\x1b[1;38;5;183m",
    .dim = "\x1b[38;5;103m",
    .ghost = "\x1b[38;5;240m",
    .highlight = "\x1b[48;5;183m\x1b[38;5;235m",
};

pub const matrix: Theme = .{
    .accent = "\x1b[38;5;46m",
    .accent_strong = "\x1b[1;38;5;46m",
    .dim = "\x1b[38;5;65m",
    .ghost = "\x1b[38;5;22m",
    .highlight = "\x1b[48;5;46m\x1b[38;5;232m",
};

pub const rosepine: Theme = .{
    .accent = "\x1b[38;5;168m",
    .accent_strong = "\x1b[1;38;5;168m",
    .dim = "\x1b[38;5;245m",
    .ghost = "\x1b[38;5;240m",
    .highlight = "\x1b[48;5;168m\x1b[38;5;235m",
};

pub const solarized: Theme = .{
    .accent = "\x1b[38;5;37m",
    .accent_strong = "\x1b[1;38;5;136m",
    .dim = "\x1b[38;5;66m",
    .ghost = "\x1b[38;5;239m",
    .highlight = "\x1b[48;5;37m\x1b[38;5;235m",
};

pub const default: Theme = red;

pub const all = [_]Named{
    .{ .name = "red", .theme = red },
    .{ .name = "cyan", .theme = cyan },
    .{ .name = "mono", .theme = mono },
    .{ .name = "dracula", .theme = dracula },
    .{ .name = "nord", .theme = nord },
    .{ .name = "gruvbox", .theme = gruvbox },
    .{ .name = "tokyonight", .theme = tokyonight },
    .{ .name = "catppuccin", .theme = catppuccin },
    .{ .name = "matrix", .theme = matrix },
    .{ .name = "rosepine", .theme = rosepine },
    .{ .name = "solarized", .theme = solarized },
};

pub fn byName(name: []const u8) ?Theme {
    if (indexOf(name)) |i| return all[i].theme;
    if (std.mem.eql(u8, name, "yt") or std.mem.eql(u8, name, "youtube")) return red;
    if (std.mem.eql(u8, name, "default")) return default;
    return null;
}

pub fn indexOf(name: []const u8) ?usize {
    for (all, 0..) |n, i| {
        if (std.mem.eql(u8, n.name, name)) return i;
    }
    return null;
}

pub const names = blk: {
    var s: []const u8 = "";
    for (all, 0..) |n, i| s = s ++ (if (i == 0) "" else ", ") ++ n.name;
    break :blk s;
};

pub fn find(list: []const Named, name: []const u8) ?usize {
    for (list, 0..) |n, i| {
        if (std.mem.eql(u8, n.name, name)) return i;
    }
    if (std.mem.eql(u8, name, "yt") or std.mem.eql(u8, name, "youtube") or std.mem.eql(u8, name, "default")) {
        if (std.mem.eql(u8, name, "red")) return null;
        return find(list, "red");
    }
    return null;
}

pub fn joinNames(arena: std.mem.Allocator, list: []const Named) []const u8 {
    var out: std.ArrayList(u8) = .empty;
    for (list, 0..) |n, i| {
        if (i > 0) out.appendSlice(arena, ", ") catch return names;
        out.appendSlice(arena, n.name) catch return names;
    }
    return out.items;
}

pub const Style = struct {
    fg: ?[]const u8 = null,
    bg: ?[]const u8 = null,
    bold: bool = false,
    faint: bool = false,
    italic: bool = false,
    underline: bool = false,
    reverse: bool = false,
};

pub const Spec = struct {
    base: []const u8 = "default",
    accent: ?Style = null,
    accent_strong: ?Style = null,
    dim: ?Style = null,
    ghost: ?Style = null,
    highlight: ?Style = null,
    bold: ?Style = null,
};

const slots = .{ "accent", "accent_strong", "dim", "ghost", "highlight", "bold" };

pub const MAX_FILE_BYTES = 16 * 1024;
pub const MAX_USER_THEMES = 64;

pub const Error = error{ OutOfMemory, UnknownBase, BadColor };

pub fn fromSpec(arena: std.mem.Allocator, spec: Spec) Error!Theme {
    var th = byName(spec.base) orelse return error.UnknownBase;
    inline for (slots) |f| {
        if (@field(spec, f)) |st| @field(th, f) = try sgr(arena, st);
    }
    return th;
}

pub fn sgr(arena: std.mem.Allocator, st: Style) Error![]const u8 {
    var params: std.ArrayList(u8) = .empty;
    const attrs = [_]struct { on: bool, code: []const u8 }{
        .{ .on = st.bold, .code = "1" },
        .{ .on = st.faint, .code = "2" },
        .{ .on = st.italic, .code = "3" },
        .{ .on = st.underline, .code = "4" },
        .{ .on = st.reverse, .code = "7" },
    };
    for (attrs) |a| if (a.on) try appendParam(arena, &params, a.code);
    if (st.fg) |c| try appendParam(arena, &params, try colorParam(arena, 38, c));
    if (st.bg) |c| try appendParam(arena, &params, try colorParam(arena, 48, c));
    if (params.items.len == 0) return "";
    return std.fmt.allocPrint(arena, "\x1b[{s}m", .{params.items});
}

fn appendParam(arena: std.mem.Allocator, params: *std.ArrayList(u8), p: []const u8) !void {
    if (params.items.len > 0) try params.append(arena, ';');
    try params.appendSlice(arena, p);
}

fn colorParam(arena: std.mem.Allocator, layer: u8, c: []const u8) Error![]const u8 {
    if (c.len == 7 and c[0] == '#') {
        const rgb = std.fmt.parseInt(u24, c[1..], 16) catch return error.BadColor;
        return std.fmt.allocPrint(arena, "{d};2;{d};{d};{d}", .{ layer, rgb >> 16, (rgb >> 8) & 0xff, rgb & 0xff });
    }
    const idx = std.fmt.parseInt(u8, c, 10) catch return error.BadColor;
    return std.fmt.allocPrint(arena, "{d};5;{d}", .{ layer, idx });
}

pub fn parse(gpa: std.mem.Allocator, arena: std.mem.Allocator, source: [:0]const u8, file: []const u8) ?Theme {
    var diag: std.zon.parse.Diagnostics = undefined;
    const spec = std.zon.parse.fromSlice(Spec, .{
        .gpa = gpa,
        .arena = arena,
        .source = source,
        .diagnostics = &diag,
    }) catch |err| {
        if (err == error.ParseZon) log.write("theme {f}", .{diag.fmt(file)}) else log.write("theme {s}: {s}", .{ file, @errorName(err) });
        return null;
    };
    return fromSpec(arena, spec) catch |err| {
        switch (err) {
            error.UnknownBase => log.write("theme {s}: unknown base \"{s}\" (built-ins: {s})", .{ file, spec.base, names }),
            error.BadColor => log.write("theme {s}: colors are \"#rrggbb\" or a 256-color index like \"214\"", .{file}),
            error.OutOfMemory => log.write("theme {s}: out of memory", .{file}),
        }
        return null;
    };
}

pub fn load(gpa: std.mem.Allocator, arena: std.mem.Allocator, io: std.Io, dir_path: []const u8) []const Named {
    var out: std.ArrayList(Named) = .empty;
    out.appendSlice(arena, &all) catch return &all;
    var dir = std.Io.Dir.openDirAbsolute(io, dir_path, .{ .iterate = true }) catch return out.items;
    defer dir.close(io);

    var user: std.ArrayList(Named) = .empty;
    var it = dir.iterate();
    while (it.next(io) catch null) |entry| {
        if (user.items.len >= MAX_USER_THEMES) break;
        if (entry.kind != .file or !std.mem.endsWith(u8, entry.name, ".zon")) continue;
        const stem = entry.name[0 .. entry.name.len - ".zon".len];
        if (stem.len == 0) continue;
        const full = std.fmt.allocPrint(arena, "{s}/{s}", .{ dir_path, entry.name }) catch continue;
        const bytes = fsutil.readCappedAlloc(arena, full, MAX_FILE_BYTES) orelse continue;
        const source = arena.dupeSentinel(u8, bytes, 0) catch continue;
        const th = parse(gpa, arena, source, entry.name) orelse continue;
        const name = arena.dupe(u8, stem) catch continue;
        user.append(arena, .{ .name = name, .theme = th }) catch break;
    }
    std.mem.sort(Named, user.items, {}, struct {
        fn lt(_: void, a: Named, b: Named) bool {
            return std.mem.lessThan(u8, a.name, b.name);
        }
    }.lt);
    for (user.items) |u| {
        if (indexOf(u.name)) |i| out.items[i] = u else out.append(arena, u) catch break;
    }
    return out.items;
}

const testing = std.testing;

test "byName resolves known names, aliases, and default" {
    try testing.expectEqualStrings(red.accent, byName("red").?.accent);
    try testing.expectEqualStrings(nord.accent, byName("nord").?.accent);
    try testing.expectEqualStrings(red.accent, byName("yt").?.accent);
    try testing.expectEqualStrings(red.accent, byName("youtube").?.accent);
    try testing.expectEqualStrings(default.accent, byName("default").?.accent);
    try testing.expect(byName("nonexistent") == null);
}

test "indexOf matches all and only declared themes" {
    try testing.expectEqual(@as(?usize, 0), indexOf("red"));
    try testing.expectEqual(@as(?usize, 1), indexOf("cyan"));
    try testing.expectEqual(@as(?usize, all.len - 1), indexOf("solarized"));
    try testing.expect(indexOf("yt") == null);
}

test "names is generated from the all table" {
    try testing.expectEqualStrings("red, cyan, mono, dracula, nord, gruvbox, tokyonight, catppuccin, matrix, rosepine, solarized", names);
}

test "sgr builds truecolor, 256-color and attribute sequences" {
    var aa: std.heap.ArenaAllocator = .init(testing.allocator);
    defer aa.deinit();
    const a = aa.allocator();
    try testing.expectEqualStrings("\x1b[38;2;255;221;51m", try sgr(a, .{ .fg = "#ffdd33" }));
    try testing.expectEqualStrings("\x1b[1;38;5;214m", try sgr(a, .{ .fg = "214", .bold = true }));
    try testing.expectEqualStrings("\x1b[38;2;24;24;24;48;2;255;221;51m", try sgr(a, .{ .fg = "#181818", .bg = "#ffdd33" }));
    try testing.expectEqualStrings("\x1b[2m", try sgr(a, .{ .faint = true }));
    try testing.expectEqualStrings("", try sgr(a, .{}));
    try testing.expectError(error.BadColor, sgr(a, .{ .fg = "#ffdd3" }));
    try testing.expectError(error.BadColor, sgr(a, .{ .fg = "256" }));
    try testing.expectError(error.BadColor, sgr(a, .{ .bg = "yellow" }));
}

test "parse fills omitted slots from base" {
    var aa: std.heap.ArenaAllocator = .init(testing.allocator);
    defer aa.deinit();
    const a = aa.allocator();
    const th = parse(testing.allocator, a, ".{ .base = \"nord\", .accent = .{ .fg = \"#ffdd33\" } }", "t.zon").?;
    try testing.expectEqualStrings("\x1b[38;2;255;221;51m", th.accent);
    try testing.expectEqualStrings(nord.highlight, th.highlight);
    try testing.expectEqualStrings(nord.dim, th.dim);
    const plain = parse(testing.allocator, a, ".{}", "t.zon").?;
    try testing.expectEqualStrings(default.accent, plain.accent);
}

test "parse rejects unknown fields, bad colors and unknown bases" {
    var aa: std.heap.ArenaAllocator = .init(testing.allocator);
    defer aa.deinit();
    const a = aa.allocator();
    try testing.expect(parse(testing.allocator, a, ".{ .accnet = .{ .fg = \"#ffffff\" } }", "t.zon") == null);
    try testing.expect(parse(testing.allocator, a, ".{ .dim = .{ .fg = \"grey\" } }", "t.zon") == null);
    try testing.expect(parse(testing.allocator, a, ".{ .base = \"nope\" }", "t.zon") == null);
    try testing.expect(parse(testing.allocator, a, ".{ .accent = ", "t.zon") == null);
}

test "find resolves aliases against a merged list" {
    const custom: Theme = .{ .accent = "A", .accent_strong = "", .dim = "", .ghost = "", .highlight = "" };
    const list = [_]Named{ .{ .name = "red", .theme = red }, .{ .name = "mine", .theme = custom } };
    try testing.expectEqual(@as(?usize, 1), find(&list, "mine"));
    try testing.expectEqual(@as(?usize, 0), find(&list, "youtube"));
    try testing.expectEqual(@as(?usize, 0), find(&list, "default"));
    try testing.expect(find(&list, "nord") == null);
    try testing.expect(find(list[1..], "default") == null);
}
