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
}
