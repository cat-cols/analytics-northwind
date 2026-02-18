# 1) Install dependencies
pip install -r requirements.txt

# 2) Setup virtual environment
python -m venv .venv
source .venv/bin/activate

# 3) setup directories
mkdir -p database docs notebooks logs outputs reports viz scripts src tests

# 4) Setup database
source ./database/setup.sh

# 5) Run setup

