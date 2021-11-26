local mock = require("luassert.mock")

describe("config:", function()
  local config = require("snipe.config")

  describe("setup", function()
    it("uses default targets", function()
      config.setup()
      local default_targets = {
        "function",
        "method_declaration",
        "function_declaration",
        "function_definition",
        "local_function",
        "class_declaration",
        "class_definition",
      }
      assert.are.same(config.options, { targets = default_targets })
    end)

    it("overrides default targets", function()
      config.setup({
        targets = {
          "test",
        },
      })
      assert.are.same(config.options, { targets = { "test" } })
    end)
  end)
end)
