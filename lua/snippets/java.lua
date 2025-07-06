-- ~/.config/nvim/lua/snippets/java.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep

return {
  s("main", {
    t({ "public static void main(String[] args) {", "    " }),
    i(1, 'System.out.println("Hello")'),
    t({ "", "}" }),
  }),

  s("getter", {
    t({ "public " }), i(1, "Type"), t({ " get" }), i(2, "FieldName"), t({ "() {", "    " }),
    t({ "return this." }), i(3, "field"), t({ ";", "}" }),
  }),

  s("setter", {
    t({ "public void set" }), i(1, "FieldName"), t({ "(" }), i(2, "Type"), t({ " " }),
    i(3, "field"), t({ ") {", "    " }), t({ "this." }), i(4, "field"), t({ " = " }),
    i(5, "field"), t({ ";", "}" }),
  }),

  s("constructor", {
    t({ "public " }), i(1, "ClassName"), t({ "(" }), i(2, "Type"), t({ " " }), i(3, "field"),
    t({ ") {", "    " }), t({ "this." }), i(4, "field"), t({ " = " }), i(5, "field"),
    t({ ";", "}" }),
  }),

  s("staticClass", {
    t({ "public static class " }), i(1, "ClassName"), t({ " {", "    " }),
    i(2, "Field"), t({ ";", "", "}" }),
  }),

  s("staticInterface", {
    t({ "public static interface " }), i(1, "InterfaceName"), t({ " {", "    " }),
    i(2, "Method"), t({ "();", "", "}" }),
  }),

  -- Class template
  s("class", {
    t({ "public class " }), i(1, "ClassName"), t({ " {", "    // Fields", "    " }),
    i(2, "private Type field;"), t({ "", "    // Constructors", "    " }),
    i(3, "public ClassName() {}"), t({ "", "    // Methods", "    " }),
    i(4, "public void foo() { }"), t({ "", "}" }),
  }),

  -- System.out shortcut
  s("sout", {
    t("System.out.println("), i(1, '"message"'), t({ ");" }),
  }),

  -- Try-catch block
  s("trycatch", {
    t({ "try {", "    " }), i(1, "// code"), t({ "", "} catch (" }),
    i(2, "Exception e"), t({ ") {", "    " }),
    t({ "e.printStackTrace();" }), i(3, ""), t({ "", "}" }),
  }),

  -- For loop (index)
  s("fori", {
    t({ "for (int " }), i(1, "i"), t({ " = 0; " }), rep(1), t({ " < " }), i(2, "n"),
    t({ "; " }), rep(1), t({ "++) {", "    " }),
    i(3, "// TODO"), t({ "", "}" }),
  }),

  -- Enhanced for loop
  s("foreach", {
    t({ "for (" }), i(1, "Type"), t({ " " }), i(2, "item"), t({ " : " }),
    i(3, "collection"), t({ ") {", "    " }), i(4, "// TODO"), t({ "", "}" }),
  }),

  -- Enum template
  s("enum", {
    t({ "public enum " }), i(1, "EnumName"), t({ " {", "    " }),
    i(2, "VALUE1, VALUE2;"), t({ "", "    // fields, constructors, methods", "    " }),
    i(3, ""), t({ "", "}" }),
  }),

  -- Record template
  s("record", {
    t({ "public record " }), i(1, "RecordName"), t({ "(" }),
    i(2, "Type field"), t({ ") {", "    " }),
    i(3, "// body"), t({ "", "}" }),
  }),

  -- Static record template
  s("staticRecord", {
    t({ "public static record " }), i(1, "RecordName"), t({ "(" }),
    i(2, "Type field"), t({ ") {", "    " }),
    i(3, "// body"), t({ "", "}" }),
  }),
}
