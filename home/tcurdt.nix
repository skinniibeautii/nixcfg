{ pkgs, ... }: {

  # programs.bash.enable = true;

  programs = {

    bash = {
      enable = true;
      initExtra = ''
        # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    zsh = {
      enable = true;
      envExtra = ''
        # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin/:/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
      '';
    };

    # git = import ../home/git.nix;

    git = {
      enable = true;

      userName = "Torsten Curdt";
      userEmail = "tcurdt@vafer.org";

      # ignores = [ "*~" "*.swp" ];

      aliases = {
        p = "push";

        r = "pull --rebase";
        rf = "pull --rebase --force";

        s = "status -s";

        ci = "commit -v";
        co = "checkout";

        a = "add";
        au = "add -u";
        aa = "add --all";

        t = "tag";
        td = "!f() { git tag -d $1; git push --delete origin $1; }; f";
        tf = "!f() { git tag -f $1; git push --force origin HEAD:refs/tags/$1; }; f";

        b = "branch -av";
        bd = "branch -D";

        l = "log --graph --decorate --no-merges --pretty=format:'%Cred%h %Cblue%cN %Cgreen%cd%C(yellow)%d%Creset - %s' --date='format:%F %a'";
        la = "log --full-history --all --graph --abbrev-commit --pretty=format:'%Cred%h %Cblue%cN %Cgreen%cd%C(yellow)%d%Creset - %s' --date='format:%F %a'";
        lf = "log --graph --decorate --no-merges --oneline --name-status --pretty=format:'%Cred%h %Cblue%cN %Cgreen%cd%C(yellow)%d%Creset - %s %n' --date='format:%F %a'";
        lp = "log --abbrev-commit --date=relative -p";

        export = "archive -o latest.tar.gz -9 --prefix=latest/";

        setup = "!git init && git add . && git commit -m init";

      };

      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = "true";
      };

    };

    lazygit.enable = true;

  };

  # home.shellAliases = import ../home/shellAliases.nix;
  home.shellAliases = {
    ll = "ls -la";
    cat = "bat";
    ls = "eza";
    # g = "git";
    # lg = "lazygit";
  };

  # home.sessionVariables = import ../home/sessionVariables.nix;
  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "nano";
    # CLICOLOR = 1;
  };

  home.packages = [
    pkgs.tmux
    pkgs.curl
    pkgs.jq
    pkgs.unzip
    pkgs.htop
    pkgs.gitMinimal
    pkgs.file
    pkgs.dnsutils
    pkgs.sd # sed
    pkgs.fd # find
    pkgs.eza # ls
    pkgs.bat # cat
    pkgs.procs # ps
    pkgs.ripgrep # grep
    pkgs.hyperfine # progress
  ];

  home.file = {
    ".foo" = {
      text = ''
        bar
      '';
    };
  };

  home.stateVersion = "23.11";
}