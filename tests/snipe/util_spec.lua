local mock = require("luassert.mock")

describe("util:", function()
  local util = require("snipe.util")

  describe("merging_ts_ranges", function()
    local ts_utils_mock = mock(require("nvim-treesitter.ts_utils"), true)

    it("merges basic ranges", function()
      -- [1, 5], [3, 8] -> [1, 8]
      ts_utils_mock.get_node_range.returns(3, 0, 8, 0)
      local start_row, end_row = util.merge_ts_ranges(1, 5, {})
      assert.are.equal(start_row, 1)
      assert.are.equal(end_row, 8)

      -- [1, 5], [5, 8] -> [1, 8]
      ts_utils_mock.get_node_range.returns(5, 0, 8, 0)
      start_row, end_row = util.merge_ts_ranges(1, 5, {})
      assert.are.equal(start_row, 1)
      assert.are.equal(end_row, 8)

      -- [1, 5], [2, 3] -> [1, 5]
      ts_utils_mock.get_node_range.returns(2, 0, 3, 0)
      start_row, end_row = util.merge_ts_ranges(1, 5, {})
      assert.are.equal(start_row, 1)
      assert.are.equal(end_row, 5)
    end)

    it("ignores ranges that do not overlap", function()
      ts_utils_mock.get_node_range.returns(6, 0, 8, 0)
      local start_row, end_row = util.merge_ts_ranges(1, 5, {})
      assert.are.equal(start_row, 1)
      assert.are.equal(end_row, 5)
    end)
  end)
end)
