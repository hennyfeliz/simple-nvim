-- ~/.config/nvim/lua/snippets/java.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("main", {
    t({ "public static void main(String[] args) {", "\t" }), i(1, "System.out.println(\"Hello\")"),
    t({ "", "}" }),
  }),

  s("getter", {
    t({ "public " }), i(1, "Type"), t({ " get" }), i(2, "FieldName"), t({ "() {", "\t" }),
    t({ "return this." }), i(3, "field"), t({ ";", "}" }),
  }),

  s("setter", {
    t({ "public void set" }), i(1, "FieldName"), t({ "(" }), i(2, "Type"), t({ " " }),
    i(3, "field"), t({ ") {", "\t" }), t({ "this." }), i(4, "field"), t({ " = " }),
    i(5, "field"), t({ ";", "}" }),
  }),

  s("constructor", {
    t({ "public " }), i(1, "ClassName"), t({ "(" }), i(2, "Type"), t({ " " }), i(3, "field"),
    t({ ") {", "\t" }), t({ "this." }), i(4, "field"), t({ " = " }), i(5, "field"),
    t({ ";", "}" }),
  }),

  s("staticClass", {
    t({ "public static class " }), i(1, "ClassName"), t({ " {", "\t" }),
    i(2, "Field"), t({ ";", "", "}" }),
  }),

  s("staticInterface", {
    t({ "public static interface " }), i(1, "InterfaceName"), t({ " {", "\t" }),
    i(2, "Method"), t({ "();", "", "}" }),
  }),
}
