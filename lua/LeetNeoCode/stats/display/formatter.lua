-- Enhanced display formatter for user statistics with cool visualizations
local M = {}
local C = require "LeetNeoCode.config"

-- Collection of serious motivational quotes - grinding focused
local MOTIVATIONAL_QUOTES = {
  "🔥 When you want to succeed as bad as you want to breathe, then you'll find a way! - Eric Thomas",
  "💪 Champions don't become champions in the ring. They become champions in their training! - Eric Thomas",
  "⚡ Pain is temporary. Quitting lasts forever. Keep grinding!",
  "🚀 You can't cheat the grind. It knows how much you've invested!",
  "💎 The grind never stops. When you're tired, keep going!",
  "🎯 Success isn't given. It's earned in the gym, on the field, and at the keyboard!",
  "🔥 Stop looking for shortcuts. The magic happens in the struggle!",
  "💪 Your why has to be stronger than your excuses! Code through the pain!",
  "⭐ Comfort is the enemy of greatness. Get uncomfortable with hard problems!",
  "🌟 When you conquer one fear, it gives you strength to conquer others!",
  "🔥 You have to want success as much as you want to breathe! No days off!",
  "🎯 Excuses will always be there for you. Opportunities won't!",
  "💎 The moment you give up is the moment you let someone else win!",
  "🚀 Don't cry to quit. You already in pain, you already hurt. Get a reward from it! - Eric Thomas",
  "⚡ The only thing between you and your goal is the story you tell yourself!",
  "🔥 Champions don't stay down. They get up, dust off, and code again!",
  "💪 When it gets hard, that's when champions separate from everyone else!",
  "🌟 Your dedication to the craft will determine your level of success!",
  "🎯 Beast mode isn't a mode, it's a lifestyle! Code like your life depends on it!",
  "💎 While others sleep, champions are grinding! Stay hungry!",
  "⚡ You can't become legendary without doing legendary things! Push harder!",
  "🔥 The algorithm doesn't care about your feelings. Neither should you!",
  "💪 Success is a process, not an event. Trust the process! - Eric Thomas",
  "🚀 Most people fail because they major in minor things. Focus on what matters!",
  "⭐ Every master was once a disaster. Keep pushing through!"
}

