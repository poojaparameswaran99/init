# Soderling Lab — HPC Getting Started Guide

Welcome! This guide will walk you through setting up your environment on the Duke Compute Cluster (DCC) and organizing your projects. No programming experience is assumed — just follow the steps in order.

---

## 1. Accessing the Cluster

You'll connect to the DCC using **SSH** (Secure Shell), which gives you a terminal on a remote computer. There are two ways to log in: with a password (requires multi-factor authentication every time) or with SSH keys (recommended — no MFA needed after setup).

### Option A: Quick login with password + MFA

**Mac/Linux** — open your terminal app. **Windows** — use [MobaXterm](https://mobaxterm.mobatek.net/) or PowerShell. Then run:

```bash
ssh <your_netid>@dcc-login.oit.duke.edu
```

You'll be prompted for your Duke NetID password, followed by a Duo two-factor authentication prompt (push notification, phone call, or passcode). Once you complete both, you'll land in your **home directory** (`/hpc/home/<your_netid>`).

> A VPN is **not** required to connect, but MFA **is** required for password-based login.

### Option B: SSH keys (recommended)

Setting up SSH keys creates a secure key-based connection between your laptop and the DCC. Once configured, you can log in with just a passphrase — no Duo MFA, no VPN, no password. This also makes file transfers (`scp`, `rsync`) much smoother.

#### Step 1: Generate a key pair (on your local machine)

**Mac / Linux / Windows PowerShell:**

```bash
ssh-keygen -t ed25519
```

(Alternative if `ed25519` isn't supported: `ssh-keygen -t rsa -b 4096`)

You'll be prompted for where to save the key — the default (`~/.ssh/id_ed25519`) is fine, just press Enter. Then choose a **passphrase** (a password for your key — pick something secure you can remember).

This creates two files:

| File | What it is | Share it? |
|---|---|---|
| `~/.ssh/id_ed25519` | Your **private** key | **NEVER** share this with anyone |
| `~/.ssh/id_ed25519.pub` | Your **public** key | This is what you upload to Duke |

**Windows (MobaXterm):** Open MobaXterm → Tools → MobaKeyGen (SSH Key Generator). Set the key type to `ed25519`, click Generate, optionally add a passphrase, and save both the public and private keys.

#### Step 2: View and copy your public key

```bash
cat ~/.ssh/id_ed25519.pub
```

This will print something like:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... yourname@yourmachine
```

Select and **copy** the entire line.

#### Step 3: Upload your public key to Duke

1. Go to the Duke self-service portal: [https://idms-web-selfservice.oit.duke.edu/advanced](https://idms-web-selfservice.oit.duke.edu/advanced)
2. Log in with your Duke NetID.
3. Find the section **"Manage Your Public SSH Keys"**.
4. Click **"+ See More about SSH keys"** to expand it.
5. Paste your public key into the **"New Public Key"** text box.
6. Click **"Add Key"**.

It may take a few minutes for the key to propagate across Duke systems.

#### Step 4: Test your connection

```bash
ssh <your_netid>@dcc-login.oit.duke.edu
```

If everything worked, you should see `Enter passphrase for key ...` instead of `Password:`. Enter your key passphrase and you're in — no Duo prompt.

### Setting up an SSH config file (optional but very convenient)

Instead of typing the full hostname every time, you can create a config file on your local machine that lets you just type `ssh dcc`.

```bash
# Create or edit the config file
nano ~/.ssh/config
```

Add the following (replace `<your_netid>` with your actual NetID):

```
# DCC login node
Host dcc
    HostName dcc-login.oit.duke.edu
    User <your_netid>
    IdentityFile ~/.ssh/id_ed25519

# Specific login nodes (useful if one is down)
Host dcc1
    HostName dcc-login-01.oit.duke.edu
    User <your_netid>
    IdentityFile ~/.ssh/id_ed25519

Host dcc2
    HostName dcc-login-02.oit.duke.edu
    User <your_netid>
    IdentityFile ~/.ssh/id_ed25519

Host dcc3
    HostName dcc-login-03.oit.duke.edu
    User <your_netid>
    IdentityFile ~/.ssh/id_ed25519
```

Now you can simply run:

```bash
ssh dcc
```

### Connecting with VSCode (optional)

VSCode can connect directly to the DCC for editing files and running code. You **must** have SSH keys set up first (Duo MFA does not work with VSCode).

1. Install the **Remote - SSH** extension in VSCode.
2. Make sure you have an SSH config file set up (see above).
3. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux) and select **"Remote-SSH: Connect to Host..."**
4. Choose `dcc` from the list.
5. Enter your SSH key passphrase when prompted.

> **Important:** VSCode on the login node is fine for editing scripts and managing files, but do **not** run computationally intensive tasks from VSCode on the login nodes. Use SLURM (covered below) for heavy computation, or connect to an interactive session via [Open OnDemand](https://dcc-ondemand-01.oit.duke.edu).

### Open OnDemand (web-based alternative)

If you prefer a browser-based interface, Duke provides **Open OnDemand** at [https://dcc-ondemand-01.oit.duke.edu](https://dcc-ondemand-01.oit.duke.edu). From there you can open a terminal, manage files, and launch interactive applications (Jupyter, RStudio) — all without installing anything on your laptop. You'll need an existing DCC account to access it.

### Transferring files

Once you have SSH keys set up, transferring files between your laptop and the DCC is straightforward:

```bash
# Push a file to the DCC
scp myfile.csv <your_netid>@dcc-login.oit.duke.edu:/hpc/group/soderlinglab/<your_netid>/

# Pull a file from the DCC to your current directory
scp <your_netid>@dcc-login.oit.duke.edu:/hpc/group/soderlinglab/output/results.csv .

# For many files, use rsync (faster, can resume interrupted transfers)
rsync -rP my_data_folder/ <your_netid>@dcc-login.oit.duke.edu:/hpc/group/soderlinglab/<your_netid>/
```

If you set up the SSH config file, you can use the short alias instead:

```bash
scp myfile.csv dcc:/hpc/group/soderlinglab/<your_netid>/
```

> **Tip:** The login nodes are shared — never run heavy computations here. Use SLURM (covered below) to submit jobs to compute nodes.

---

## 2. Initial Setup (Run Once)

We have a setup script that installs **micromamba** (a fast Python environment manager) and configures your shell. Run it the first time you log in:

```bash
# Navigate to the lab's init directory
cd /hpc/group/soderlinglab/init

# Run the setup script
bash setup.sh
```

### What the setup script does

For reference, here is what `setup.sh` contains and what each part does:

```bash
#!/bin/bash

# 1. Copy the lab's standard bashrc to your home directory.
#    This gives you useful aliases, the micromamba shell hook, and lab paths.
cp /hpc/group/soderlinglab/init/template_bashrc $HOME/.bashrc

# 2. Install micromamba (a lightweight conda alternative) into ~/.local/bin.
#    This MUST match MAMBA_EXE / PATH in template_bashrc (both use ~/.local/bin).
mkdir -p $HOME/.local/bin
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest \
  | tar -xvj -C $HOME/.local/bin --strip-components=1 bin/micromamba

# 3. Point micromamba to the lab's shared environment location.
#    Environments are stored in the group directory so everyone can share them.
export MAMBA_ROOT_PREFIX=/hpc/group/soderlinglab/python_envs/micromamba

# 4. Reload your shell. template_bashrc sets MAMBA_EXE, prepends ~/.local/bin
#    to PATH, and evals the micromamba shell hook — so micromamba works right away.
source ~/.bashrc
```

After running this, **close and reopen your terminal** (or run `source ~/.bashrc`) to make sure everything is active.

---

## 3. Using Micromamba (Python Environments)

Micromamba works just like conda but faster. Environments let you install specific packages for a project without affecting anything else.

### Common commands

```bash
# List available environments
micromamba env list

# Activate an existing environment
micromamba activate <env_name>

# Create a new environment with Python
micromamba create -n my_project python=3.10

# Install a package into the active environment
micromamba install numpy pandas matplotlib

# Deactivate when done
micromamba deactivate
```

> **Important:** Our environments live in the shared group directory (`/hpc/group/soderlinglab/python_envs/micromamba`). Check with the lab before creating new environments — there may already be one with the packages you need.

---

## 4. Project Directory Structure

Every project in the lab follows a consistent layout. This makes it easy for others to understand and reproduce your work. Below is the standard structure and where each piece lives on the cluster.

```
Project/
│
├── data/                          # Working data (in /cwork/<netid>)
│   ├── X.csv                      #   Large or temporary data files go here.
│   └── Y.csv                      #   cwork = "compute work" scratch space.
│
├── pdata/                         # Permanent data (in /hpc/group/soderlinglab)
│   └── output/                    #   Results you want to keep long-term.
│
├── src/                           # Source code (in /hpc/group/soderlinglab)
│   └── p_repo/                    #   The project's code repository.
│       └── method_name/
│           ├── commands/           #   Scripts you run directly:
│           │   ├── train.py        #     - train a model
│           │   ├── test.py         #     - evaluate a model
│           │   └── scrape_data.py  #     - download/prepare data
│           ├── utils/              #   Helper functions used by commands.
│           └── models/             #   Model definitions.
│
└── tasks/                         # Task runs (in /hpc/group/soderlinglab)
    └── preprocess/                #   One folder per task (e.g., preprocess).
        ├── run1/
        │   └── config.yaml        #   Each run has its own config.
        ├── run2/
        │   └── config.yaml
        ├── src/ -> ../../src/...  #   Soft link to the source code.
        └── data/ -> ../../data/   #   Soft link to the data directory.
```

### Key concepts

- **`data/`** lives on scratch storage (`/cwork/<netid>`). This is fast storage meant for active work. Files here may be **purged** after a period of inactivity — don't treat it as permanent.
- **`pdata/`** lives in the lab group directory. Use this for final results and data you want to keep.
- **`src/`** is where your code lives. It is stored in the group directory and version-controlled with Git.
- **`tasks/`** is where you actually run experiments. Each run gets its own folder with a `config.yaml` that records the exact parameters used. The `src/` and `data/` folders inside are **soft links** (shortcuts) pointing back to the real code and data — this avoids duplication.
- **Soft links** (also called symbolic links) are like shortcuts. They point to a file or folder somewhere else. You create them with `ln -s <target> <link_name>`.

---

## 5. Submitting Jobs with SLURM

SLURM is the job scheduler on the DCC. You write a small script describing what resources you need, and SLURM runs your code on a compute node when resources are available.

### Example SLURM script (`job.sh`)

```bash
#!/bin/bash
#SBATCH --job-name=my_analysis       # Name shown in the queue
#SBATCH --output=logs/%j.out         # Standard output log (%j = job ID)
#SBATCH --error=logs/%j.err          # Error log
#SBATCH --partition=common           # Which set of nodes to use
#SBATCH --mem=16G                    # Memory requested
#SBATCH --time=02:00:00              # Max wall time (HH:MM:SS)
#SBATCH --account=soderlinglab       # Our lab allocation

# Activate your environment
source ~/.bashrc
micromamba activate my_env

# Run your script
python src/p_repo/method_name/commands/train.py --config tasks/preprocess/run1/config.yaml
```

### Submitting and monitoring

```bash
# Submit a job
sbatch job.sh

# Check your jobs
squeue -u $USER

# Cancel a job
scancel <job_id>

# See job history / efficiency
sacct -j <job_id> --format=JobID,Elapsed,MaxRSS,State
```

> **Tip:** Always create a `logs/` directory before submitting (`mkdir -p logs`), or SLURM will fail silently if the output directory doesn't exist.

---

## 6. Quick Reference

| Task | Command |
|---|---|
| Log in | `ssh dcc` (with config) or `ssh <netid>@dcc-login.oit.duke.edu` |
| See where you are | `pwd` |
| List files | `ls -la` |
| Change directory | `cd <path>` |
| Copy a file | `cp source destination` |
| Move / rename | `mv old new` |
| Create a directory | `mkdir -p my_dir` |
| Create a soft link | `ln -s /real/path /link/name` |
| View a file | `cat file.txt` or `less file.txt` |
| Edit a file | `nano file.txt` (beginner-friendly editor) |
| Activate environment | `micromamba activate <env>` |
| Submit a job | `sbatch job.sh` |
| Check job queue | `squeue -u $USER` |
| Cancel a job | `scancel <job_id>` |
| Copy file to DCC | `scp file.csv dcc:/path/` |
| Copy file from DCC | `scp dcc:/path/file.csv .` |

---

## 7. Getting Help

- **DCC documentation:** [https://rc.duke.edu/dcc](https://rc.duke.edu/dcc)
- **DCC login & SSH keys guide:** [https://oit-rc.pages.oit.duke.edu/rcsupportdocs/dcc/login/](https://oit-rc.pages.oit.duke.edu/rcsupportdocs/dcc/login/)
- **Open OnDemand:** [https://dcc-ondemand-01.oit.duke.edu](https://dcc-ondemand-01.oit.duke.edu)
- **Lab members:** Ask in the lab Slack or stop by — no question is too basic.
- **Micromamba docs:** [https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html)

---

*Last updated: March 2026*
# init
