-- ~/.config/nvim/lua/snippets/rust.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {

  -- Rust function
  s("fn", {
    t({ "fn " }), i(1, "function_name"), t("("), i(2, "args"), t({ ") {", "\t" }),
    i(3, "println!(\"Hello\")"), t({ "", "}" }),
  }),

  -- Rust struct
  s("struct", {
    t({ "struct " }), i(1, "StructName"), t({ " {", "\t" }),
    i(2, "field: Type"), t({ "", "}" }),
  }),

  -- Rust enum
  s("enum", {
    t({ "enum " }), i(1, "EnumName"), t({ " {", "\t" }),
    i(2, "Variant1"), t({ ",", "\t" }),
    i(3, "Variant2"), t({ "", "}" }),
  }),

  -- Rust trait
  s("trait", {
    t({ "trait " }), i(1, "TraitName"), t({ " {", "\t" }),
    i(2, "fn method(&self);"), t({ "", "}" }),
  }),
}
