-- ~/.config/nvim/lua/snippets/javascriptreact.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.functional

return {
  -- React functional component
  s("rfc", {
    t({ "const " }), i(1, "Component"), t({ " = () => {", "\treturn (" }),
    t({ "", "\t\t<div>" }), i(2, "Content"), t({ "</div>", "\t);", "};" }),
  }),

  -- Console log
  s("clg", {
    t("console.log("), i(1, '"value"'), t(");"),
  }),

  -- useState
  s("us", {
    t("const ["), i(1, "state"), t(", "), i(2, "setState"), t("] = useState("), i(3, "initial"), t(");"),
  }),

  -- s("us", {
  --   t("const ["), i(1, "state"), t(", "),
  --   f(function(args)
  --     local name = args[1][1]
  --     return "set" .. name:sub(1, 1):upper() .. name:sub(2)
  --   end, { 1 }),
  --   t("] = useState("), i(2, "initial"), t(");"),
  -- }),

}