-- Get a random motivational quote
local function get_random_quote()
  math.randomseed(os.time())
  return MOTIVATIONAL_QUOTES[math.random(#MOTIVATIONAL_QUOTES)]
end

-- Create ASCII art for problem counts with bars
local function create_ascii_stats_bar(easy, medium, hard)
  local total = easy + medium + hard
  if total == 0 then
    return {"📊 No problems solved yet - time to start! 🎯"}
  end

  local max_width = 40
  local easy_width = math.floor((easy / total) * max_width)
  local medium_width = math.floor((medium / total) * max_width)
  local hard_width = max_width - easy_width - medium_width

  local lines = {}
  table.insert(lines, "📊 Problem Solving Journey:")
  table.insert(lines, "")
  table.insert(lines, "+" .. string.rep("-", max_width + 2) .. "+")
  table.insert(lines, "| " .. string.rep("🟢", easy_width) .. string.rep("🟡", medium_width) .. string.rep("🔴", hard_width) .. " |")
  table.insert(lines, "+" .. string.rep("-", max_width + 2) .. "+")
  table.insert(lines, string.format("   🟢 Easy: %d   🟡 Medium: %d   🔴 Hard: %d", easy, medium, hard))

  return lines
end

-- Create a progress bar visualization with custom styling
local function create_progress_bar(percentage, length, style)
  length = length or 25
  style = style or "blocks"

  local filled_length = math.floor((percentage / 100) * length)
  local empty_length = length - filled_length

  local bars = {
    blocks = { filled = "█", empty = "░" },
    circles = { filled = "●", empty = "○" },
    squares = { filled = "■", empty = "□" },
    stars = { filled = "★", empty = "☆" },
    arrows = { filled = "▶", empty = "▷" }
  }

  local bar_style = bars[style] or bars.blocks
  return string.rep(bar_style.filled, filled_length) .. string.rep(bar_style.empty, empty_length)
end

-- Create skill level assessment
local function create_skill_level_assessment(stats)
  local total = stats.problems.total_solved
  local lines = {}

  local skill_level, icon, description
  if total >= 1000 then
    skill_level = "Legendary Coder"
    icon = "👑"
    description = "You're in the elite tier!"
  elseif total >= 500 then
    skill_level = "Advanced Problem Solver"
    icon = "🦾"
    description = "Impressive dedication!"
  elseif total >= 200 then
    skill_level = "Intermediate Developer"
    icon = "🎯"
    description = "Great progress!"
  elseif total >= 50 then
    skill_level = "Rising Star"
    icon = "⭐"
    description = "Building momentum!"
  elseif total >= 10 then
    skill_level = "Getting Started"
    icon = "🌱"
    description = "Keep it up!"
  else
    skill_level = "Beginner"
    icon = "🐣"
    description = "Every expert was once a beginner!"
  end

  table.insert(lines, string.format("🏅 Skill Level: %s %s", icon, skill_level))
  table.insert(lines, string.format("   %s", description))

  return lines
end

-- Create difficulty distribution chart with cool visualization
local function create_difficulty_chart(stats)
  local chart_lines = {}

  -- ASCII art header
  table.insert(chart_lines, "📈 Difficulty Breakdown:")
  table.insert(chart_lines, "")

  -- Create visual bars for each difficulty
  local easy_bar = create_progress_bar(stats.difficulty_distribution.easy, 30, "circles")
  local medium_bar = create_progress_bar(stats.difficulty_distribution.medium, 30, "squares")
  local hard_bar = create_progress_bar(stats.difficulty_distribution.hard, 30, "stars")

  table.insert(chart_lines, string.format("🟢 Easy   |%s| %d%% (%d)",
    easy_bar, stats.difficulty_distribution.easy, stats.problems.easy.solved))
  table.insert(chart_lines, string.format("🟡 Medium |%s| %d%% (%d)",
    medium_bar, stats.difficulty_distribution.medium, stats.problems.medium.solved))
  table.insert(chart_lines, string.format("🔴 Hard   |%s| %d%% (%d)",
    hard_bar, stats.difficulty_distribution.hard, stats.problems.hard.solved))

  return chart_lines
end

-- Create contest performance section with ranking visualization
local function create_contest_section(stats)
  local lines = {}

  if stats.contest.attended > 0 then
    table.insert(lines, "🏆 Contest Performance:")
    table.insert(lines, "")

    -- Rating visualization
    local rating = stats.contest.rating
    local rating_icon = "🥉"
    local rating_tier = "Beginner"

    if rating >= 2400 then
      rating_icon = "👑"
      rating_tier = "Legendary Grandmaster"
    elseif rating >= 2100 then
      rating_icon = "🏆"
      rating_tier = "International Grandmaster"
    elseif rating >= 1900 then
      rating_icon = "🥇"
      rating_tier = "Grandmaster"
    elseif rating >= 1600 then
      rating_icon = "🥈"
      rating_tier = "Master"
    elseif rating >= 1400 then
      rating_icon = "🥉"
      rating_tier = "Expert"
    end

    table.insert(lines, string.format("   %s Rating: %d (%s)", rating_icon, rating, rating_tier))
    table.insert(lines, string.format("   📅 Contests Attended: %d", stats.contest.attended))

    if stats.contest.global_ranking > 0 then
      table.insert(lines, string.format("   🌍 Global Ranking: #%s", stats.contest.global_ranking))
    end

    if stats.contest.top_percentage > 0 then
      table.insert(lines, string.format("   📊 Top %.1f%% of participants", stats.contest.top_percentage))
    end
  else
    table.insert(lines, "🏆 Contest Performance:")
    table.insert(lines, "")
    table.insert(lines, "   🎯 Ready for your first contest? Jump in! 🚀")
  end

  return lines
end

-- Create achievements section (simplified since badges don't seem to work)
local function create_achievements_section(stats)
  local lines = {}

  table.insert(lines, "🎖️ Achievements & Stats:")
  table.insert(lines, "")

  if stats.ranking > 0 then
    local ranking_emoji = "🌟"
    if stats.ranking <= 1000 then
      ranking_emoji = "👑"
    elseif stats.ranking <= 10000 then
      ranking_emoji = "🥇"
    elseif stats.ranking <= 50000 then
      ranking_emoji = "🥈"
    elseif stats.ranking <= 100000 then
      ranking_emoji = "🥉"
    end

    table.insert(lines, string.format("   %s Global Ranking: #%s", ranking_emoji, stats.ranking))
  end

  -- Acceptance rate visualization
  local acc_emoji = "📈"
  if stats.acceptance_rate >= 80 then
    acc_emoji = "🎯"
  elseif stats.acceptance_rate >= 60 then
    acc_emoji = "📈"
  elseif stats.acceptance_rate >= 40 then
    acc_emoji = "📊"
  else
    acc_emoji = "📉"
  end

  table.insert(lines, string.format("   %s Acceptance Rate: %d%%", acc_emoji, stats.acceptance_rate))

  -- Streak information
  if stats.streak > 0 then
    local streak_emoji = "🔥"
    if stats.streak >= 100 then
      streak_emoji = "🌋"
    elseif stats.streak >= 50 then
      streak_emoji = "🔥🔥"
    elseif stats.streak >= 30 then
      streak_emoji = "🔥"
    end
    table.insert(lines, string.format("   %s Current Streak: %d days", streak_emoji, stats.streak))
  end

  return lines
end

-- Create summary stats box with proper ASCII borders
local function create_summary_box(stats)
  local lines = {}

  table.insert(lines, "+- 📋 Quick Stats --------------------------------+")
  table.insert(lines, string.format("| Total Solved: %-8d Submissions: %-8d |", stats.problems.total_solved, stats.problems.total_submissions))
  table.insert(lines, string.format("| Easy: %-4d Medium: %-4d Hard: %-4d     |",
    stats.problems.easy.solved, stats.problems.medium.solved, stats.problems.hard.solved))
  table.insert(lines, string.format("| Acceptance Rate: %-6d%%                |", stats.acceptance_rate))
  table.insert(lines, "+---------------------------------------------+")

  return lines
end

-- Main function to show stats notification with enhanced visualizations
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

  table.insert(lines, string.rep("=", 50))
  table.insert(lines, "")

  -- Quick summary box
  local summary_success, summary_lines = pcall(create_summary_box, stats)
  if summary_success and summary_lines then
    for _, line in ipairs(summary_lines) do
      table.insert(lines, line)
    end
  end

  table.insert(lines, "")

  -- Skill level assessment
  local skill_success, skill_lines = pcall(create_skill_level_assessment, stats)
  if skill_success and skill_lines then
    for _, line in ipairs(skill_lines) do
      table.insert(lines, line)
    end
  end

  table.insert(lines, "")

  -- ASCII stats bar
  local ascii_success, ascii_lines = pcall(create_ascii_stats_bar,
    stats.problems.easy.solved, stats.problems.medium.solved, stats.problems.hard.solved)
  if ascii_success and ascii_lines then
    for _, line in ipairs(ascii_lines) do
      table.insert(lines, line)
    end
  end

  table.insert(lines, "")

  -- Enhanced difficulty distribution chart
  local chart_success, chart_lines = pcall(create_difficulty_chart, stats)
  if chart_success and chart_lines then
    for _, line in ipairs(chart_lines) do
      table.insert(lines, line)
    end
  end

  table.insert(lines, "")

  -- Contest performance
  local contest_success, contest_lines = pcall(create_contest_section, stats)
  if contest_success and contest_lines then
    for _, line in ipairs(contest_lines) do
      table.insert(lines, line)
    end
  end

  table.insert(lines, "")

  -- Achievements
  local achievement_success, achievement_lines = pcall(create_achievements_section, stats)
  if achievement_success and achievement_lines then
    for _, line in ipairs(achievement_lines) do
      table.insert(lines, line)
    end
  end

  table.insert(lines, "")
  table.insert(lines, get_random_quote())

  -- Show the notification with configurable timeout
  local notify_success, result = pcall(function()
    local notify = require "LeetNeoCode.utils.ui.notify"
    local timeout = C.stats_notification_timeout or 20000 -- Use configured timeout
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
