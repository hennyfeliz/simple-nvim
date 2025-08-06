-- Improved and extended Java snippets for LuaSnip

local luasnip = require("luasnip")
local snippet = luasnip.snippet
local text_node = luasnip.text_node
local insert_node = luasnip.insert_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt
local func = luasnip.function_node

-- Capitalize helper
local function capitalize(args)
  local str = args[1][1] or ""
  return (str:gsub("^%l", string.upper))
end

return {
  snippet("main", {
    text_node({ "public static void main(String[] args) {", "    " }),
    insert_node(1, 'System.out.println("Hello, world!");'),
    text_node({ "", "}" }),
  }),

  snippet("getter", {
    text_node("public "),
    insert_node(1, "Type"),
    text_node(" get"),
    func(capitalize, { 2 }),
    text_node({ "() {", "    return this." }),
    insert_node(2, "field"),
    text_node({ ";", "}" }),
  }),

  snippet("setter", {
    text_node("public void set"),
    func(capitalize, { 1 }),
    text_node("("),
    insert_node(2, "Type"),
    text_node(" "),
    insert_node(1, "field"),
    text_node({ ") {", "    this." }),
    rep(1),
    text_node(" = "),
    rep(1),
    text_node({ ";", "}" }),
  }),

  snippet("constructor", {
    text_node("public "),
    insert_node(1, "ClassName"),
    text_node("("),
    insert_node(2, "Type"),
    text_node(" "),
    insert_node(3, "field"),
    text_node({ ") {", "    this." }),
    rep(3),
    text_node(" = "),
    rep(3),
    text_node({ ";", "}" }),
  }),

  snippet("staticClass", {
    text_node("public static class "),
    insert_node(1, "ClassName"),
    text_node({ " {", "    " }),
    insert_node(2, "// fields and methods"),
    text_node({ "", "}" }),
  }),

  snippet("staticInterface", {
    text_node("public static interface "),
    insert_node(1, "InterfaceName"),
    text_node({ " {", "    " }),
    insert_node(2, "// method signatures"),
    text_node({ "", "}" }),
  }),

  snippet("class", {
    text_node("public class "),
    insert_node(1, "ClassName"),
    text_node({ " {", "    // Fields", "    " }),
    insert_node(2, "private Type field;"),
    text_node({ "", "    // Constructors", "    " }),
    insert_node(3, "public "),
    rep(1),
    text_node("() { }"),
    text_node({ "", "    // Methods", "    " }),
    insert_node(4, "public void foo() { }"),
    text_node({ "", "}" }),
  }),

  snippet("sout", {
    text_node("System.out.println("),
    insert_node(1, '"message"'),
    text_node({ ");" }),
  }),

  snippet("trycatch", {
    text_node({ "try {", "    " }),
    insert_node(1, "// code that may throw exception"),
    text_node({ "", "} catch (" }),
    insert_node(2, "Exception e"),
    text_node({ ") {", "    e.printStackTrace();", "}" }),
  }),

  snippet("trywith", {
    text_node("try ("),
    insert_node(1, "ResourceType resource = new ResourceType()"),
    text_node({ ") {", "    " }),
    insert_node(2, "// use resource"),
    text_node({ "", "} catch (" }),
    insert_node(3, "Exception e"),
    text_node({ ") {", "    e.printStackTrace();", "}" }),
  }),

  snippet("fori", {
    text_node("for (int "),
    insert_node(1, "i"),
    text_node(" = 0; "),
    rep(1),
    text_node(" < "),
    insert_node(2, "n"),
    text_node("; "),
    rep(1),
    text_node({ "++) {", "    " }),
    insert_node(3, "// TODO"),
    text_node({ "", "}" }),
  }),

  snippet("foreach", {
    text_node("for ("),
    insert_node(1, "Type"),
    text_node(" "),
    insert_node(2, "item"),
    text_node(" : "),
    insert_node(3, "collection"),
    text_node({ ") {", "    " }),
    insert_node(4, "// TODO"),
    text_node({ "", "}" }),
  }),

  snippet("enum", {
    text_node("public enum "),
    insert_node(1, "EnumName"),
    text_node({ " {", "    " }),
    insert_node(2, "VALUE1, VALUE2;"),
    text_node({ "", "", "    // fields, constructors, methods", "    " }),
    insert_node(3, "// TODO"),
    text_node({ "", "}" }),
  }),

  snippet("record", {
    text_node("public record "),
    insert_node(1, "RecordName"),
    text_node("("),
    insert_node(2, "Type field"),
    text_node({ ") {", "    " }),
    insert_node(3, "// additional methods"),
    text_node({ "", "}" }),
  }),

  snippet("staticRecord", {
    text_node("public static record "),
    insert_node(1, "RecordName"),
    text_node("("),
    insert_node(2, "Type field"),
    text_node({ ") {", "    " }),
    insert_node(3, "// additional methods"),
    text_node({ "", "}" }),
  }),

  snippet("sealedClass", {
    text_node("public sealed class "),
    insert_node(1, "ClassName"),
    text_node(" permits "),
    insert_node(2, "SubClass1, SubClass2"),
    text_node({ " {", "    " }),
    insert_node(3, "// class body"),
    text_node({ "", "}" }),
  }),

  snippet("sealedInterface", {
    text_node("public sealed interface "),
    insert_node(1, "InterfaceName"),
    text_node(" permits "),
    insert_node(2, "ImplementingClass1, ImplementingClass2"),
    text_node({ " {", "    " }),
    insert_node(3, "// abstract methods"),
    text_node({ "", "}" }),
  }),

  snippet("equhash", {
    text_node("@Override\npublic boolean equals(Object obj) {\n    if (this == obj) return true;\n    if (obj == null || getClass() != obj.getClass()) return false;\n    "),
    insert_node(1, "ClassName"),
    text_node(" other = ("),
    rep(1),
    text_node(") obj;\n    return java.util.Objects.equals("),
    insert_node(2, "field1"),
    text_node(", other."),
    rep(2),
    text_node(") && java.util.Objects.equals("),
    insert_node(3, "field2"),
    text_node(", other."),
    rep(3),
    text_node({ ");\n}\n\n@Override\npublic int hashCode() {\n    return java.util.Objects.hash(" }),
    rep(2),
    text_node(", "),
    rep(3),
    text_node({ ");\n}" }),
  }),

  snippet("tostring", {
    text_node("@Override\npublic String toString() {\n    return "),
    insert_node(1, '"ClassName{" + "field=" + field + "}"'),
    text_node({ ";\n}" }),
  }),

  snippet("switchExpr", {
    text_node("var result = switch ("),
    insert_node(1, "variable"),
    text_node({ ") {", "    case " }),
    insert_node(2, "VALUE1"),
    text_node(", "),
    insert_node(3, "VALUE2"),
    text_node({ " -> {\n        " }),
    insert_node(4, "// statements"),
    text_node({ "\n        yield " }),
    insert_node(5, "value"),
    text_node({ ";", "    }", "    default -> {\n        " }),
    insert_node(6, "// default case"),
    text_node({ "\n        yield " }),
    insert_node(7, "defaultValue"),
    text_node({ ";", "    }", "};" }),
  }),

  snippet("case", {
    text_node("case "),
    insert_node(1, "value"),
    text_node(" -> "),
    insert_node(2, "// result"),
    text_node(";"),
  }),

  snippet("lambda", {
    insert_node(1, "item"),
    text_node(" -> "),
    insert_node(2, "/* expression */"),
  }),

  snippet("const", {
    text_node("public static final "),
    insert_node(1, "Type"),
    text_node(" "),
    insert_node(2, "CONSTANT_NAME"),
    text_node(" = "),
    insert_node(3, "value"),
    text_node(";"),
  }),
}

