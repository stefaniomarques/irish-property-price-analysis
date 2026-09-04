# Irish Residential Property Price Analysis

SQL analysis of 803,904 property sales across Ireland (2010–2026), sourced from
the Property Services Regulatory Authority's public Residential Property Price
Register.

## Key Findings

- National average prices bottomed out in **2012** (post financial-crisis low),
  then recovered steadily — up roughly 91% from the 2012 trough to 2025.
- **New-build properties carry a growing price premium** over second-hand
  homes: around 4% in 2015, rising to roughly 20% by 2019.
- **Post-pandemic price growth was fastest outside Dublin.** Roscommon, Sligo,
  and Leitrim all saw 80%+ price growth from 2020 to 2025 — consistent with a
  remote-work-driven shift in housing demand toward rural counties, rather
  than the capital.
- Dublin's mean price (€568k) sits well above its median (€467k) in 2025,
  reflecting a small number of very high-value sales pulling the average up —
  a reminder that mean price is a misleading summary statistic for skewed
  markets like residential property.

## A Data Quality Issue Worth Documenting

A small number of sales (~1,000, roughly 0.1% of the register) are recorded at
€5m or more. These are almost never single high-value homes — they're
**bulk/portfolio sales**, where an entire apartment block is sold as one
transaction and recorded as a single "property" sale (e.g. one real entry:
*"461 Apartments in Blocks A, B and C"*). Left in, these badly distort average
price calculations. Every query here filters them out via a `likely_bulk_sale`
flag defined in the enriched view — the same kind of measurement-validity
check applied throughout my MSc thesis analysis (see
[mscthesis](https://github.com/stefaniomarques/mscthesis)).

## Contents

- `schema.sql` — database, table, and an enriched view that standardises the
  New/Second-Hand flag (source data mixes English and Irish-language
  descriptions) and flags likely bulk sales
- `queries.sql` — 6 tested analytical queries: county price comparisons
  (mean vs. median), year-over-year growth, new-build price premium, top
  transaction areas, rolling quarterly averages, and county-level pandemic-era
  growth
- `data/README.md` — where to get the source data (not redistributed here)

## Reproducing the Analysis

1. Download the full register from
   [propertypriceregister.ie](https://www.propertypriceregister.ie) (see
   `data/README.md` for details)
2. Run `schema.sql` in MySQL Workbench (or any MySQL-compatible client) to
   create the database and table
3. Import the CSV using Workbench's Table Data Import Wizard
4. Run `queries.sql`

## Tools

MySQL / MySQL Workbench · Python (pandas, for data cleaning)
