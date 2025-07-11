  # Starship prompt - fast and informative
  { config, pkgs, ... }:

  {

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      # Minimal format for speed
      format = "$directory$git_branch$git_status$cmd_duration$character";

      # Show command duration for performance awareness
      cmd_duration = {
        min_time = 500;
        format = "[$duration]($style) ";
        style = "yellow";
      };

      # Git optimization
      git_branch = {
        format = "[$branch]($style) ";
        style = "purple";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "red";
        conflicted = "🏳";
        ahead = "🏎💨";
        behind = "😰";
        diverged = "😵";
        up_to_date = "✓";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "👍";
        renamed = "👅";
        deleted = "🗑";
      };

      # Directory display
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "cyan";
      };

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
}
