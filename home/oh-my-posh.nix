{
  programs.oh-my-posh = {
    enable = true;

    settings = {
      version = 2;
      final_space = true;
      disable_notice = true;
      disable_cursor_positioning = true;

      blocks = [
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              type = "path";
              foreground = "blue";
              template = "{{ .Path }}";
              properties.style = "full";
            }
            {
              type = "text";
              template = "{{if .Env.IN_NIX_SHELL }} ❄️ {{ end }}";
            }
            {
              type = "git";
              template = " {{ .HEAD }}";
              properties = {
                branch_icon = "";
                commit_icon = "@";
                fetch_status = true;
              };
            }
            {
              type = "git";
              foreground = "yellow";
              foreground_templates = [
                "{{ if and (or (gt .Staging.Modified 0) (gt .Staging.Added 0)) (and (eq .Working.Modified 0) (eq .Working.Untracked 0)) }}green{{end}}"
                "{{ if and (or (eq .Staging.Modified 0) (eq .Staging.Added 0)) (and (eq .Working.Modified 0) (gt .Working.Untracked 0)) }}magenta{{end}}"
              ];
              template = "{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }}";
              properties.fetch_status = true;
            }
            {
              type = "git";
              foreground = "cyan";
              template = " {{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}";
              properties.fetch_status = true;
            }
            {
              type = "git";
              template = "{{ if gt .StashCount 0 }}{{ if gt .StashCount 1 }} {{ .StashCount }}{{ end }}  {{ end }}";
              properties.fetch_status = true;
            }
          ];
        }

        {
          type = "rprompt";
          overflow = "hidden";

          segments = [
            {
              type = "executiontime";
              foreground = "yellow";
              template = "{{ .FormattedMs }}";

              properties.threshold = 1000;
            }
            {
              type = "text";
              foreground = "red";
              template = "{{if gt .Code 0 }} <b>{{ .Code }}</b>{{ end }}";
            }
          ];
        }

        {
          type = "prompt";
          alignment = "left";
          newline = true;

          segments = [
            {
              type = "text";
              foreground_templates = [
                "{{if gt .Code 0}}red{{end}}"
                "{{if eq .Code 0}}magenta{{end}}"
              ];
              template = "❯";
            }
          ];
        }
      ];

      transient_prompt = {
        type = "text";
        foreground_templates = [
          "{{if gt .Code 0}}red{{end}}"
          "{{if eq .Code 0}}magenta{{end}}"
        ];
        template = "❯ ";
      };

      secondary_prompt = {
        type = "text";
        foreground = "magenta";
        template = "❯❯ ";
      };
    };
  };
}
