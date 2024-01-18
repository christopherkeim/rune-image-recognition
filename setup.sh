#! /bin/bash
# 
# This script sets up a local development environment on an Ubuntu 20.04/22.04 machine
# to work with Poetry managed Python3.X projects. 
# 
# Targets:
#   - Python3.10
#   - Poetry 1.5.1
#   - Docker 24.0.6
#   - Terraform v1.6.6
#
# Requirements:
#   - Ubuntu 20.04/22.04
#   - Python3.7+ 
#

# -----------------------------------------------------------------------------------------------------------
# 0) Config: here we'll set default variables and handle options for controlling 
#    the target versions of Python and Poetry installed during set up.
# -----------------------------------------------------------------------------------------------------------
package="setup.sh"

TARGET_PYTHON_VERSION="3.10"
TARGET_POETRY_VERSION="1.5.1"


show_help() {
  cat <<END
  Sets up Poetry managed Python environment for machine learning 
  development on Ubuntu 20.04/22.04.

  ${package} [options] [arguments]

  options:
  -h, --help                Display help message
  --python=VERSION          Python version to use (default 3.10)
  --poetry=VERSION          Poetry version to use (default 1.5.1)
END

  exit 0
}

while getopts 'h-:' flag; do
  case "${flag}" in
    h) show_help ;;
    -)
      # Prefix substring removal matching "*="
      LONG_OPTARG_VALUE="${OPTARG#*=}"
      case ${OPTARG} in
        help)
          show_help
          ;;
        python=?*)  
          TARGET_PYTHON_VERSION="${LONG_OPTARG_VALUE}"
          ;;
        poetry=?*) 
          TARGET_POETRY_VERSION="${LONG_OPTARG_VALUE}"
          ;;
        python* | poetry*)
          echo "No arg for --${OPTARG} option" >&2
          exit 2
          ;;
        help*)
          echo "No arg allowed for --${OPTARG} option" >&2; 
          exit 2
          ;;
        *)
          echo "Unknown option --$OPTARG" >&2
          exit 2 
          ;;
      esac 
      ;;
    # getopts already reported the unknown option error, so exit
    \?) exit 2 ;;
  esac
done
shift $((OPTIND-1))

readonly TARGET_PYTHON_VERSION
readonly TARGET_POETRY_VERSION


# -----------------------------------------------------------------------------------------------------------
# 1) Base Requirements: this will ensure that you base requirements along with some data science
#    CLI tools installed.
# -----------------------------------------------------------------------------------------------------------

# Check if ca-certificates is in the apt-cache
if ( apt-cache show ca-certificates > /dev/null ); then
  echo 'ca-certificates is already cached 🟢'
else
  sudo apt update
fi

# Ensure ca-certificates package is installed on the machine
if ( which update-ca-certificates > /dev/null ); then
  echo 'ca-certificates is already installed 🟢'
else
  echo 'Installing ca-certificates 📜'
  sudo apt-get install -y ca-certificates
fi

# Check if curl is in the apt-cache
if ( apt-cache show curl > /dev/null ); then
  echo 'curl is already cached 🟢'
else
  sudo apt update
fi

# Ensure curl is installed on the machine
if ( which curl > /dev/null ); then
  echo 'curl is already installed 🟢'
else
  echo 'Installing curl 🌀'
  sudo apt install -y curl
fi

# Check if make is in the apt-cache
if ( apt-cache show make > /dev/null ); then
  echo 'make is already cached 🟢'
else
  sudo apt update
fi

# Ensure make is installed on the machine
if ( which make > /dev/null ); then
  echo 'make is already installed 🟢'
else
  echo 'Installing make 🔧'
  sudo apt install -y make
fi

# Check if gnupg is in the apt-cache
if ( apt-cache show gpg > /dev/null ); then
  echo 'gnupg is already cached 🟢'
else
  sudo apt update
fi

