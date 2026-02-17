Yeah — **three scripts is a very sane “grown-up repo” structure**, *as long as each one has a clear job and you don’t turn it into a Rube Goldberg machine.*

Here’s the cleanest pattern:

### 1) `scripts/setup.sh` (run once per machine)

**Purpose:** get the environment ready.

* Create venv
* Install Python deps
* (Optionally) create/load the `northwind` database from your `database/northwind.sql`
* Check Postgres is reachable

This should be **idempotent** (safe to run twice).

### 2) `scripts/export.sh` (run whenever SQL changes)

**Purpose:** generate data artifacts.

* Run your export queries
* Write CSVs to `outputs/`
* (Optionally) validate outputs exist + row counts

This should be your “data build” step.

### 3) `scripts/viz.sh` (run whenever you want updated charts)

**Purpose:** generate visuals.

* Read CSVs from `outputs/`
* Create charts into `reports/figures/` (or `outputs/figures/`)
* (Optional) create a simple HTML report page that displays the charts

This is your “report build” step.

---

## Bonus: add a single “do everything” runner

Instead of making humans remember three commands, give them one:

### 4) `scripts/run_all.sh`

Runs setup (optional), export, viz.

That’s the recruiter-friendly move.

---

## The one rule that keeps this clean

**Shell scripts orchestrate; Python does the work.**

So:

* `.sh` = directories, env vars, calling commands
* `.py` = charts / data transforms

Your `viz.sh` should basically be:

```bash
#!/bin/bash
set -euo pipefail
source .venv/bin/activate
python viz/make_charts.py
```

---

## Naming + layout I’d use

```
scripts/
  setup.sh
  export.sh
  viz.sh
  run_all.sh
viz/
  make_charts.py
sql/
outputs/
reports/
  figures/
```

---

## Tiny detail that makes this *actually portable*

Avoid hardcoding your path and your username. Use repo-relative paths:

* `PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"`

And avoid `psql -U postgres` since on your Mac it’s `b` by default. Let `psql` use current user, or allow an env var:

```bash
DB_NAME="${DB_NAME:-northwind}"
PSQL="psql -d $DB_NAME"
```

---

💡💡 If you do this, your repo becomes a little machine with a big “professional” smell: *setup → build data → build visuals*. That’s exactly the mental model firms use (even when they call it dbt/Airflow/CI).
