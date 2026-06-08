#!/bin/bash
set -e

uv sync

VENV="$(pwd)/.venv"
PYVER=$(ls "$VENV/lib/" | grep python | head -1)
MODULAR="$VENV/lib/$PYVER/site-packages/modular"
VERSION=$("$VENV/bin/mojo" --version 2>/dev/null | grep -oP '[\d.]+' | head -1)

mkdir -p .vscode
cat > .vscode/modular.cfg << EOF
[max]
version = $VERSION

[mojo-max]
driver_path = $MODULAR/bin/mojo
lsp_server_path = $MODULAR/bin/mojo-lsp-server
mblack_path = $VENV/bin/mblack
lldb_plugin_path = $MODULAR/lib/libMojoLLDB.so
lldb_vscode_path = $MODULAR/bin/lldb-dap
lldb_visualizers_path = $MODULAR/lib/lldb-visualizers
lldb_path = $MODULAR/bin/mojo-lldb
EOF

echo "Done. Open the project in VS Code and press F5 to debug."
