# Work Scripts - Zettelkasten & Utilities

A Nix flake-based project for shell scripts useful for work

## Installation

### Using Nix Flakes

```bash
# Development environment
nix flake update
nix develop

# Build and run
nix build
```

### Using Home Manager

Add to your home-manager flake inputs:

```nix
inputs.work-scripts.url = "path:/home/torsneyw/projects/work_scripts";
```

Then in your home-manager configuration:

```nix
home.packages = builtins.attrValues inputs.work-scripts.packages.${pkgs.system};
```

Run `home-manager switch` to install all scripts.

## Usage

### Create a New Meeting Note

```bash
# With arguments
./bin/meeting_note.sh "Team Standup" ~/Documents/Notes

# Using Nix
nix run .#meeting_note -- "Team Standup" ~/Documents/Notes
```

