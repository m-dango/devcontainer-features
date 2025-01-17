#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# This code was generated by the DevContainers Feature Cookiecutter 
# Docs: https://github.com/devcontainers-contrib/features/tree/main/pkgs/feature-template#readme
#-------------------------------------------------------------------------------------------------------------

set -e
{%- if cookiecutter.content.aptget is defined and cookiecutter.content.aptget |length > 0  -%} 
{%- set optional_aptget_packages = (cookiecutter.content.aptget | selectattr('exposed', 'equalto', 'True') | list) -%}
{%- set mandatory_aptget_packages = (cookiecutter.content.aptget | selectattr('exposed', 'equalto', 'False') | list) -%}

{%- if optional_aptget_packages is defined and optional_aptget_packages|length > 0 -%}
# optional aptget packages  
{% for aptget_package in optional_aptget_packages -%} 
{{ aptget_package.display_name  | to_screaming_snake_case}}=${% raw %}{{% endraw %}{%- if aptget_package.version_alias is defined -%}{{aptget_package.version_alias | to_env_case}}{% else %}{{ aptget_package.display_name | to_env_case}}{%- endif -%}:-"{{ aptget_package.default }}"{% raw %}}{% endraw %}
{% endfor -%}
{%- endif -%}
{%- endif -%}

{% if cookiecutter.content.pipx is defined and cookiecutter.content.pipx |length > 0 %}   
{% for pipx_package in cookiecutter.content.pipx %}
# pipx version for {{ pipx_package.package_name }}
{% if pipx_package.exposed is defined and pipx_package.exposed == "True" -%}   
{{ pipx_package.display_name | to_screaming_snake_case }}=${% raw %}{{% endraw %}{%- if pipx_package.version_alias is defined -%}{{pipx_package.version_alias | to_env_case}}{% else %}{{ pipx_package.display_name | to_env_case}}{%- endif -%}:-"{{ pipx_package.default }}"{% raw %}}{% endraw %}
{% else -%}
{{ pipx_package.display_name | to_screaming_snake_case }}="latest"
{% endif -%}
   

{%- if pipx_package.injections is defined and pipx_package.injections |length > 0 -%}   
# injection versions for {{ pipx_package.package_name }} pipx env
{%- for pipx_injection in pipx_package.injections %}
{%- if pipx_injection.exposed is defined and pipx_injection.exposed == "True" %}   
{{ pipx_injection.display_name | to_screaming_snake_case }}=${% raw %}{{% endraw %}{%- if pipx_injection.version_alias is defined -%}{{pipx_injection.version_alias | to_env_case}}{% else %}{{ pipx_injection.display_name | to_env_case}}{%- endif -%}:-"{{ pipx_injection.default }}"{% raw %}}{% endraw %}
{% else -%}
{{ pipx_injection.display_name | to_screaming_snake_case }}="latest"
{% endif -%}

{%- endfor %}
{%- endif %}
{%- endfor -%}
{%- endif %}

{% if cookiecutter.content.npm is defined and cookiecutter.content.npm |length > 0 -%}   
{%- for npm_package in cookiecutter.content.npm -%}
# npm version for {{ npm_package.package_name }}
{% if npm_package.exposed is defined and npm_package.exposed == "True" -%}   
{{ npm_package.display_name | to_screaming_snake_case }}=${% raw %}{{% endraw %}{%- if npm_package.version_alias is defined -%}{{npm_package.version_alias | to_env_case}}{% else %}{{ npm_package.display_name | to_env_case}}{%- endif -%}:-"{{ npm_package.default }}"{% raw %}}{% endraw %}
{% else -%}
{{ npm_package.display_name | to_screaming_snake_case }}="latest"
{% endif -%}
{%- endfor -%}
{%- endif %}

