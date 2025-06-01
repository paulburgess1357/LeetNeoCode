-- Display formatter for user statistics
local M = {}

-- Create a progress bar visualization
local function create_progress_bar(percentage, length, filled_char, empty_char)
  length = length or 20
  filled_char = filled_char or "█"
  empty_char = empty_char or "░"

  local filled_length = math.floor((percentage / 100) * length)
  local empty_length = length - filled_length

  return string.rep(filled_char, filled_length) .. string.rep(empty_char, empty_length)
end

-- Create a difficulty distribution chart
local function create_difficulty_chart(stats)
  local chart_lines = {}

  table.insert(chart_lines, "📊 Problem Difficulty Distribution:")
  table.insert(chart_lines, "")

  -- Easy problems (Green theme)
  local easy_bar = create_progress_bar(stats.difficulty_distribution.easy, 25, "🟩", "⬜")
  table.insert(chart_lines, string.format("🟢 Easy:   %s %d%% (%d solved)",
    easy_bar, stats.difficulty_distribution.easy, stats.problems.easy.solved))

  -- Medium problems (Orange theme)
  local medium_bar = create_progress_bar(stats.difficulty_distribution.medium, 25, "🟨", "⬜")
  table.insert(chart_lines, string.format("🟡 Medium: %s %d%% (%d solved)",
    medium_bar, stats.difficulty_distribution.medium, stats.problems.medium.solved))

  -- Hard problems (Red theme)
  local hard_bar = create_progress_bar(stats.difficulty_distribution.hard, 25, "🟥", "⬜")
  table.insert(chart_lines, string.format("🔴 Hard:   %s %d%% (%d solved)",
    hard_bar, stats.difficulty_distribution.hard, stats.problems.hard.solved))

  return chart_lines
end

-- Create contest performance section
local function create_contest_section(stats)
  local lines = {}

  if stats.contest.attended > 0 then
    table.insert(lines, "🏆 Contest Performance:")
    table.insert(lines, "")
    table.insert(lines, string.format("   Contests Attended: %d", stats.contest.attended))
    table.insert(lines, string.format("   Current Rating: %d", stats.contest.rating))

    if stats.contest.global_ranking > 0 then
      table.insert(lines, string.format("   Global Ranking: #%d", stats.contest.global_ranking))
    end

    if stats.contest.top_percentage > 0 then
      table.insert(lines, string.format("   Top %.1f%% of participants", stats.contest.top_percentage))
    end

    if stats.contest.badge ~= "" then
      table.insert(lines, string.format("   Badge: %s", stats.contest.badge))
    end
  else
    table.insert(lines, "🏆 Contest Performance: No contests attended yet")
  end

  return lines
end

-- Create achievements section
local function create_achievements_section(stats)
  local lines = {}

  table.insert(lines, "🏅 Achievements & Recognition:")
  table.insert(lines, "")

  if stats.total_badges > 0 then
    table.insert(lines, string.format("   Total Badges Earned: %d", stats.total_badges))
  end

  if stats.active_badge ~= "" then
    table.insert(lines, string.format("   Active Badge: %s", stats.active_badge))
  end

  if stats.upcoming_badges > 0 then
    table.insert(lines, string.format("   Badges in Progress: %d", stats.upcoming_badges))
  end

  if stats.ranking > 0 then
    table.insert(lines, string.format("   Global Ranking: #%d", stats.ranking))
  end

  if stats.total_badges == 0 and stats.ranking == 0 then
    table.insert(lines, "   Keep solving problems to earn achievements! 💪")
  end

  return lines
end

-- Create recent activity section
local function create_recent_activity(stats)
  local lines = {}

  if #stats.recent_solved > 0 then
    table.insert(lines, "⚡ Recent Problem Solves:")
    table.insert(lines, "")

    for i, problem in ipairs(stats.recent_solved) do
      local time_ago = "Unknown date"
      if problem.timestamp and problem.timestamp > 0 then
        time_ago = os.date("%Y-%m-%d", problem.timestamp)
      end
      table.insert(lines, string.format("   %d. %s (%s)", i, problem.title, time_ago))
    end
  else
    table.insert(lines, "⚡ Recent Activity: No recent submissions found")
  end

  return lines
end

-- Main function to show stats notification with improved error handling
function M.show_stats_notification(username, stats)
  -- Validate inputs
  if not username or username == "" then
    vim.notify("❌ Invalid username provided", vim.log.levels.ERROR)
    return false
  end

  if not stats or type(stats) ~= "table" then
    vim.notify("❌ Invalid stats data provided", vim.log.levels.ERROR)
    return false
  end

  local lines = {}

  -- Header with user info
  table.insert(lines, string.format("🧩 LeetCode Stats for @%s", username))

  if stats.real_name and stats.real_name ~= "" then
    table.insert(lines, string.format("👤 %s", stats.real_name))
  end

  if stats.location and stats.location ~= "" then
    table.insert(lines, string.format("📍 %s", stats.location))
  end

  table.insert(lines, string.rep("═", 60))
  table.insert(lines, "")

  -- Overall stats section
  table.insert(lines, "📈 Overall Performance:")
  table.insert(lines, "")
  table.insert(lines, string.format("   Total Problems Solved: %d", stats.problems.total_solved))
  table.insert(lines, string.format("   Total Submissions: %d", stats.problems.total_submissions))
  table.insert(lines, string.format("   Acceptance Rate: %d%%", stats.acceptance_rate))

  if stats.streak and stats.streak > 0 then
    table.insert(lines, string.format("   Current Streak: %d days 🔥", stats.streak))
  end

  table.insert(lines, "")

  -- Add difficulty distribution chart
  local success, chart_lines = pcall(create_difficulty_chart, stats)
  if success and chart_lines then
    for _, line in ipairs(chart_lines) do
      table.insert(lines, line)
    end
  else
    table.insert(lines, "📊 Problem distribution data not available")
  end

  table.insert(lines, "")

  -- Add contest performance
  local contest_success, contest_lines = pcall(create_contest_section, stats)
  if contest_success and contest_lines then
    for _, line in ipairs(contest_lines) do
      table.insert(lines, line)
    end
  else
    table.insert(lines, "🏆 Contest data not available")
  end

  table.insert(lines, "")

  -- Add achievements
  local achievement_success, achievement_lines = pcall(create_achievements_section, stats)
  if achievement_success and achievement_lines then
    for _, line in ipairs(achievement_lines) do
      table.insert(lines, line)
    end
  else
    table.insert(lines, "🏅 Achievement data not available")
  end

  table.insert(lines, "")

  -- Add recent activity
  local activity_success, activity_lines = pcall(create_recent_activity, stats)
  if activity_success and activity_lines then
    for _, line in ipairs(activity_lines) do
      table.insert(lines, line)
    end
  else
    table.insert(lines, "⚡ Recent activity data not available")
  end

  table.insert(lines, "")
  table.insert(lines, "💡 Keep grinding! Every problem solved is progress! 🚀")

  -- Show the notification with improved error handling
  local notify_success, result = pcall(function()
    local notify = require "LeetNeoCode.utils.ui.notify"
    local timeout = 15000 -- 15 seconds for stats
    return notify.persistent_notification(lines, timeout, true)
  end)

  if not notify_success then
    -- Fallback to simple notification
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
    return false
  end

  return result
end

return M
