#!/bin/bash
# Soderling Lab — one-time DCC setup. Run once after your first login:
#   cd /hpc/group/soderlinglab/init && bash setup.sh
#
# This is the single, all-in-one setup. It combines what used to be split
# between setup.sh and osetup.sh: shell shortcut, lab .bashrc, micromamba
# install, the shared env root prefix, AND an explicit ~/.mambarc pinning the
# conda-forge channel + the shared envs dir.

SHARED="/hpc/group/soderlinglab/python_envs/micromamba"

# 1. Create the ~/soderlinglab shortcut into the shared group directory.
#    (~/soderlinglab is NOT there by default — this makes it.) -sfn is safe to
#    re-run: it won't clobber a real dir and updates the link if it already exists.
ln -sfn /hpc/group/soderlinglab $HOME/soderlinglab

# 2. Install the lab's standard .bashrc (aliases, micromamba hook, paths).
cp /hpc/group/soderlinglab/init/template_bashrc $HOME/.bashrc

# 3. Install micromamba into ~/.local/bin.
#    This location MUST match MAMBA_EXE / PATH in template_bashrc, which both
#    point at ~/.local/bin. (Do not install to ~/bin — the bashrc won't find it.)
mkdir -p $HOME/.local/bin
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest \
  | tar -xvj -C $HOME/.local/bin --strip-components=1 bin/micromamba

# 4. Point micromamba at the shared group environment location.
export MAMBA_ROOT_PREFIX="$SHARED"
$HOME/.local/bin/micromamba shell init -s bash -r "$SHARED"

# 5. Write ~/.mambarc: pin the conda-forge channel and the shared envs dir so
#    new environments always land in the shared group location.
USER_ENV_DIR="$SHARED/envs"     # or "$SHARED/users/$USER/envs" to namespace per user
cat > "$HOME/.mambarc" <<YML
channels:
  - conda-forge
  - nodefaults

envs_dirs:
  - $USER_ENV_DIR
YML

# 6. Reload the shell. template_bashrc sets MAMBA_EXE, prepends ~/.local/bin to
#    PATH, and evals the micromamba shell hook, so micromamba is ready after this.
source ~/.bashrc

echo "Setup complete. Close and reopen your terminal (or run 'source ~/.bashrc')."
