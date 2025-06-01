-- API fetcher for LeetCode user statistics
local M = {}

-- Debug function to log API response
local function debug_response(response, username)
  if vim.g.leetcode_debug then
    vim.notify("Debug: API Response for " .. username .. ":\n" .. vim.inspect(response), vim.log.levels.DEBUG)
  end
end

-- Fallback function to get basic stats from public profile page
local function fetch_public_profile_fallback(username)
  local cmd = {
    "curl",
    "-s",
    "-L",
    "https://leetcode.com/" .. username .. "/",
    "-H",
    "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
  }

  local resp = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return nil, "Network error accessing profile page"
  end

  -- Try to extract basic stats from the HTML page
  local stats = {
    username = username,
    problems_solved = 0,
    easy_solved = 0,
    medium_solved = 0,
    hard_solved = 0,
    acceptance_rate = 0,
    ranking = 0
  }

  -- Look for problem counts in the HTML
  local solved_pattern = '"solvedProblem":(%d+)'
  local easy_pattern = '"easySolved":(%d+)'
  local medium_pattern = '"mediumSolved":(%d+)'
  local hard_pattern = '"hardSolved":(%d+)'
  local ranking_pattern = '"ranking":(%d+)'

  local total_match = resp:match(solved_pattern)
  local easy_match = resp:match(easy_pattern)
  local medium_match = resp:match(medium_pattern)
  local hard_match = resp:match(hard_pattern)
  local ranking_match = resp:match(ranking_pattern)

  if total_match then stats.problems_solved = tonumber(total_match) end
  if easy_match then stats.easy_solved = tonumber(easy_match) end
  if medium_match then stats.medium_solved = tonumber(medium_match) end
  if hard_match then stats.hard_solved = tonumber(hard_match) end
  if ranking_match then stats.ranking = tonumber(ranking_match) end

  if stats.problems_solved > 0 then
    return stats, nil
  else
    return nil, "Could not extract stats from profile page"
  end
end

-- Fetch user profile data from LeetCode GraphQL API
function M.fetch_user_data(username)
  -- First try the simpler userPublicProfile query
  local simple_query = [[
    query userPublicProfile($username: String!) {
      matchedUser(username: $username) {
        username
        profile {
          realName
          userAvatar
          location
          ranking
        }
        submitStatsGlobal {
          acSubmissionNum {
            difficulty
            count
            submissions
          }
        }
      }
    }
  ]]

  local payload = vim.fn.json_encode({
    query = simple_query,
    variables = { username = username }
  })

  local cmd = {
    "curl",
    "-s",
    "-X", "POST",
    "https://leetcode.com/graphql",
    "-H", "Content-Type: application/json",
    "-H", "Accept: application/json",
    "-H", "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
    "-H", "Origin: https://leetcode.com",
    "-H", "Referer: https://leetcode.com/problemset/",
    "-d", payload,
  }

  local resp = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Network error, trying fallback method...", vim.log.levels.WARN)
    return fetch_public_profile_fallback(username)
  end

  local ok, decoded = pcall(vim.fn.json_decode, resp)
  if not ok then
    debug_response(resp, username)
    vim.notify("JSON parse error, trying fallback method...", vim.log.levels.WARN)
    return fetch_public_profile_fallback(username)
  end

  debug_response(decoded, username)

  -- Check for errors in response
  if decoded.errors then
    local error_msg = "GraphQL errors: "
    for _, error in ipairs(decoded.errors) do
      error_msg = error_msg .. (error.message or "Unknown error") .. "; "
    end
    vim.notify(error_msg .. " Trying fallback method...", vim.log.levels.WARN)
    return fetch_public_profile_fallback(username)
  end

  if not decoded.data then
    vim.notify("No data in response, trying fallback method...", vim.log.levels.WARN)
    return fetch_public_profile_fallback(username)
  end

  if not decoded.data.matchedUser then
    return nil, "User '" .. username .. "' not found"
  end

  -- Try to get contest data with a separate query (optional)
  local contest_data = nil
  local contest_query = [[
    query userContestRanking($username: String!) {
      userContestRanking(username: $username) {
        attendedContestsCount
        rating
        globalRanking
        topPercentage
      }
    }
  ]]

  local contest_payload = vim.fn.json_encode({
    query = contest_query,
    variables = { username = username }
  })

  local contest_cmd = {
    "curl",
    "-s",
    "-X", "POST",
    "https://leetcode.com/graphql",
    "-H", "Content-Type: application/json",
    "-H", "Accept: application/json",
    "-H", "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
    "-H", "Origin: https://leetcode.com",
    "-H", "Referer: https://leetcode.com/problemset/",
    "-d", contest_payload,
  }

  local contest_resp = vim.fn.system(contest_cmd)
  if vim.v.shell_error == 0 then
    local contest_ok, contest_decoded = pcall(vim.fn.json_decode, contest_resp)
    if contest_ok and contest_decoded and contest_decoded.data then
      contest_data = contest_decoded.data.userContestRanking
    end
  end

  return {
    user = decoded.data.matchedUser,
    contest = contest_data
  }, nil
end

return M