{% if cookiecutter.content.asdf is defined and cookiecutter.content.asdf |length > 0 -%}   
{%- for asdf_plugin in cookiecutter.content.asdf -%}
# asdf plugin version for {{ asdf_plugin.package_name }}
{% if asdf_plugin.exposed is defined and asdf_plugin.exposed == "True" -%}   
{{ asdf_plugin.display_name | to_screaming_snake_case }}=${% raw %}{{% endraw %}{%- if asdf_plugin.version_alias is defined -%}{{asdf_plugin.version_alias | to_env_case}}{% else %}{{ asdf_plugin.display_name | to_env_case}}{%- endif -%}:-"{{ asdf_plugin.default }}"{% raw %}}{% endraw %}
{% else -%}
{{ asdf_plugin.display_name | to_screaming_snake_case }}="latest"
{% endif -%}
{%- endfor -%}
{%- endif %}

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as 
    root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi


{% if ((cookiecutter.content.aptget is defined) and (cookiecutter.content.aptget |length > 0)) or ((cookiecutter.content.npm is defined) and (cookiecutter.content.npm |length > 0)) or ((cookiecutter.content.asdf is defined) and (cookiecutter.content.asdf |length > 0)) -%} 

check_packages() {
    # This is part of devcontainers-contrib script library
    # source: https://github.com/devcontainers-contrib/features/tree/v1.1.8/script-library
  if ! dpkg -s "$@" > /dev/null 2>&1; then
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
      echo "Running apt-get update..."
      apt-get update -y
    fi
    apt-get -y install --no-install-recommends "$@"
  fi
}
{% endif %}




{% if cookiecutter.content.aptget is defined and cookiecutter.content.aptget |length > 0  -%} 
{%- if mandatory_aptget_packages is defined and mandatory_aptget_packages|length > 0 -%}
aptget_packages=({% for aptget_package_name in mandatory_aptget_packages -%}{{aptget_package_name.package_name}} {% endfor %})
{% else %}
aptget_packages=()
{%- endif -%}

{%- if optional_aptget_packages is defined and optional_aptget_packages|length > 0 -%}

{%- for aptget_package in optional_aptget_packages -%} 
if [ "${{ aptget_package.display_name  | to_screaming_snake_case }}" != "none" ]; 
    aptget_packages+=("{{aptget_package.package_name}}")
fi

{% endfor %}
{%- endif -%}

check_packages "${aptget_packages[@]}"
{% endif %}

{% if cookiecutter.content.pipx is defined and cookiecutter.content.pipx |length > 0  %} 

install_via_pipx() {
    # This is part of devcontainers-contrib script library
    # source: https://github.com/devcontainers-contrib/features/tree/v1.1.6/script-library
    PACKAGES=("$@")
    arraylength="${#PACKAGES[@]}"

    env_name=$(echo ${PACKAGES[0]} | cut -d "=" -f 1 | cut -d "<" -f 1 | cut -d ">" -f 1 )

    # if no python - install it
    if ! dpkg -s python3-minimal python3-pip libffi-dev python3-venv > /dev/null 2>&1; then
        apt-get update -y
        apt-get -y install python3-minimal python3-pip libffi-dev python3-venv
    fi
    export PIPX_HOME=/usr/local/pipx
    mkdir -p ${PIPX_HOME}
    export PIPX_BIN_DIR=/usr/local/bin
    export PYTHONUSERBASE=/tmp/pip-tmp
    export PIP_CACHE_DIR=/tmp/pip-tmp/cache
    pipx_bin=pipx
    # if pipx not exists - install it
    if ! type pipx > /dev/null 2>&1; then
        pip3 install --disable-pip-version-check --no-cache-dir --user pipx packaging==21.3
        pipx_bin=/tmp/pip-tmp/bin/pipx
    fi
    # install main package
    ${pipx_bin} install --pip-args '--no-cache-dir --force-reinstall' -f "${PACKAGES[0]}"
    # install injections (if provided)
    for (( i=1; i<${arraylength}; i++ ));
    do
    ${pipx_bin} inject $env_name --pip-args '--no-cache-dir --force-reinstall' -f "${PACKAGES[$i]}"
    done

    # cleaning pipx to save disk space
    rm -rf /tmp/pip-tmp
}