# Ensure gnupg is installed on the machine
if ( which gpg > /dev/null ); then
  echo 'make is already installed 🟢'
else
  echo 'Installing gnugp 🔧'
  sudo apt install -y gnupg
fi

# Check if bat is in the apt-cache
if ( apt-cache show bat > /dev/null ); then
  echo 'batcat is already cached 🟢'
else
  sudo apt update
fi

# Ensure bat is installed on the machine
if ( which batcat > /dev/null ); then
  echo 'batcat is already installed 🟢'
else
  echo 'Installing batcat 🔧'
  sudo apt install -y bat
fi

# Check if jq is in the apt-cache
if ( apt-cache show jq > /dev/null ); then
  echo 'jq is already cached 🟢'
else
  sudo apt update
fi

# Ensure jq is installed on the machine
if ( which jq > /dev/null ); then
  echo 'jq is already installed 🟢'
else
  echo 'Installing jq 🔧'
  sudo apt install -y jq
fi

# Check if csvkit is in the apt-cache
if ( apt-cache show csvkit > /dev/null ); then
  echo 'csvkit is already cached 🟢'
else
  sudo apt update
fi

# Ensure csvkit is installed on the machine (commands csvlook, csvcut, in2csv, sql2csv)
if ( which csvlook > /dev/null ); then
  echo 'csvkit is already installed 🟢'
else
  echo 'Installing csvkit 🔧'
  sudo apt install -y csvkit
fi


# -----------------------------------------------------------------------------------------------------------
# 2) Python3.X Install: here we'll install Python3.10 (default) - swap this for a version you'd like.
# -----------------------------------------------------------------------------------------------------------

# Check if software-properties-common is in the apt-cache
if ( apt-cache show software-properties-common > /dev/null ); then
  echo 'software-properties-common is already cached 🟢'
else
  sudo apt update
fi

# Check for the software-properties-common requirement
if ( dpkg -L software-properties-common > /dev/null ); then
  echo 'software-properties-common requirement met 🟢'
else
  echo 'Installing software-properties-common 🔧'
  sudo apt install -y software-properties-common
fi

# Add this apt repository for Python 3.X
if [[ -n "$(ls /etc/apt/sources.list.d | grep deadsnakes)" ]]; then
  echo 'ppa:deadsnakes/ppa apt repository present 🟢'
else
  echo 'Adding deadsnakes to the apt-repository 💀🐍'
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  # Refresh the package list again
  sudo apt update -y
fi

# Now you can download Python3.X
if ( which python${TARGET_PYTHON_VERSION} > /dev/null ); then
  echo "Python${TARGET_PYTHON_VERSION} already installed 🐍"
else
  echo "Installing Python${TARGET_PYTHON_VERSION} 🔧"
  sudo apt install -y python${TARGET_PYTHON_VERSION}
fi

# Verify Python3.X installation
if ( which python${TARGET_PYTHON_VERSION} > /dev/null ); then
  echo "$(python${TARGET_PYTHON_VERSION} --version) 🐍 🚀 ✨"
else
  echo "Python ${TARGET_PYTHON_VERSION} was not installed successfully 🔴"
fi


# -----------------------------------------------------------------------------------------------------------
# 3) Poetry Install: here we'll install and configure Poetry, as well as add Poetry to the PATH.
# -----------------------------------------------------------------------------------------------------------

# Install Poetry using the official installer
if ( which poetry > /dev/null ); then
  echo "Poetry ${TARGET_POETRY_VERSION} is already installed 🟢"
else
  echo 'Installing Poetry 🧙‍♂️'
  curl -sSL https://install.python-poetry.org \
    | POETRY_VERSION=${TARGET_POETRY_VERSION} python3 -
fi

# Add Poetry to the path in the current user's .bashrc
if ( poetry --version > /dev/null ); then
  echo 'Poetry is already in PATH 🟢'
