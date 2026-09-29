# Personal Scripts - Zettelkasten & Utilities

A Nix flake-based project for shell scripts useful for me

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
inputs.ttw-scripts.url = "path:/home/torsneyw/projects/ttw_scripts";
```

Then in your home-manager configuration:

```nix
imports = [
  inputs.ttw-scripts.homeManagerModules.default
];

programs.work-scripts = {
  enable = true;
  vaultPath = "/home/username/Documents/Notes";
};
```

With default vault path:

```nix
programs.work-scripts.enable = true;
```

This will install all scripts and set the `ZK_VAULT` environment variable.

## Usage

### Create a New Meeting Note

With home-manager module (vault path is set automatically):

```bash
meeting_note "Team Standup"
```

Manual usage:

```bash
# With arguments
./bin/meeting_note.sh "Team Standup" ~/Documents/Notes

# Using environment variable
ZK_VAULT=~/Documents/Notes meeting_note "Team Standup"

# Using Nix
nix run .#meeting_note -- "Team Standup" ~/Documents/Notes
```

