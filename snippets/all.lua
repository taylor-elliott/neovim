local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- DOCS
-- https://github.com/L3MON4D3/LuaSnip/blob/b5a72f1fbde545be101fcd10b70bcd51ea4367de/Examples/snippets.lua#L501

return {
    s(
        "gitignore_basic",
        fmt(
            [[
__pycache__/
*.py[cod]
*$py.class

.Python
env/
venv/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Jupyter Notebook checkpoints
.ipynb_checkpoints

# pyenv
.python-version

# virtualenv
.venv/
env/
venv/

# IDEs
.idea/
.vscode/
*.sublime-project
*.sublime-workspace

# OS files
.DS_Store
Thumbs.db

# Logs
*.log

# dotenv
.env
]],
            {}
        )
    ),

    s(
        "gitignore_python",
        fmt(
            [[
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
env/
venv/
ENV/
env.bak/
venv.bak/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Jupyter Notebook checkpoints
.ipynb_checkpoints

# pyenv
.python-version

# virtualenv
.venv/
env/
venv/

# IDEs
.idea/
.vscode/
*.sublime-project
*.sublime-workspace

# OS files
.DS_Store
Thumbs.db

# Logs
*.log

# dotenv
.env
]],
            {}
        )
    ),
}