else
  echo -e \
    "# Add Poetry (Python Package Manager) to PATH
    export PATH="/home/${USER}/.local/bin:${PATH}"" \
    >> ~/.bashrc
  source ~/.bashrc
fi

# Configure Poetry to put build all virtual environments in the project's directory
if [[ "$(poetry config virtualenvs.in-project)" == "true" ]]; then
  echo 'Poetry already configured to create virtual envs within projects 🟢'
else
  echo 'Configuring Poetry to create virtual envs in projects 🪐'
  poetry config virtualenvs.in-project true
fi


# -----------------------------------------------------------------------------------------------------------
# 4) Docker Install: here we'll install Docker
# -----------------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------------
# 4.1) Set up the repository: Before you install Docker Engine for the first time on a new host machine, 
# you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.
# -----------------------------------------------------------------------------------------------------------

# Pull the current machine's distro for GPG key targeting
readonly DISTRO="$(lsb_release -d | awk -F ' ' '{print tolower($2)}')"

# Add Docker’s official GPG key
if [[ -f /etc/apt/keyrings/docker.gpg ]]; then
  echo 'Docker GPG Key already installed at /etc/apt/keyrings/docker.gpg 🟢'
else
  echo 'Installing Docker GPG Key at /etc/apt/keyrings/docker.gpg 🔧'
  
  # Create the /etc/apt/keyrings directory with appropriate permissions
  sudo install -m 0755 -d /etc/apt/keyrings
  
  # Download the GPG key from Docker
  curl -fsSL https://download.docker.com/linux/${DISTRO}/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Set up the repository
if [[ -f /etc/apt/sources.list.d/docker.list ]]; then
  echo 'docker.list repository already exists at /etc/apt/sources.list.d/docker.list 🟢'
else
  echo 'Installing docker.list repository at /etc/apt/sources.list.d/docker.list 🔧'
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/$DISTRO \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

# -----------------------------------------------------------------------------------------------------------
# 4.2) Install Docker Engine
# -----------------------------------------------------------------------------------------------------------

# Check if docker-ce is in the apt-cache
if ( apt-cache show docker-ce > /dev/null ); then
  echo 'docker-ce is already cached 🟢'
else
  sudo apt update
fi

# Install Docker Engine, containerd, and Docker Compose
if ( docker --version > /dev/null ); then
  echo 'Docker is already installed 🟢'
  echo "Using $(docker --version)"
else
  echo 'Installing Docker 🐳'

  # Installs
  sudo apt-get install -y docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
  
  # Verify that the Docker Engine installation is successful by running the hello-world image
  sudo docker run --rm hello-world
fi


# -----------------------------------------------------------------------------------------------------------
# 5) Terraform Install: here we'll install Terraform
# -----------------------------------------------------------------------------------------------------------

# Add HashiCorp's official GPG key
if [[ -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]]; then
  echo 'Hashicorp GPG Key already installed at /usr/share/keyrings/hashicorp-archive-keyring.gpg 🟢'
else
  echo 'Installing Hashicorp GPG key at /usr/share/keyrings/hashicorp-archive-keyring.gpg 🔧'
  wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
fi

# Add HashiCorp's repository
if [[ -f /etc/apt/sources.list.d/hashicorp.list ]]; then
  echo 'hashicorp.list repository already exists at /etc/apt/sources.list.d/hashicorp.list 🟢'
else
  echo 'Installing hashicorp.list repository at /etc/apt/sources.list.d/hashicorp.list 🔧'
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list
  # Refresh the package list
  sudo apt update -y
fi

# Install Terraform
if ( terraform --version > /dev/null ); then
  echo 'Terraform is already installed 🟢'
else
  echo 'Installing Terraform 🌎'
  sudo apt-get install terraform
fi

# Verify Terraform installation
if ( terraform --version > /dev/null ); then
  echo "$(terraform --version) 🌎"
else
  echo 'Terraform was not installed successfully 🔴'
fi
