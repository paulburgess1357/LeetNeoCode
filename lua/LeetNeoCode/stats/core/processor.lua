-- Core processor for user statistics data
local M = {}

-- Helper function to safely check if a value is a valid table
local function is_valid_table(value)
  return type(value) == "table" and value ~= vim.NIL
end

-- Helper function to safely get a value from a table
local function safe_get(table, key, default)
  if not is_valid_table(table) then
    return default
  end
  local value = table[key]
  if value == vim.NIL then
    return default
  end
  return value or default
end

-- Process raw user data into displayable statistics
function M.process_user_data(raw_data)
  local stats = {
    username = "",
    real_name = "",
    location = "",
    ranking = 0,

    -- Problem solving stats
    problems = {
      easy = { solved = 0, total_submissions = 0 },
      medium = { solved = 0, total_submissions = 0 },
      hard = { solved = 0, total_submissions = 0 },
      total_solved = 0,
      total_submissions = 0
    },

    -- Contest stats
    contest = {
      attended = 0,
      rating = 0,
      global_ranking = 0,
      top_percentage = 0,
      badge = ""
    },

    -- Recent activity
    recent_solved = {},
    streak = 0,

    -- Badges
    total_badges = 0,
    active_badge = "",
    upcoming_badges = 0,

    -- Calculated metrics
    acceptance_rate = 0,
    difficulty_distribution = { easy = 0, medium = 0, hard = 0 }
  }

  -- Handle fallback data structure (from HTML scraping)
  if raw_data and raw_data.problems_solved then
    stats.username = raw_data.username or ""
    stats.problems.total_solved = raw_data.problems_solved or 0
    stats.problems.easy.solved = raw_data.easy_solved or 0
    stats.problems.medium.solved = raw_data.medium_solved or 0
    stats.problems.hard.solved = raw_data.hard_solved or 0
    stats.ranking = raw_data.ranking or 0
    stats.acceptance_rate = raw_data.acceptance_rate or 0

    -- Calculate difficulty distribution
    if stats.problems.total_solved > 0 then
      stats.difficulty_distribution.easy = math.floor((stats.problems.easy.solved / stats.problems.total_solved) * 100 + 0.5)
      stats.difficulty_distribution.medium = math.floor((stats.problems.medium.solved / stats.problems.total_solved) * 100 + 0.5)
      stats.difficulty_distribution.hard = math.floor((stats.problems.hard.solved / stats.problems.total_solved) * 100 + 0.5)
    end

    return stats
  end

  -- Handle GraphQL API response structure
  local user = safe_get(raw_data, "user", {})
  local contest = safe_get(raw_data, "contest", {})

  if is_valid_table(user) then
    stats.username = safe_get(user, "username", "")

    local profile = safe_get(user, "profile", {})
    if is_valid_table(profile) then
      stats.real_name = safe_get(profile, "realName", "")
      stats.location = safe_get(profile, "location", "")
      stats.ranking = safe_get(profile, "ranking", 0)
    end

    -- Process submission statistics (try different possible field names)
    local submit_stats = safe_get(user, "submitStatsGlobal", nil) or safe_get(user, "submitStats", {})
    if is_valid_table(submit_stats) then
      local ac_submissions = safe_get(submit_stats, "acSubmissionNum", {})
      if is_valid_table(ac_submissions) then
        for _, submission in ipairs(ac_submissions) do
          if is_valid_table(submission) then
            local difficulty = safe_get(submission, "difficulty", ""):lower()
            local count = safe_get(submission, "count", 0)
            local submissions = safe_get(submission, "submissions", 0)

            if stats.problems[difficulty] then
              stats.problems[difficulty].solved = count
              stats.problems[difficulty].total_submissions = submissions
              stats.problems.total_solved = stats.problems.total_solved + count
              stats.problems.total_submissions = stats.problems.total_submissions + submissions
            end
          end
        end
      end
    end

    -- Calculate acceptance rate
    if stats.problems.total_submissions > 0 then
      stats.acceptance_rate = math.floor((stats.problems.total_solved / stats.problems.total_submissions) * 100 + 0.5)
    end

    -- Calculate difficulty distribution
    if stats.problems.total_solved > 0 then
      stats.difficulty_distribution.easy = math.floor((stats.problems.easy.solved / stats.problems.total_solved) * 100 + 0.5)
      stats.difficulty_distribution.medium = math.floor((stats.problems.medium.solved / stats.problems.total_solved) * 100 + 0.5)
      stats.difficulty_distribution.hard = math.floor((stats.problems.hard.solved / stats.problems.total_solved) * 100 + 0.5)
    end

    -- Process recent submissions
    local recent_submissions = safe_get(user, "recentAcSubmissionList", {})
    if is_valid_table(recent_submissions) then
      for i, submission in ipairs(recent_submissions) do
        if i <= 5 and is_valid_table(submission) then -- Only show top 5
          table.insert(stats.recent_solved, {
            title = safe_get(submission, "title", "Unknown Problem"),
            timestamp = safe_get(submission, "timestamp", 0)
          })
        end
      end
    end

    -- Process badges
    local badges = safe_get(user, "badges", {})
    if is_valid_table(badges) then
      stats.total_badges = #badges
    end

    local active_badge = safe_get(user, "activeBadge", {})
    if is_valid_table(active_badge) then
      stats.active_badge = safe_get(active_badge, "displayName", "")
    end

    local upcoming_badges = safe_get(user, "upcomingBadges", {})
    if is_valid_table(upcoming_badges) then
      stats.upcoming_badges = #upcoming_badges
    end

    -- Process streak
    stats.streak = safe_get(user, "streak", 0)
  end

  -- Process contest data safely
  if is_valid_table(contest) then
    stats.contest.attended = safe_get(contest, "attendedContestsCount", 0)
    stats.contest.rating = safe_get(contest, "rating", 0)
    stats.contest.global_ranking = safe_get(contest, "globalRanking", 0)
    stats.contest.top_percentage = safe_get(contest, "topPercentage", 0)

    local contest_badge = safe_get(contest, "badge", {})
    if is_valid_table(contest_badge) then
      stats.contest.badge = safe_get(contest_badge, "name", "")
    end
  end

  return stats
end

return M
