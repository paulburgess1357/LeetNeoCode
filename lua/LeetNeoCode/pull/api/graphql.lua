-- GraphQL API utilities for LeetCode
local vim = vim
local C = require "LeetNeoCode.config"

local M = {}

-- Perform a GraphQL request to LeetCode API and return decoded table
function M.request(query, variables)
  local payload = vim.fn.json_encode {
    query = query,
    variables = variables
  }

  local slug = variables.titleSlug or ""
  local cmd = {
    "curl",
    "-s",
    "https://leetcode.com/graphql",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Origin: https://leetcode.com",
    "-H",
    "Referer: https://leetcode.com/problems/" .. slug .. "/",
    "-d",
    payload,
  }

  local resp = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return nil, "Curl error: " .. vim.v.shell_error
  end

  local ok, decoded = pcall(vim.fn.json_decode, resp)
  if not ok then
    return nil, "JSON decode error"
  end

  if not decoded or not decoded.data then
    return nil, "Invalid response format"
  end

  return decoded.data, nil
end

return M