{% for pipx_package in cookiecutter.content.pipx %}
pipx_installations=()
if [ "${{ pipx_package.display_name | to_screaming_snake_case }}" != "none" ]; then
    if [ "${{ pipx_package.display_name | to_screaming_snake_case }}" =  "latest" ]; then
        pipx_installations+=("{{pipx_package.package_name}}")
    else
        pipx_installations+=("{{pipx_package.package_name}}==${{ pipx_package.display_name | to_screaming_snake_case }}")
    fi
{%- if pipx_package.injections is defined and pipx_package.injections |length > 0 -%}   
{% for pipx_injection in pipx_package.injections %}
    if [ "${{ pipx_injection.display_name | to_screaming_snake_case }}" != "none" ]; then
        if [ "${{ pipx_injection.display_name | to_screaming_snake_case }}" =  "latest" ]; then
            pipx_installations+=("{{pipx_injection.package_name}}")
        else
            pipx_installations+=("{{pipx_injection.package_name}}==${{ pipx_injection.display_name | to_screaming_snake_case }}")
        fi
    fi
{% endfor %}
{% endif %}
fi

install_via_pipx "${pipx_installations[@]}"

{% endfor %}
{%- endif %}

{% if cookiecutter.content.npm is defined and cookiecutter.content.npm |length > 0  %} 

install_via_npm() {
    # This is part of devcontainers-contrib script library
    # source: https://github.com/devcontainers-contrib/features/tree/v1.1.8/script-library
    PACKAGE=$1
    
    # install node+npm if does not exists
    if ! type npm >/dev/null 2>&1; then
        echo "Installing node and npm..."
        check_packages curl
        curl -fsSL https://raw.githubusercontent.com/devcontainers/features/main/src/node/install.sh | $SHELL
        export NVM_DIR=/usr/local/share/nvm
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    fi
    npm install -g --omit=dev $PACKAGE
}


{% for npm_package in cookiecutter.content.npm -%}
if [ "${{ npm_package.display_name | to_screaming_snake_case }}" != "none" ]; then
    if [ "${{ npm_package.display_name | to_screaming_snake_case }}" =  "latest" ]; then
        npm_package="{{npm_package.package_name}}"
    else
        npm_package="{{npm_package.package_name}}@${{ npm_package.display_name | to_screaming_snake_case }}"
    fi
    install_via_npm ${npm_package}
fi
{% endfor %}
{% endif %}


{% if cookiecutter.content.asdf is defined and cookiecutter.content.asdf |length > 0  %} 

updaterc() {
    # This is part of devcontainers-contrib script library
    # source: https://github.com/devcontainers-contrib/features/tree/v1.1.8/script-library
    echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
    if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/bash.bashrc
    fi
    if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/zsh/zshrc
    fi
}

install_via_asdf() {
    # This is part of devcontainers-contrib script library
    # source: https://github.com/devcontainers-contrib/features/tree/v1.1.8/script-library
    PACKAGE=$1
    VERSION=$2
    REPO=$3

    # install git and curl if does not exists
    check_packages curl git
    if ! type asdf >/dev/null 2>&1; then
        su - "$_REMOTE_USER" <<EOF
            git clone --depth=1 \
            -c core.eol=lf \
            -c core.autocrlf=false \
            -c fsck.zeroPaddedFilemode=ignore \
            -c fetch.fsck.zeroPaddedFilemode=ignore \
            -c receive.fsck.zeroPaddedFilemode=ignore \
            "https://github.com/asdf-vm/asdf.git" $_REMOTE_USER_HOME/.asdf 2>&1
            . $_REMOTE_USER_HOME/.asdf/asdf.sh

            asdf plugin-add "$PACKAGE" "$REPO"
            asdf install "$PACKAGE" "$VERSION"
            asdf global "$PACKAGE" "$VERSION"
EOF
    fi
    updaterc ". $_REMOTE_USER_HOME/.asdf/asdf.sh"
}


{% for asdf_plugin in cookiecutter.content.asdf -%}
if [ "${{ asdf_plugin.display_name | to_screaming_snake_case }}" != "none" ]; then
    install_via_asdf "{{asdf_plugin.package_name}}" "${{ asdf_plugin.display_name | to_screaming_snake_case }}"
fi
{% endfor %}
{% endif %}

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"