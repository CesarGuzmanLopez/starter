#!/usr/bin/env bash
# Bootstrap de este config de Neovim en un clon fresco.
# Idempotente: se puede correr cuantas veces sea.
# Uso: ./scripts/bootstrap.sh [--full]
#   sin flags : plugins (Lazy) + Mason + jdtls + treesitter + providers
#   --check   : solo verifica e informa lo que falta (exit 1 si falta algo)
set -u

MASON_PKGS="angular-language-server bash-language-server clangd clang-format cmake-language-server cmakelint codelldb css-lsp debugpy dockerfile-language-server eslint_d google-java-format htmlhint html-lsp intelephense jdtls js-debug-adapter jsonlint json-lsp julia-lsp ktfmt ktlint lua-language-server markdownlint marksman mypy prettierd pyright qmlls ruff rust-analyzer serve-d stylelint stylua taplo typescript-language-server yaml-language-server yamllint"
TS_PARSERS="bash c cmake cpp css d dockerfile html java javascript json julia kotlin lua luadoc markdown markdown_inline printf python rust toml tsx typescript vim vimdoc yaml"

CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

fail=0
have() { command -v "$1" >/dev/null 2>&1; }
need() { # need <bin> <para-que>
	if have "$1"; then echo "OK   $1 ($2)"; else
		echo "FALTA $1 ($2)"
		fail=1
	fi
}

echo "== 1/6 herramientas del sistema =="
need nvim "editor >= 0.11"
need git "lazy.nvim"
need curl "descargas Mason/parsers"
need gcc "compilar parsers treesitter"
need node "LSPs Mason"
need python3 "pyright/ruff/debugpy"
need java "jdtls (ideal JDK 25+)"
have julia || echo "aviso: falta julia (juliaup: curl -fsSL https://install.julialang.org | sh)"
have rg || echo "aviso: falta rg (telescope live-grep)"
have tree-sitter || echo "aviso: falta tree-sitter CLI (npm i -g tree-sitter-cli)"

if [ "$CHECK_ONLY" = 1 ]; then
	echo "== providers =="
	python3 -c "import pynvim" 2>/dev/null && echo "OK   pynvim" || {
		echo "FALTA pynvim"
		fail=1
	}
	npm ls -g neovim >/dev/null 2>&1 && echo "OK   neovim npm" || {
		echo "FALTA neovim npm"
		fail=1
	}
	ruby -e "require 'neovim'" 2>/dev/null && echo "OK   neovim gem" || {
		echo "FALTA neovim gem"
		fail=1
	}
	nvim --headless -c 'lua if not pcall(require,"jsregexp") then vim.cmd("cquit 1") end' -c 'qa!' >/dev/null 2>&1 &&
		echo "OK   jsregexp" || {
		echo "FALTA jsregexp"
		fail=1
	}
	[ "$fail" = 0 ] && echo "TODO OK" || echo "FALTAN COSAS"
	exit "$fail"
fi

echo "== 2/6 providers (best effort) =="
python3 -c "import pynvim" 2>/dev/null || pip install --break-system-packages -q pynvim 2>/dev/null || pip install -q pynvim || echo "aviso: no se pudo instalar pynvim"
npm ls -g neovim >/dev/null 2>&1 || npm i -g neovim || echo "aviso: no se pudo instalar neovim npm"
ruby -e "require 'neovim'" 2>/dev/null || gem install --user-install neovim || echo "aviso: no se pudo instalar neovim gem"
nvim --headless -c 'lua if not pcall(require,"jsregexp") then vim.cmd("cquit 1") end' -c 'qa!' >/dev/null 2>&1 ||
	luarocks --lua-version=5.1 install --local jsregexp || echo "aviso: no se pudo instalar jsregexp"
have tree-sitter || npm i -g tree-sitter-cli || echo "aviso: sin tree-sitter CLI no hay parsers"

echo "== 3/6 plugins (Lazy sync) =="
nvim --headless "+Lazy! sync" +qa || {
	echo "ERROR en Lazy sync"
	exit 1
}

echo "== 4/6 Mason =="
# shellcheck disable=SC2086
nvim --headless "+MasonInstall $MASON_PKGS" +qa || echo "aviso: revisar :Mason (algun paquete pudo fallar)"

echo "== 5/6 jdtls (ruta que espera lua/configs/jdtls.lua) =="
if [ ! -e "$HOME/.local/share/jdtls" ]; then
	ln -s "$HOME/.local/share/nvim/mason/packages/jdtls" "$HOME/.local/share/jdtls"
	echo "OK   symlink ~/.local/share/jdtls"
else
	echo "OK   ~/.local/share/jdtls ya existe"
fi

echo "== 6/6 treesitter (compila, tarda varios minutos) =="
# shellcheck disable=SC2086
nvim --headless -c "TSInstall $TS_PARSERS" -c 'lua vim.wait(600000)' -c 'qa!'
echo "parsers instalados: $(ls "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/parser" 2>/dev/null | wc -l)"

echo "== checkhealth =="
nvim --headless -c 'silent checkhealth' -c 'silent! write! /tmp/nvim-bootstrap-health.txt' -c 'qa!' >/dev/null 2>&1
if grep -E "ERROR|✘" /tmp/nvim-bootstrap-health.txt | head -5; then
	echo "revisar /tmp/nvim-bootstrap-health.txt"
else
	echo "checkhealth sin errores"
fi
